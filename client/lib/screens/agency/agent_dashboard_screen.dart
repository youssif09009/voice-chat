import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../services/agency_api.dart';
import 'auth_screen.dart';
import 'income_screen.dart';
import 'widgets/agency_widgets.dart';

// White theme palette
const _kPurple = AppColors.primaryPurple;
const _kCyan   = Color(0xFF06B6D4);
const _kText   = Color(0xFF1A1A2E);
const _kSub    = Color(0xFF888899);
const _kBorder = Color(0xFFEEEEF5);
const _kSurf   = Color(0xFFF7F7FB);

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});
  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = AgencyApi.instance.username ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: AppColors.background,
        title: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _kCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handshake_rounded, color: _kCyan, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Agent Dashboard',
                style: TextStyle(color: _kText, fontSize: 15,
                    fontWeight: FontWeight.bold)),
            if (username.isNotEmpty)
              Text(username,
                  style: const TextStyle(color: _kSub, fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.gold, size: 22),
            tooltip: 'Income',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const IncomeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: _kSub, size: 20),
            onPressed: () {
              AgencyApi.instance.clearSession();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => AgencyAuthScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _kCyan,
          labelColor: _kText,
          unselectedLabelColor: _kSub,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: _kBorder,
          tabs: const [
            Tab(text: '📊 Overview'),
            Tab(text: '🎯 Targets'),
            Tab(text: '💰 Earnings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _AgentOverviewTab(),
          _AgentTargetsTab(),
          _AgentEarningsTab(),
        ],
      ),
    );
  }
}

// ── Overview ──────────────────────────────────────────────────────────────────

class _AgentOverviewTab extends StatefulWidget {
  const _AgentOverviewTab();
  @override
  State<_AgentOverviewTab> createState() => _AgentOverviewTabState();
}

class _AgentOverviewTabState extends State<_AgentOverviewTab> {
  Map<String, dynamic>? _data;
  String? _inviteLink;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final results = await Future.wait([
      AgencyApi.instance.getAgentDashboard(),
      AgencyApi.instance.getInviteCode(),
    ]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (results[0].ok) {
        _data = results[0].data;
        _inviteLink = results[1].data?['inviteLink'] as String?;
      } else { _error = results[0].error; }
    });
  }

  void _copyLink() {
    if (_inviteLink == null) return;
    Clipboard.setData(ClipboardData(text: _inviteLink!));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Invite link copied!'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingPane();
    if (_error != null) return ErrorPane(message: _error!, onRetry: _load);

    final agent   = _data!['agent'] as Map<String, dynamic>;
    final monthly = (_data!['monthlyEarnings'] as num).toDouble();
    final invitees = (_data!['recentInvitees'] as List)
        .cast<Map<String, dynamic>>();

    return RefreshIndicator(
      onRefresh: _load, color: _kCyan, backgroundColor: AppColors.background,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        // Invite code card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kCyan.withValues(alpha: 0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🔗', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text('Your Invite Code',
                  style: TextStyle(color: _kSub, fontSize: 12)),
              const Spacer(),
              StatusBadge(agent['status'] as String),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Text(agent['inviteCode'] as String,
                  style: const TextStyle(color: _kText, fontSize: 24,
                      fontWeight: FontWeight.bold, letterSpacing: 4))),
              GestureDetector(
                onTap: _copyLink,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kCyan.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kCyan.withValues(alpha: 0.35)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.copy_rounded, color: _kCyan, size: 14),
                    SizedBox(width: 6),
                    Text('Copy', style: TextStyle(color: _kCyan,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ]),
            if (_inviteLink != null) ...[
              const SizedBox(height: 6),
              Text(_inviteLink!, style: const TextStyle(color: _kSub, fontSize: 10),
                  overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Stats grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            StatCard(label: 'Total Invites',
                value: '${agent['totalInvites']}',
                icon: Icons.people_rounded, color: _kCyan),
            StatCard(label: 'Active Users',
                value: '${agent['activeInvites']}',
                icon: Icons.person_rounded, color: Colors.green),
            StatCard(label: 'Total Earnings',
                value: '🪙 ${(agent['totalEarnings'] as num).toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.gold),
            StatCard(label: 'This Month',
                value: '🪙 ${monthly.toStringAsFixed(0)}',
                icon: Icons.calendar_month_rounded, color: _kPurple),
          ],
        ),
        const SizedBox(height: 16),

        // Commission rate
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            const Text('💸', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Commission Rate',
                  style: TextStyle(color: _kSub, fontSize: 12)),
              Text(
                '${((agent['commissionRate'] as num) * 100).toStringAsFixed(0)}% on invited users\' gifts',
                style: const TextStyle(color: _kText, fontSize: 14,
                    fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),

        // Recent invitees
        if (invitees.isNotEmpty) ...[
          const SectionHeader(title: '👥 Recent Invitees'),
          ...invitees.map((u) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              CircleAvatar(radius: 16,
                  backgroundColor: _kCyan.withValues(alpha: 0.12),
                  child: Text((u['username'] as String)[0].toUpperCase(),
                      style: const TextStyle(color: _kCyan,
                          fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(width: 10),
              Text(u['username'] as String,
                  style: const TextStyle(color: _kText, fontSize: 13)),
            ]),
          )),
        ],
      ]),
    );
  }
}

