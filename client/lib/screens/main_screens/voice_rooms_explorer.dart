import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/room_models.dart';
import '../../services/room_api.dart';
import 'create_room_sheet.dart';
import 'voice_room.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class VoiceRoomsExplorerScreen extends StatefulWidget {
  const VoiceRoomsExplorerScreen({super.key});

  @override
  State<VoiceRoomsExplorerScreen> createState() =>
      _VoiceRoomsExplorerScreenState();
}

class _VoiceRoomsExplorerScreenState extends State<VoiceRoomsExplorerScreen> {
  RoomCategory _selectedCategory = RoomCategory.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<VoiceRoomInfo> _rooms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rooms = await RoomApi.instance.fetchRooms();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not reach the server.\nMake sure the backend is running.';
      });
    }
  }

  List<VoiceRoomInfo> get _filteredRooms {
    return _rooms.where((room) {
      final matchesCategory = _selectedCategory == RoomCategory.all ||
          room.category == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          room.name.toLowerCase().contains(q) ||
          room.hostName.toLowerCase().contains(q) ||
          room.tags.any((t) => t.toLowerCase().contains(q));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openRoom(VoiceRoomInfo room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceRoomScreen(roomInfo: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExplorerHeader(
              searchController: _searchController,
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              onRefresh: _loadRooms,
            ),
            _CategoryTabs(
              selected: _selectedCategory,
              onSelected: (c) => setState(() => _selectedCategory = c),
            ),
            const SizedBox(height: 4),
            if (_loading)
              const Expanded(child: _LoadingState())
            else if (_error != null && _rooms.isEmpty)
              Expanded(child: _ErrorState(message: _error!, onRetry: _loadRooms))
            else ...[
              if (_rooms.isNotEmpty)
                _FeaturedBanner(
                  room: _rooms.first,
                  onTap: () => _openRoom(_rooms.first),
                ),
              const SizedBox(height: 4),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Live Rooms',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _LiveBadge(),
                    const Spacer(),
                    Text(
                      '${rooms.length} room${rooms.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rooms.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRooms,
                        color: AppColors.primaryPurple,
                        backgroundColor: AppColors.surface,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) => _RoomCard(
                            room: rooms[index],
                            onTap: () => _openRoom(rooms[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: _CreateRoomFab(onTap: () async {
        await showCreateRoomSheet(context);
        // Refresh list after returning from sheet (room may have been created)
        _loadRooms();
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ExplorerHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  const _ExplorerHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Voice Rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Find your vibe',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 150,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category tabs
// ---------------------------------------------------------------------------

class _CategoryTabs extends StatelessWidget {
  final RoomCategory selected;
  final ValueChanged<RoomCategory> onSelected;

  const _CategoryTabs({required this.selected, required this.onSelected});

  static const _tabs = [
    (RoomCategory.all, '🌐', 'All'),
    (RoomCategory.trending, '🔥', 'Trending'),
    (RoomCategory.gaming, '🎮', 'Gaming'),
    (RoomCategory.music, '🎵', 'Music'),
    (RoomCategory.social, '💬', 'Social'),
    (RoomCategory.vip, '👑', 'VIP'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (category, emoji, label) = _tabs[index];
          final isSelected = selected == category;
          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Featured banner
// ---------------------------------------------------------------------------

class _FeaturedBanner extends StatelessWidget {
  final VoiceRoomInfo room;
  final VoidCallback onTap;

  const _FeaturedBanner({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D235D),
              room.accentColor.withValues(alpha: 0.4),
            ],
          ),
          border: Border.all(
            color: room.accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  room.coverEmoji,
                  style: TextStyle(
                    fontSize: 64,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: room.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: room.accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: room.accentColor, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              'FEATURED',
                              style: TextStyle(
                                color: room.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _LiveBadge(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(room.hostEmoji,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            room.hostName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.headset_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${room.listenerCount}/${room.maxSlots}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: room.accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: room.accentColor, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Room card
// ---------------------------------------------------------------------------

class _RoomCard extends StatelessWidget {
  final VoiceRoomInfo room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: room.accentColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: room.accentColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(room.coverEmoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.isVip)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('👑',
                              style: TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(room.hostEmoji,
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        room.hostName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: room.tags
                        .take(2)
                        .map((t) =>
                            _TagChip(label: t, color: room.accentColor))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.headset_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${room.listenerCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '/${room.maxSlots}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _OccupancyBar(
                    ratio: room.occupancyRatio, color: room.accentColor),
                const SizedBox(height: 8),
                const _LiveBadge(compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  final double ratio;
  final Color color;
  const _OccupancyBar({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 4,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: AlwaysStoppedAnimation<Color>(
            ratio >= 1.0 ? AppColors.red : color,
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool compact;
  const _LiveBadge({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.red,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryPurple),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😵', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No rooms found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different category or search term',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateRoomFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateRoomFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryPurple, Color(0xFFD946EF)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Create Room',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
