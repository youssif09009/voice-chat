
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../widgets/agency_widgets.dart';
import 'tab_helpers.dart';

const _kPurple = AppColors.primaryPurple;
const _kText   = Color(0xFF1A1A2E);
const _kSub    = Color(0xFF888899);
const _kBorder = Color(0xFFEEEEF5);

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});
  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  String? _roleFilter;
  final Set<String> _busy = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getUsers(role: _roleFilter);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) _users = (r.data!['rows'] as List).cast<Map<String, dynamic>>();
      else _error = r.error;
    });
  }

  Future<void> _toggleBan(String id, String status) async {
    setState(() => _busy.add(id));
    final r = status == 'banned'
        ? await AgencyApi.instance.unbanUser(id)
        : await AgencyApi.instance.banUser(id);
    if (!mounted) return;
    setState(() => _busy.remove(id));
    if (r.ok) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TabFilterBar(
        options: const [null, 'user', 'agent', 'host', 'admin'],
        labels:  const ['All', 'User', 'Agent', 'Host', 'Admin'],
        selected: _roleFilter,
        onSelect: (v) { setState(() => _roleFilter = v); _load(); },
      ),
      Expanded(
        child: _loading ? const LoadingPane()
            : _error != null ? ErrorPane(message: _error!, onRetry: _load)
            : RefreshIndicator(
                onRefresh: _load, color: _kPurple,
                backgroundColor: AppColors.background,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (_, i) => _UserRow(
                    user: _users[i],
                    busy: _busy.contains(_users[i]['id'] as String),
                    onToggle: () => _toggleBan(
                        _users[i]['id'] as String,
                        _users[i]['status'] as String),
                  ),
                ),
              ),
      ),
    ]);
  }
}

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool busy;
  final VoidCallback onToggle;
  const _UserRow({required this.user, required this.busy,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final status = user['status'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: _kPurple.withValues(alpha: 0.10),
          child: Text((user['username'] as String)[0].toUpperCase(),
              style: const TextStyle(color: _kPurple,
                  fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user['username'] as String, style: const TextStyle(
              color: _kText, fontWeight: FontWeight.w600, fontSize: 13)),
          Text(user['email'] as String,
              style: const TextStyle(color: _kSub, fontSize: 11)),
        ])),
        StatusBadge(user['role'] as String),
        const SizedBox(width: 8),
        busy
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _kPurple))
            : (user['role'] != 'admin'
                ? GestureDetector(
                    onTap: onToggle,
                    child: Icon(
                      status == 'banned'
                          ? Icons.lock_open_rounded
                          : Icons.block_rounded,
                      color: status == 'banned'
                          ? Colors.green
                          : const Color(0xFFDC2626),
                      size: 20,
                    ),
                  )
                : const SizedBox(width: 20)),
      ]),
    );
  }
}
