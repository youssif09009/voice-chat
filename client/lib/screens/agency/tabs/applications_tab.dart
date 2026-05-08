
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../widgets/agency_widgets.dart';

const _kPurple = AppColors.primaryPurple;
const _kText   = Color(0xFF1A1A2E);
const _kSub    = Color(0xFF888899);
const _kBorder = Color(0xFFEEEEF5);

class ApplicationsTab extends StatefulWidget {
  const ApplicationsTab({super.key});
  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getApplications();
    if (!mounted) return;
    setState(() { _loading = false;
      if (r.ok) _data = r.data; else _error = r.error; });
  }

  Future<void> _act(String id, bool approve, bool isAgent) async {
    setState(() => _busy.add(id));
    final r = isAgent
        ? (approve ? await AgencyApi.instance.approveAgent(id)
                   : await AgencyApi.instance.rejectAgent(id))
        : (approve ? await AgencyApi.instance.approveHost(id)
                   : await AgencyApi.instance.rejectHost(id));
    if (!mounted) return;
    setState(() => _busy.remove(id));
    if (r.ok) { _load(); _snack(approve ? '✅ Approved' : '❌ Rejected'); }
    else _snack(r.error ?? 'Error');
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
        backgroundColor: _kPurple));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingPane();
    if (_error != null) return ErrorPane(message: _error!, onRetry: _load);

    final agents = (_data!['agents'] as List).cast<Map<String, dynamic>>();
    final hosts  = (_data!['hosts']  as List).cast<Map<String, dynamic>>();

    if (agents.isEmpty && hosts.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: const [
        Text('🎉', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text('No pending applications',
            style: TextStyle(color: Color(0xFF888899), fontSize: 15)),
      ]));
    }

    return RefreshIndicator(
      onRefresh: _load, color: _kPurple, backgroundColor: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (agents.isNotEmpty) ...[
            const SectionHeader(title: '🤝 Agent Applications'),
            ...agents.map((a) => _AppCard(
              id: a['id'] as String, username: a['username'] as String,
              email: a['email'] as String, badge: 'Code: ${a['invite_code']}',
              busy: _busy.contains(a['id']),
              onApprove: () => _act(a['id'] as String, true, true),
              onReject:  () => _act(a['id'] as String, false, true))),
          ],
          if (hosts.isNotEmpty) ...[
            const SectionHeader(title: '🎙 Host Applications'),
            ...hosts.map((h) => _AppCard(
              id: h['id'] as String, username: h['username'] as String,
              email: h['email'] as String, badge: '',
              busy: _busy.contains(h['id']),
              onApprove: () => _act(h['id'] as String, true, false),
              onReject:  () => _act(h['id'] as String, false, false))),
          ],
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String id, username, email, badge;
  final bool busy;
  final VoidCallback onApprove, onReject;
  const _AppCard({required this.id, required this.username, required this.email,
      required this.badge, required this.busy,
      required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 20,
              backgroundColor: _kPurple.withValues(alpha: 0.10),
              child: Text(username[0].toUpperCase(),
                  style: const TextStyle(color: _kPurple,
                      fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(username, style: const TextStyle(color: _kText,
                fontWeight: FontWeight.bold, fontSize: 14)),
            Text(email, style: const TextStyle(color: _kSub, fontSize: 12)),
          ])),
          const StatusBadge('pending'),
        ]),
        if (badge.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(badge, style: const TextStyle(color: _kSub, fontSize: 11)),
        ],
        const SizedBox(height: 14),
        busy
            ? const Center(child: SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(color: _kPurple, strokeWidth: 2)))
            : Row(children: [
                Expanded(child: _Btn(label: 'Reject',
                    color: const Color(0xFFDC2626), onTap: onReject)),
                const SizedBox(width: 10),
                Expanded(child: _Btn(label: 'Approve',
                    gradient: const [_kPurple, Color(0xFFD946EF)],
                    onTap: onApprove)),
              ]),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color? color;
  final List<Color>? gradient;
  final VoidCallback onTap;
  const _Btn({required this.label, this.color, this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: gradient == null ? color!.withValues(alpha: 0.08) : null,
          gradient: gradient != null ? LinearGradient(colors: gradient!) : null,
          borderRadius: BorderRadius.circular(10),
          border: gradient == null
              ? Border.all(color: color!.withValues(alpha: 0.3)) : null,
        ),
        child: Center(child: Text(label, style: TextStyle(
            color: gradient != null ? Colors.white : color,
            fontWeight: FontWeight.bold, fontSize: 13))),
      ),
    );
  }
}
