import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum RoomCategory { all, trending, gaming, music, social, vip }

extension RoomCategoryX on RoomCategory {
  String get label => name[0].toUpperCase() + name.substring(1);

  static RoomCategory fromString(String? s) {
    return RoomCategory.values.firstWhere(
      (c) => c.name == s,
      orElse: () => RoomCategory.social,
    );
  }
}

// ---------------------------------------------------------------------------
// VoiceRoomInfo  (lightweight — used in explorer list)
// ---------------------------------------------------------------------------

class VoiceRoomInfo {
  final String id;
  final String name;
  final String hostName;
  final String hostEmoji;
  final String coverEmoji;
  final int listenerCount;
  final int maxSlots;
  final RoomCategory category;
  final bool isVip;
  final List<String> tags;
  final Color accentColor;
  final String announcement;

  const VoiceRoomInfo({
    required this.id,
    required this.name,
    required this.hostName,
    required this.hostEmoji,
    required this.coverEmoji,
    required this.listenerCount,
    required this.maxSlots,
    required this.category,
    this.isVip = false,
    this.tags = const [],
    this.accentColor = AppColors.primaryPurple,
    this.announcement = '',
  });

  double get occupancyRatio =>
      maxSlots > 0 ? (listenerCount / maxSlots).clamp(0.0, 1.0) : 0;

  factory VoiceRoomInfo.fromJson(Map<String, dynamic> json) {
    return VoiceRoomInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      hostName: json['hostName'] as String,
      hostEmoji: json['hostEmoji'] as String? ?? '🎙',
      coverEmoji: json['coverEmoji'] as String? ?? '🎵',
      listenerCount: (json['listenerCount'] as num?)?.toInt() ?? 0,
      maxSlots: (json['maxSlots'] as num?)?.toInt() ?? 20,
      category: RoomCategoryX.fromString(json['category'] as String?),
      isVip: json['isVip'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      accentColor: _hexToColor(json['accentColor'] as String?),
      announcement: json['announcement'] as String? ?? '',
    );
  }

  static Color _hexToColor(String? hex) {
    if (hex == null) return AppColors.primaryPurple;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return AppColors.primaryPurple;
  }
}

// ---------------------------------------------------------------------------
// Participant
// ---------------------------------------------------------------------------

class Participant {
  final String socketId;
  final String username;
  final bool isHost;
  final bool isBot;
  bool isMuted;

  Participant({
    required this.socketId,
    required this.username,
    this.isHost = false,
    this.isBot = false,
    this.isMuted = true,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      socketId: json['socketId'] as String,
      username: json['username'] as String? ?? 'Guest',
      isHost: json['isHost'] as bool? ?? false,
      isBot: json['isBot'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? true,
    );
  }
}

// ---------------------------------------------------------------------------
// Chat message
// ---------------------------------------------------------------------------

enum ChatMessageType { gift, system, chat }

class ChatMsg {
  final String? sender;
  final String text;
  final ChatMessageType type;
  final DateTime timestamp;

  ChatMsg({
    this.sender,
    required this.text,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
