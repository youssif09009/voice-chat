import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/room_models.dart';

/// Simple HTTP client for the REST endpoints.
class RoomApi {
  RoomApi._();
  static final RoomApi instance = RoomApi._();

  Future<List<VoiceRoomInfo>> fetchRooms() async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.serverUrl}/rooms'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list
            .map((j) => VoiceRoomInfo.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[RoomApi] fetchRooms error: $e');
    }
    return [];
  }

  Future<VoiceRoomInfo?> fetchRoom(String id) async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.serverUrl}/rooms/$id'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return VoiceRoomInfo.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      debugPrint('[RoomApi] fetchRoom error: $e');
    }
    return null;
  }

  /// Creates a new room on the server and returns the created [VoiceRoomInfo].
  Future<VoiceRoomInfo?> createRoom({
    required String name,
    required String username,
    required String hostEmoji,
    required String coverEmoji,
    required int maxSlots,
    required String category,
    required String accentColor,
    String announcement = '',
    bool isVip = false,
    List<String> tags = const [],
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.serverUrl}/rooms'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'hostName': username,
              'hostEmoji': hostEmoji,
              'coverEmoji': coverEmoji,
              'maxSlots': maxSlots,
              'category': category,
              'accentColor': accentColor,
              'announcement': announcement,
              'isVip': isVip,
              'tags': tags,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 201) {
        return VoiceRoomInfo.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
      }
      debugPrint('[RoomApi] createRoom failed: ${res.statusCode} ${res.body}');
    } catch (e) {
      debugPrint('[RoomApi] createRoom error: $e');
    }
    return null;
  }
}
