import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../widgets/agency_widgets.dart';
import 'tab_helpers.dart';

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
            : _users.isEmpty ? const TabEmpty(label: 'No users found')
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.primaryPurple,
                backgroundColor: AppColors.surface,
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
  const _UserRow({required this.user, required this.busy, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final status = user['status'] as String;
    final isBanned = status == 'banned';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBanned
              ? AppColors.red.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
          child: Text(
            (user['username'] as String)[0].toUpperCase(),
            style: const TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user['username'] as String, style: AppTypography.labelMedium),
          const SizedBox(height: 2),
          Text(user['email'] as String, style: AppTypography.caption),
        ])),
        StatusBadge(user['role'] as String),
        const SizedBox(width: 10),
        if (user['role'] != 'admin')
          busy
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primaryPurple))
              : GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: isBanned
                          ? AppColors.green.withValues(alpha: 0.12)
                          : AppColors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBanned
                            ? AppColors.green.withValues(alpha: 0.35)
                            : AppColors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
                      color: isBanned ? AppColors.green : AppColors.red,
                      size: 16,
                    ),
                  ),
                )
        else
          const SizedBox(width: 34),
      ]),
    );
  }
}