// ── Targets ───────────────────────────────────────────────────────────────────

class _AgentTargetsTab extends StatefulWidget {
  const _AgentTargetsTab();
  @override
  State<_AgentTargetsTab> createState() => _AgentTargetsTabState();
}

class _AgentTargetsTabState extends State<_AgentTargetsTab> {
  List<Map<String, dynamic>> _targets = [];
  String _period = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getAgentTargets();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) {
        _period  = r.data!['period'] as String;
        _targets = (r.data!['targets'] as List).cast<Map<String, dynamic>>();
      } else { _error = r.error; }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingPane();
    if (_error != null) return ErrorPane(message: _error!, onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load, color: _kCyan, backgroundColor: AppColors.background,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const Text('🎯', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          const Text('Monthly Targets', style: TextStyle(color: _kText,
              fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kSurf,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(_period,
                style: const TextStyle(color: _kSub, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 16),
        ..._targets.map((t) => TargetRow(
          metric:   t['metric'] as String,
          current:  (t['current'] as num).toDouble(),
          goal:     (t['goal'] as num).toDouble(),
          progress: (t['progress'] as num).toInt(),
          color:    _kCyan,
        )),
      ]),
    );
  }
}

// ── Earnings ──────────────────────────────────────────────────────────────────

class _AgentEarningsTab extends StatefulWidget {
  const _AgentEarningsTab();
  @override
  State<_AgentEarningsTab> createState() => _AgentEarningsTabState();
}

class _AgentEarningsTabState extends State<_AgentEarningsTab> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getAgentEarnings();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) _rows = (r.data!['rows'] as List).cast<Map<String, dynamic>>();
      else _error = r.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingPane();
    if (_error != null) return ErrorPane(message: _error!, onRetry: _load);

    if (_rows.isEmpty) {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🪙', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No earnings yet', style: TextStyle(color: _kSub, fontSize: 15)),
          SizedBox(height: 6),
          Text('Share your invite code to start earning',
              style: TextStyle(color: _kSub, fontSize: 12)),
        ],
      ));
    }

    return RefreshIndicator(
      onRefresh: _load, color: _kCyan, backgroundColor: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rows.length,
        itemBuilder: (_, i) => _EarningRow(row: _rows[i]),
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final Map<String, dynamic> row;
  const _EarningRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final amount = (row['amount'] as num).toDouble();
    final ts = DateTime.fromMillisecondsSinceEpoch(
        ((row['created_at'] as num).toInt()) * 1000);
    final dateStr = '${ts.day}/${ts.month}/${ts.year}  '
        '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}';

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
        Container(width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('🪙', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Agent Commission', style: TextStyle(color: _kText,
              fontSize: 13, fontWeight: FontWeight.w600)),
          Text(dateStr, style: const TextStyle(color: _kSub, fontSize: 11)),
        ])),
        Text('+${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.green,
                fontSize: 15, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
