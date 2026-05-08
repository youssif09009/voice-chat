import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../models/room_models.dart';
import '../../services/socket_service.dart';
import '../../services/webrtc_service.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class VoiceRoomScreen extends StatefulWidget {
  final VoiceRoomInfo roomInfo;

  const VoiceRoomScreen({super.key, required this.roomInfo});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScroll = ScrollController();

  // State
  bool _isMuted = true;
  bool _micReady = false;
  bool _connecting = true;
  String? _mySocketId;
  bool _amHost = false;

  List<Participant> _participants = [];
  final List<ChatMsg> _messages = [];

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // Pre-cache panel images so they all render on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final path in [
        'assets/images/panel_icon_1.png',
        'assets/images/panel_icon_2.png',
        'assets/images/panel_icon_3.png',
      ]) {
        precacheImage(AssetImage(path), context);
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScroll.dispose();
    _teardown();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Setup
  // -------------------------------------------------------------------------

  Future<void> _bootstrap() async {
    // 1. Request mic permission
    final status = await Permission.microphone.request();
    if (!mounted) return;

    if (status.isGranted) {
      final ok = await WebRtcService.instance.init();
      if (mounted) setState(() => _micReady = ok);
    }

    // 2. Connect socket & join room
    final socket = SocketService.instance;
    socket.connect();

    socket.on('connect', (_) {
      _mySocketId = socket.socket.id;
      socket.emit('join_room', {
        'roomId': widget.roomInfo.id,
        'username': 'You',
      });
    });

    socket.on('room_joined', (data) {
      final room = data['room'] as Map<String, dynamic>;
      final you = data['you'] as Map<String, dynamic>;
      final participants = (room['participants'] as List)
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _participants = participants;
        _connecting = false;
        _amHost = you['isHost'] as bool? ?? false;
      });

      _addSystemMessage('Welcome! Enjoy the room. 🎉');

      // Offer to all existing peers (except ourselves and bots)
      for (final p in participants) {
        if (p.socketId != _mySocketId && !p.isBot) {
          WebRtcService.instance.createOffer(p.socketId);
        }
      }
    });

    socket.on('peer_joined', (data) {
      final p = Participant.fromJson(
          data['participant'] as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _participants.removeWhere((x) => x.socketId == p.socketId);
        _participants.add(p);
      });
      _addSystemMessage('${p.username} joined the room.');
      // Don't attempt WebRTC with bots — they have no real socket
      if (!p.isBot && _mySocketId != null) {
        WebRtcService.instance.createOffer(p.socketId);
      }
    });

    socket.on('peer_left', (data) {
      final socketId = data['socketId'] as String;
      if (!mounted) return;
      final leaving = _participants.firstWhere(
        (p) => p.socketId == socketId,
        orElse: () => Participant(socketId: socketId, username: 'Someone'),
      );
      setState(() =>
          _participants.removeWhere((p) => p.socketId == socketId));
      // Only clean up WebRTC for real peers (bots have no peer connection)
      if (!socketId.startsWith('bot_')) {
        WebRtcService.instance.removePeer(socketId);
      }
      _addSystemMessage('${leaving.username} left the room.');
    });

    socket.on('participant_muted', (data) {
      final socketId = data['socketId'] as String;
      final isMuted = data['isMuted'] as bool;
      if (!mounted) return;
      setState(() {
        for (final p in _participants) {
          if (p.socketId == socketId) p.isMuted = isMuted;
        }
        // Sync our own mute state if we were force-muted
        if (socketId == _mySocketId && isMuted) _isMuted = true;
      });
    });

    // Host force-muted us
    socket.on('force_muted', (_) {
      if (!mounted) return;
      setState(() => _isMuted = true);
      WebRtcService.instance.setMuted(true);
      _addSystemMessage('🔇 You were muted by the host.');
    });

    // We were kicked
    socket.on('kicked', (_) {
      if (!mounted) return;
      _addSystemMessage('🚫 You were removed by the host.');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.maybePop(context);
      });
    });

    socket.on('chat_message', (data) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMsg(
          sender: data['sender'] as String?,
          text: data['text'] as String,
          type: ChatMessageType.chat,
        ));
      });
      _scrollToBottom();
    });
  }

  void _teardown() {
    final socket = SocketService.instance;
    socket.off('connect');
    socket.off('room_joined');
    socket.off('peer_joined');
    socket.off('peer_left');
    socket.off('participant_muted');
    socket.off('force_muted');
    socket.off('kicked');
    socket.off('chat_message');
    socket.disconnect();
    WebRtcService.instance.dispose();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  void _toggleMic() {
    final newMuted = !_isMuted;
    setState(() => _isMuted = newMuted);
    WebRtcService.instance.setMuted(newMuted);
    SocketService.instance.emit('set_muted', {'isMuted': newMuted});
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    SocketService.instance.emit('chat_message', {
      'roomId': widget.roomInfo.id,
      'text': text,
    });
    _chatController.clear();
  }

  /// Host taps a participant slot — show action sheet
  void _onParticipantTap(Participant p) {
    if (!_amHost) return;
    if (p.socketId == _mySocketId) return; // can't act on yourself

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _HostActionSheet(
        participant: p,
        onMute: () {
          Navigator.pop(context);
          SocketService.instance.emit('host_mute', {
            'targetSocketId': p.socketId,
          });
          _addSystemMessage('🔇 You muted ${p.username}.');
        },
        onKick: () {
          Navigator.pop(context);
          SocketService.instance.emit('host_kick', {
            'targetSocketId': p.socketId,
          });
          _addSystemMessage('🚫 You removed ${p.username}.');
        },
      ),
    );
  }

  void _addSystemMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMsg(text: text, type: ChatMessageType.system));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: DefaultSelectionStyle(
        selectionColor: Colors.transparent,
        child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/images/room_bg.jpeg', fit: BoxFit.cover),
          // Premium multi-stop overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.80),
                ],
                stops: const [0.0, 0.22, 0.60, 1.0],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _RoomAppBar(
                  roomInfo: widget.roomInfo,
                  onClose: () => Navigator.maybePop(context),
                ),
                _AnnouncementBanner(text: widget.roomInfo.announcement),
                const _GiftPromoBanner(),
                if (_connecting)
                  LinearProgressIndicator(
                    color: AppColors.primaryPurple,
                    backgroundColor:
                        AppColors.primaryPurple.withValues(alpha: 0.15),
                    minHeight: 2,
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // chatHeight must fit 3 panel buttons (min ~40px each + padding)
                      const double chatHeight = 155;
                      final double gridHeight =
                          constraints.maxHeight - chatHeight;
                      return Column(
                        children: [
                          // ── Slots grid — full width, no overlap ──
                          SizedBox(
                            height: gridHeight,
                            child: _SlotsGrid(
                              participants: _participants,
                              mySocketId: _mySocketId,
                              availableHeight: gridHeight,
                              amHost: _amHost,
                              onParticipantTap: _onParticipantTap,
                            ),
                          ),
                          // ── Chat + right panel side by side ──
                          SizedBox(
                            height: chatHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Chat feed takes remaining width
                                Expanded(
                                  child: _ChatFeed(
                                    messages: _messages,
                                    scrollController: _chatScroll,
                                  ),
                                ),
                                // Right panel — fixed width, never overlaps grid
                                const _RightSidePanel(),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _BottomBar(
                  controller: _chatController,
                  isMuted: _isMuted,
                  micReady: _micReady,
                  onMicTap: _toggleMic,
                  onGiftTap: () {},
                  onMenuTap: () {},
                  onSend: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      ), // DefaultSelectionStyle
    );
  }
}

// ---------------------------------------------------------------------------
// App Bar — next-gen premium
// ---------------------------------------------------------------------------

class _RoomAppBar extends StatelessWidget {
  final VoiceRoomInfo roomInfo;
  final VoidCallback onClose;

  const _RoomAppBar({required this.roomInfo, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Host avatar — glowing gold ring
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B2D8E), Color(0xFF1A0A30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.gold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.45),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(roomInfo.hostEmoji,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              // LV badge
              Positioned(
                bottom: -4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: const Text('LV7',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roomInfo.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 8),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      roomInfo.hostName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4)
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    _Pill(
                      text:
                          'ID:${roomInfo.id.substring(0, 6).toUpperCase()}',
                      bg: Colors.white.withValues(alpha: 0.08),
                      border: Colors.white.withValues(alpha: 0.18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Heart — cyan glow
          _TopBtn(
            onTap: () {},
            gradient: const LinearGradient(
              colors: [Color(0xFF006064), Color(0xFF00BCD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            glowColor: const Color(0xFF00BCD4),
            child: const Icon(Icons.favorite_border_rounded,
                color: Colors.white, size: 17),
          ),
          const SizedBox(width: 8),
          // Share / close
          _TopBtn(
            onTap: onClose,
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.ios_share_rounded,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Reusable top-bar button
class _TopBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Gradient gradient;
  final Color? glowColor;
  final Color? border;

  const _TopBtn({
    required this.onTap,
    required this.child,
    required this.gradient,
    this.glowColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          border: border != null
              ? Border.all(color: border!, width: 1)
              : null,
          boxShadow: [
            if (glowColor != null)
              BoxShadow(
                color: glowColor!.withValues(alpha: 0.45),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Tiny pill badge
class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color border;

  const _Pill({
    required this.text,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Right Side Panel — 3 premium image buttons, perfectly centered
// ---------------------------------------------------------------------------

class _RightSidePanel extends StatelessWidget {
  const _RightSidePanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight;
          // Each button = 1/3 of height minus 20px total padding
          final double btnSize = ((h - 20) / 3).clamp(36.0, 64.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PanelBtn(
                  assetPath: 'assets/images/panel_icon_1.png',
                  size: btnSize),
              _PanelBtn(
                  assetPath: 'assets/images/panel_icon_2.png',
                  size: btnSize),
              _PanelBtn(
                  assetPath: 'assets/images/panel_icon_3.png',
                  size: btnSize),
            ],
          );
        },
      ),
    );
  }
}

/// Premium panel button:
/// - Transparent background (room bg shows through)
/// - Gold→purple→cyan gradient border via CustomPainter
/// - Image centered inside, top-aligned to avoid watermark
/// - Dark gradient overlay on bottom half hides any watermark text
class _PanelBtn extends StatelessWidget {
  final String assetPath;
  final double size;

  const _PanelBtn({required this.assetPath, required this.size});

  static const double _r = 13.0; // border radius
  static const double _bw = 2.5; // border width

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            // Draws the gradient border ring
            painter: _GradientBorderPainter(
              borderWidth: _bw,
              radius: _r,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFFFFD700), // gold
                  Color(0xFF8B5CF6), // purple
                  Color(0xFF06B6D4), // cyan
                  Color(0xFFFFD700), // back to gold
                ],
                stops: [0.0, 0.33, 0.66, 1.0],
              ),
            ),
            // Foreground: transparent bg + image + watermark cover
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_r - _bw),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                fit: StackFit.expand,
                children: [
                  // Transparent dark bg — room background shows through
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(_r - _bw),
                    ),
                  ),
                  // Image — top-aligned so main content shows
                  Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    cacheWidth: 120,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }
                      // Shimmer while loading
                      return Container(
                        color: Colors.white.withValues(alpha: 0.04),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: size * 0.38,
                      ),
                    ),
                  ),
                  // Dark gradient on bottom — covers watermark text
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: size * 0.42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a rounded-rectangle gradient border ring.
class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderWidth;
  final double radius;

  const _GradientBorderPainter({
    required this.gradient,
    required this.borderWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outer = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(
        rect.deflate(borderWidth),
        Radius.circular(radius - borderWidth),
      ));
    final ring = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(
      ring,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.gradient != gradient ||
      old.borderWidth != borderWidth ||
      old.radius != radius;
}

// ---------------------------------------------------------------------------
// Announcement Banner — glowing gold text
// ---------------------------------------------------------------------------

class _AnnouncementBanner extends StatelessWidget {
  final String text;
  const _AnnouncementBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text('📢', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 6),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gift Promo Banner — next-gen premium pill
// ---------------------------------------------------------------------------

class _GiftPromoBanner extends StatelessWidget {
  const _GiftPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D0080),
            Color(0xFF7B1FA2),
            Color(0xFF9C27B0),
            Color(0xFF7B1FA2),
            Color(0xFF3D0080),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gold ring
          Container(
            margin: const EdgeInsets.all(5),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4A1080), Color(0xFF1A0840)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.gold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.person,
                color: AppColors.accentPurple, size: 17),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Tap mic to go live and connect! 🎙',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // GO button — gold gradient
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Text(
              'GO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slots Grid — 5 cols × 4 rows = 20, zero gaps, no white lines
// ---------------------------------------------------------------------------

class _SlotsGrid extends StatelessWidget {
  final List<Participant> participants;
  final String? mySocketId;
  final double availableHeight;
  final bool amHost;
  final void Function(Participant) onParticipantTap;

  const _SlotsGrid({
    required this.participants,
    required this.mySocketId,
    required this.availableHeight,
    required this.amHost,
    required this.onParticipantTap,
  });

  @override
  Widget build(BuildContext context) {
    const int cols = 5; // 5 cols × 4 rows = 20 slots, wider cells
    const int rows = 4;
    const int total = cols * rows;

    final double screenW = MediaQuery.of(context).size.width;
    final double cellW = screenW / cols;
    final double cellH = availableHeight / rows;

    const double labelH = 14.0;
    const double gap = 3.0;
    const double safety = 4.0;
    final double avatarSize =
        (cellH - labelH - gap - safety).clamp(28.0, 999.0);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: cellW / cellH,
      ),
      itemCount: total,
      itemBuilder: (context, index) {
        if (index < participants.length) {
          final p = participants[index];
          final isMe = p.socketId == mySocketId;
          return GestureDetector(
            onTap: amHost && !isMe ? () => onParticipantTap(p) : null,
            child: _ParticipantSlot(
              participant: p,
              isMe: isMe,
              avatarSize: avatarSize,
              cellH: cellH,
              isHostView: amHost && !isMe,
            ),
          );
        }
        return _EmptySlot(
            number: index + 1, avatarSize: avatarSize, cellH: cellH);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Participant Slot — premium next-gen
// ---------------------------------------------------------------------------

class _ParticipantSlot extends StatelessWidget {
  final Participant participant;
  final bool isMe;
  final double avatarSize;
  final double cellH;
  final bool isHostView;

  const _ParticipantSlot({
    required this.participant,
    required this.avatarSize,
    required this.cellH,
    this.isMe = false,
    this.isHostView = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color ringColor = participant.isHost
        ? AppColors.gold
        : isMe
            ? const Color(0xFF00E5FF)
            : AppColors.primaryPurple.withValues(alpha: 0.8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : cellH;
        // Avatar = 74% of cell height — no upper clamp, grows with cell
        final double sz = (h * 0.74).clamp(26.0, 999.0);
        final double inner = sz - 4;
        final double badge = (sz * 0.28).clamp(9.0, 17.0);
        // Label sits at the bottom of the cell
        const double labelH = 14.0;
        final double avatarTop = (h - sz - labelH - 2) / 2;

        return SizedBox(
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Avatar — positioned from top
              Positioned(
                top: avatarTop.clamp(0.0, h - sz),
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: sz,
                    height: sz,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      alignment: Alignment.center,
                      children: [
                // Ring with glow
                Container(
                  width: sz,
                  height: sz,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor,
                      width: participant.isHost || isMe ? 2.5 : 1.5,
                    ),
                    boxShadow: participant.isHost || isMe
                        ? [
                            BoxShadow(
                              color: ringColor.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Avatar fill
                Container(
                  width: inner,
                  height: inner,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: participant.isBot
                          ? [
                              const Color(0xFF0A2A18),
                              const Color(0xFF1A4D30)
                            ]
                          : participant.isHost
                              ? [
                                  const Color(0xFF4A1A80),
                                  const Color(0xFF1A0840)
                                ]
                              : isMe
                                  ? [
                                      const Color(0xFF003A4A),
                                      const Color(0xFF001A22)
                                    ]
                                  : [
                                      const Color(0xFF2A1F5A),
                                      const Color(0xFF150F30)
                                    ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    participant.isBot
                        ? Icons.smart_toy_outlined
                        : participant.isHost
                            ? Icons.person
                            : Icons.person_outline,
                    color: participant.isBot
                        ? Colors.greenAccent.shade400
                        : isMe
                            ? const Color(0xFF00E5FF)
                            : AppColors.accentPurple,
                    size: inner * 0.46,
                  ),
                ),
                // Crown — top of avatar, inside bounds
                if (participant.isHost)
                  Positioned(
                    top: 0,
                    child: Text('👑',
                        style: TextStyle(
                          fontSize: sz * 0.22,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 4)
                          ],
                        )),
                  ),
                // Coin badge — bottom left
                Positioned(
                  bottom: 2,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6D00), Color(0xFFFFD600)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 6)),
                        const SizedBox(width: 1),
                        Text(
                          participant.isHost ? '1M' : '0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mute badge — bottom right
                if (participant.isMuted)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: badge,
                      height: badge,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFFF1744)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.black.withValues(alpha: 0.6),
                            width: 1.5),
                      ),
                      child: Icon(Icons.mic_off,
                          color: Colors.white, size: badge * 0.55),
                    ),
                  ),
                // Bot badge — top right
                if (participant.isBot)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: badge * 0.9,
                      height: badge * 0.9,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.smart_toy,
                          color: Colors.white, size: badge * 0.5),
                    ),
                  ),
                // Host-view tap hint
                if (isHostView)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
                ),
              ),
              // Label — pinned to bottom of cell
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: labelH,
                child: SelectionContainer.disabled(
                  child: Text(
                    isMe ? 'You' : participant.username,
                    style: TextStyle(
                      color: participant.isHost
                          ? AppColors.gold
                          : participant.isBot
                              ? Colors.greenAccent.shade400
                              : isMe
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white,
                      fontSize: 9,
                      fontWeight: participant.isHost || isMe
                          ? FontWeight.bold
                          : FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 6),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int number;
  final double avatarSize;
  final double cellH;

  const _EmptySlot({
    required this.number,
    required this.avatarSize,
    required this.cellH,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
      height: cellH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Circle — centered
          Positioned(
            top: 0,
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // Number label — pinned to bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 14,
            child: Text(
              '$number',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 9,
                fontWeight: FontWeight.w400,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 4)
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat Feed
// ---------------------------------------------------------------------------

class _ChatFeed extends StatelessWidget {
  final List<ChatMsg> messages;
  final ScrollController scrollController;

  const _ChatFeed({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      itemCount: messages.length,
      itemBuilder: (context, index) =>
          _ChatBubble(message: messages[index]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMsg message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.gift:
        return _GiftMessage(message: message);
      case ChatMessageType.system:
        return _SystemMessage(text: message.text);
      case ChatMessageType.chat:
        return _UserChatMessage(message: message);
    }
  }
}

class _GiftMessage extends StatelessWidget {
  final ChatMsg message;
  const _GiftMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Small avatar circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: const Icon(Icons.person,
                color: AppColors.accentPurple, size: 14),
          ),
          const SizedBox(width: 8),
          // Text — no background, just floating
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.35),
                children: [
                  const TextSpan(text: '🎁 '),
                  TextSpan(
                    text: '${message.sender ?? ''}  ',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: message.text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final String text;
  const _SystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    // Gold bold text, no background — exactly like the screenshot
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          height: 1.35,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 6),
            Shadow(color: Colors.black, blurRadius: 2),
          ],
        ),
      ),
    );
  }
}

class _UserChatMessage extends StatelessWidget {
  final ChatMsg message;
  const _UserChatMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Small purple avatar circle — matches screenshot
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF2E1065)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: AppColors.primaryPurple, width: 1.5),
            ),
            child: const Icon(Icons.person_outline,
                color: AppColors.accentPurple, size: 14),
          ),
          const SizedBox(width: 8),
          // Text — no background pill, just floating text like screenshot
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.35),
                children: [
                  TextSpan(
                    text: '${message.sender}  ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: message.text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Bar — next-gen premium
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isMuted;
  final bool micReady;
  final VoidCallback onMicTap;
  final VoidCallback onGiftTap;
  final VoidCallback onMenuTap;
  final VoidCallback onSend;

  const _BottomBar({
    required this.controller,
    required this.isMuted,
    required this.micReady,
    required this.onMicTap,
    required this.onGiftTap,
    required this.onMenuTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bool micActive = !isMuted && micReady;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.78),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Suggestion pill ──
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                      ),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Say hello to everyone!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.35),
                      size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── Input row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Say something',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Grid button
              _BarBtn(
                onTap: onMenuTap,
                child: const Icon(Icons.grid_view_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              // Mic button — glows purple when active
              _BarBtn(
                onTap: micReady ? onMicTap : () {},
                active: micActive,
                activeGradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                glowColor: micActive
                    ? AppColors.primaryPurple
                    : null,
                child: Icon(
                  micActive
                      ? Icons.mic_rounded
                      : Icons.mic_off_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Gift button with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _BarBtn(
                    onTap: onGiftTap,
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFFFF6D00), Color(0xFFFFD600)],
                    ),
                    child: const Text('🎁',
                        style: TextStyle(fontSize: 20)),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFFF1744)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.red.withValues(alpha: 0.6),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '91',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool active;
  final Gradient? activeGradient;
  final Color? glowColor;

  const _BarBtn({
    required this.onTap,
    required this.child,
    this.active = false,
    this.activeGradient,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: active && activeGradient != null
              ? activeGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
          border: Border.all(
            color: active
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            if (glowColor != null)
              BoxShadow(
                color: glowColor!.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Host Action Sheet — shown when host taps a participant slot
// ---------------------------------------------------------------------------

class _HostActionSheet extends StatelessWidget {
  final Participant participant;
  final VoidCallback onMute;
  final VoidCallback onKick;

  const _HostActionSheet({
    required this.participant,
    required this.onMute,
    required this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12112A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Participant info
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D235D),
                  border: Border.all(
                      color: AppColors.primaryPurple, width: 2),
                ),
                child: Icon(
                  participant.isBot
                      ? Icons.smart_toy_outlined
                      : Icons.person_outline,
                  color: participant.isBot
                      ? Colors.greenAccent
                      : AppColors.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    participant.isBot ? 'Test Bot' : 'Participant',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Mute action
          _ActionTile(
            icon: Icons.mic_off_rounded,
            label: participant.isMuted ? 'Already Muted' : 'Mute Participant',
            color: participant.isMuted
                ? Colors.white38
                : AppColors.primaryPurple,
            onTap: participant.isMuted ? null : onMute,
          ),
          const SizedBox(height: 10),
          // Kick action
          _ActionTile(
            icon: Icons.person_remove_rounded,
            label: 'Remove from Room',
            color: AppColors.red,
            onTap: onKick,
          ),
          const SizedBox(height: 10),
          // Cancel
          _ActionTile(
            icon: Icons.close_rounded,
            label: 'Cancel',
            color: Colors.white38,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: onTap == null ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: onTap == null ? 0.1 : 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: onTap == null
                    ? Colors.white38
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

