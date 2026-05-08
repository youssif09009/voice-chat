import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

// ---------------------------------------------------------------------------
// Simple result wrapper
// ---------------------------------------------------------------------------

class ApiResult<T> {
  final T? data;
  final String? error;
  bool get ok => error == null;

  const ApiResult.success(this.data) : error = null;
  const ApiResult.failure(this.error) : data = null;
}

// ---------------------------------------------------------------------------
// Agency API singleton
// ---------------------------------------------------------------------------

class AgencyApi {
  AgencyApi._();
  static final AgencyApi instance = AgencyApi._();

  String? _token;
  String? _userId;
  String? _role;
  String? _username;

  String? get token    => _token;
  String? get userId   => _userId;
  String? get role     => _role;
  String? get username => _username;
  bool   get isLoggedIn => _token != null;

  void setSession({
    required String token,
    required String userId,
    required String role,
    required String username,
  }) {
    _token    = token;
    _userId   = userId;
    _role     = role;
    _username = username;
  }

  void clearSession() {
    _token = _userId = _role = _username = null;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String get _base => AppConstants.serverUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<ApiResult<Map<String, dynamic>>> _get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$_base$path'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.success(body);
      }
      return ApiResult.failure(body['error'] as String? ?? 'Request failed');
    } catch (e) {
      debugPrint('[AgencyApi] GET $path error: $e');
      return ApiResult.failure('Network error — is the server running?');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$_base$path'),
              headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.success(resBody);
      }
      return ApiResult.failure(
          resBody['error'] as String? ?? 'Request failed');
    } catch (e) {
      debugPrint('[AgencyApi] POST $path error: $e');
      return ApiResult.failure('Network error — is the server running?');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _patch(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(Uri.parse('$_base$path'),
              headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.success(resBody);
      }
      return ApiResult.failure(
          resBody['error'] as String? ?? 'Request failed');
    } catch (e) {
      debugPrint('[AgencyApi] PATCH $path error: $e');
      return ApiResult.failure('Network error');
    }
  }

  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  Future<ApiResult<Map<String, dynamic>>> login(
      String email, String password) async {
    final r = await _post('/api/users/login', {
      'email': email,
      'password': password,
    });
    if (r.ok && r.data != null) {
      setSession(
        token:    r.data!['token'] as String,
        userId:   r.data!['userId'] as String,
        role:     r.data!['role'] as String,
        username: r.data!['username'] as String,
      );
    }
    return r;
  }

  Future<ApiResult<Map<String, dynamic>>> register(
      String username, String email, String password,
      {String? inviteCode}) async {
    return _post('/api/users/register', {
      'username': username,
      'email': email,
      'password': password,
      if (inviteCode != null && inviteCode.isNotEmpty) 'inviteCode': inviteCode,
    });
  }

  // -------------------------------------------------------------------------
  // Admin
  // -------------------------------------------------------------------------

  Future<ApiResult<Map<String, dynamic>>> getAnalytics() =>
      _get('/api/admin/analytics');

  Future<ApiResult<Map<String, dynamic>>> getApplications() =>
      _get('/api/admin/applications');

  Future<ApiResult<Map<String, dynamic>>> getUsers(
          {int page = 1, String? role, String? status}) =>
      _get('/api/admin/users?page=$page'
          '${role != null ? "&role=$role" : ""}'
          '${status != null ? "&status=$status" : ""}');

  Future<ApiResult<Map<String, dynamic>>> approveAgent(String id) =>
      _post('/api/admin/agents/$id/approve', {});

  Future<ApiResult<Map<String, dynamic>>> rejectAgent(String id) =>
      _post('/api/admin/agents/$id/reject', {});

  Future<ApiResult<Map<String, dynamic>>> approveHost(String id) =>
      _post('/api/admin/hosts/$id/approve', {});

  Future<ApiResult<Map<String, dynamic>>> rejectHost(String id) =>
      _post('/api/admin/hosts/$id/reject', {});

  Future<ApiResult<Map<String, dynamic>>> setAgentCommission(
          String id, double rate) =>
      _patch('/api/admin/agents/$id/commission', {'rate': rate});

  Future<ApiResult<Map<String, dynamic>>> setHostCommission(
          String id, double rate) =>
      _patch('/api/admin/hosts/$id/commission', {'rate': rate});

  Future<ApiResult<Map<String, dynamic>>> banUser(String id) =>
      _post('/api/admin/users/$id/ban', {});

  Future<ApiResult<Map<String, dynamic>>> unbanUser(String id) =>
      _post('/api/admin/users/$id/unban', {});

  // Admin — agents & hosts lists with full stats
  Future<ApiResult<Map<String, dynamic>>> getAdminAgentsList(
          {int page = 1, String? status}) =>
      _get('/api/admin/agents-list?page=$page'
          '${status != null ? "&status=$status" : ""}');

  Future<ApiResult<Map<String, dynamic>>> getAdminHostsList(
          {int page = 1, String? status}) =>
      _get('/api/admin/hosts-list?page=$page'
          '${status != null ? "&status=$status" : ""}');

  Future<ApiResult<Map<String, dynamic>>> getEarningsBreakdown() =>
      _get('/api/admin/earnings-breakdown');

  // -------------------------------------------------------------------------
  // Agents
  // -------------------------------------------------------------------------

  Future<ApiResult<Map<String, dynamic>>> applyAsAgent() =>
      _post('/api/agents/apply', {});

  Future<ApiResult<Map<String, dynamic>>> getAgentDashboard() =>
      _get('/api/agents/dashboard');

  Future<ApiResult<Map<String, dynamic>>> getAgentTargets() =>
      _get('/api/agents/targets');

  Future<ApiResult<Map<String, dynamic>>> getAgentEarnings(
          {int page = 1}) =>
      _get('/api/agents/earnings?page=$page');

  Future<ApiResult<Map<String, dynamic>>> getInviteCode() =>
      _get('/api/agents/invite-code');

  // -------------------------------------------------------------------------
  // Hosts
  // -------------------------------------------------------------------------

  Future<ApiResult<Map<String, dynamic>>> applyAsHost() =>
      _post('/api/hosts/apply', {});

  Future<ApiResult<Map<String, dynamic>>> getHostDashboard() =>
      _get('/api/hosts/dashboard');

  Future<ApiResult<Map<String, dynamic>>> getHostTargets() =>
      _get('/api/hosts/targets');

  Future<ApiResult<Map<String, dynamic>>> getHostEarnings({int page = 1}) =>
      _get('/api/hosts/earnings?page=$page');

  // -------------------------------------------------------------------------
  // Rankings
  // -------------------------------------------------------------------------

  Future<ApiResult<Map<String, dynamic>>> getAgentRankings(
          {String period = 'monthly'}) =>
      _get('/api/rankings/agents?period=$period');

  Future<ApiResult<Map<String, dynamic>>> getHostRankings(
          {String period = 'monthly'}) =>
      _get('/api/rankings/hosts?period=$period');

  // -------------------------------------------------------------------------
  // Gifts
  // -------------------------------------------------------------------------

  Future<ApiResult<Map<String, dynamic>>> sendGift(
          String receiverId, double amount, {String? roomId}) =>
      _post('/api/gifts/send', {
        'receiverId': receiverId,
        'amount': amount,
        if (roomId != null) 'roomId': roomId,
      });
}
