import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';

/// Manages WebRTC peer connections for voice chat.
///
/// Flow:
///   1. Call [init] after joining a room to capture the local mic stream.
///   2. For each existing peer, call [createOffer].
///   3. When a new peer joins, they call [createOffer] to us.
///   4. Socket events relay offer/answer/ICE between peers.
class WebRtcService {
  WebRtcService._();
  static final WebRtcService instance = WebRtcService._();

  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peers = {};

  bool get hasLocalStream => _localStream != null;

  // -------------------------------------------------------------------------
  // Init — capture microphone
  // -------------------------------------------------------------------------

  Future<bool> init() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      _listenSignaling();
      return true;
    } catch (e) {
      debugPrint('[WebRTC] getUserMedia error: $e');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mute / unmute local track
  // -------------------------------------------------------------------------

  void setMuted(bool muted) {
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !muted);
  }

  // -------------------------------------------------------------------------
  // Create offer (called when we want to connect to an existing peer)
  // -------------------------------------------------------------------------

  Future<void> createOffer(String targetSocketId) async {
    final pc = await _createPeerConnection(targetSocketId);
    final offer = await pc.createOffer({'offerToReceiveAudio': true});
    await pc.setLocalDescription(offer);

    SocketService.instance.emit('webrtc_offer', {
      'targetSocketId': targetSocketId,
      'sdp': {'type': offer.type, 'sdp': offer.sdp},
    });
  }

  // -------------------------------------------------------------------------
  // Signaling listeners
  // -------------------------------------------------------------------------

  void _listenSignaling() {
    final socket = SocketService.instance;

    socket.on('webrtc_offer', (data) async {
      final from = data['fromSocketId'] as String;
      final sdpMap = data['sdp'] as Map<String, dynamic>;

      final pc = await _createPeerConnection(from);
      await pc.setRemoteDescription(
        RTCSessionDescription(sdpMap['sdp'] as String, sdpMap['type'] as String),
      );

      final answer = await pc.createAnswer({'offerToReceiveAudio': true});
      await pc.setLocalDescription(answer);

      socket.emit('webrtc_answer', {
        'targetSocketId': from,
        'sdp': {'type': answer.type, 'sdp': answer.sdp},
      });
    });

    socket.on('webrtc_answer', (data) async {
      final from = data['fromSocketId'] as String;
      final sdpMap = data['sdp'] as Map<String, dynamic>;
      final pc = _peers[from];
      if (pc == null) return;
      await pc.setRemoteDescription(
        RTCSessionDescription(sdpMap['sdp'] as String, sdpMap['type'] as String),
      );
    });

    socket.on('webrtc_ice', (data) async {
      final from = data['fromSocketId'] as String;
      final candidateMap = data['candidate'] as Map<String, dynamic>;
      final pc = _peers[from];
      if (pc == null) return;
      await pc.addCandidate(
        RTCIceCandidate(
          candidateMap['candidate'] as String,
          candidateMap['sdpMid'] as String?,
          candidateMap['sdpMLineIndex'] as int?,
        ),
      );
    });
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  Future<RTCPeerConnection> _createPeerConnection(String peerId) async {
    if (_peers.containsKey(peerId)) return _peers[peerId]!;

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    final pc = await createPeerConnection(config);
    _peers[peerId] = pc;

    // Add local audio tracks
    _localStream?.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });

    // ICE candidates
    pc.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      SocketService.instance.emit('webrtc_ice', {
        'targetSocketId': peerId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    pc.onConnectionState = (state) {
      debugPrint('[WebRTC] $peerId → $state');
    };

    return pc;
  }

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  Future<void> dispose() async {
    SocketService.instance.off('webrtc_offer');
    SocketService.instance.off('webrtc_answer');
    SocketService.instance.off('webrtc_ice');

    for (final pc in _peers.values) {
      await pc.close();
    }
    _peers.clear();

    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream?.dispose();
    _localStream = null;
  }

  void removePeer(String socketId) {
    _peers[socketId]?.close();
    _peers.remove(socketId);
  }
}
