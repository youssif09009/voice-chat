import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../payment_screen.dart';
import '../sub_agency_screen.dart';
import '../agency_main_screen.dart';
import '../agency_income_screen.dart';
import '../ranking_screen.dart';
import '../widgets/agency_widgets.dart';

const _kPurple = AppColors.primaryPurple;
const _kText   = AppColors.textPrimary;
const _kSub    = AppColors.textSecondary;
const _kBorder = AppColors.border;

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});
  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  Map<String, dynamic>? _d;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getAnalytics();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) _d = r.data; else _error = r.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingPane();
    if (_error != null) return ErrorPane(message: _error!, onRetry: _load);

    final users    = _d!['users']    as Map<String, dynamic>;
    final agents   = _d!['agents']   as Map<String, dynamic>;
    final hosts    = _d!['hosts']    as Map<String, dynamic>;
    final gifts    = _d!['gifts']    as Map<String, dynamic>;
    final earnings = _d!['earnings'] as Map<String, dynamic>;
    final monthly  = _d!['monthly']  as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: _load,
      color: _kPurple,
      backgroundColor: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if ((agents['pending'] as int) > 0 || (hosts['pending'] as int) > 0)
            _AlertBanner(
                '${agents['pending']} agent + ${hosts['pending']} host application(s) awaiting approval'),

          const SectionHeader(title: 'Platform Overview'),
          _StatsGrid(users: users, agents: agents, hosts: hosts, gifts: gifts),

          const SizedBox(height: 16),
          _EarningsBanner(value: (earnings['total'] as num).toDouble()),

          const SectionHeader(title: 'This Month'),
          _MonthlyGrid(monthly: monthly),

          const SectionHeader(title: 'Quick Actions'),
          _QuickActionsGrid(),
        ],
      ),
    );
  }
}

// ── Alert banner ──────────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final String message;
  const _AlertBanner(this.message);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.notifications_rounded,
            color: AppColors.amber, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.amber))),
      ]),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> users, agents, hosts, gifts;
  const _StatsGrid({required this.users, required this.agents,
      required this.hosts, required this.gifts});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        StatCard(label: 'Total Users',
            value: '${users['total']}',
            icon: Icons.people_rounded, color: _kPurple,
            subtitle: '+${users['newLast7Days']} this week'),
        StatCard(label: 'Active Agents',
            value: '${agents['active']}',
            icon: Icons.handshake_rounded, color: const Color(0xFF06B6D4),
            subtitle: '${agents['pending']} pending'),
        StatCard(label: 'Active Hosts',
            value: '${hosts['active']}',
            icon: Icons.mic_rounded, color: const Color(0xFFD946EF),
            subtitle: '${hosts['pending']} pending'),
        StatCard(label: 'Gift Volume',
            value: '${(gifts['volume'] as num).toStringAsFixed(0)}',
            icon: Icons.card_giftcard_rounded, color: AppColors.gold,
            subtitle: '${gifts['count']} gifts'),
      ],
    );
  }
}

// ── Earnings banner ───────────────────────────────────────────────────────────

class _EarningsBanner extends StatelessWidget {
  final double value;
  const _EarningsBanner({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFD946EF)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
          blurRadius: 16, offset: const Offset(0, 6),
        )],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Platform Earnings',
              style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          Text('🪙 ${value.toStringAsFixed(0)} coins',
              style: AppTypography.h1.copyWith(color: Colors.white)),
        ]),
      ]),
    );
  }
}

// ── Monthly grid ──────────────────────────────────────────────────────────────

class _MonthlyGrid extends StatelessWidget {
  final Map<String, dynamic> monthly;
  const _MonthlyGrid({required this.monthly});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _MetricTile(label: 'Host Earnings',
            value: '🪙 ${(monthly['hostEarnings'] as num).toStringAsFixed(0)}',
            color: const Color(0xFFD946EF)),
        _MetricTile(label: 'Agent Earnings',
            value: '🪙 ${(monthly['agentEarnings'] as num).toStringAsFixed(0)}',
            color: const Color(0xFF06B6D4)),
        _MetricTile(label: 'Monthly Gifts',
            value: '${monthly['giftsCount']} gifts',
            color: AppColors.gold),
        _MetricTile(label: 'Gift Volume',
            value: '🪙 ${(monthly['giftsVolume'] as num).toStringAsFixed(0)}',
            color: _kPurple),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MetricTile({required this.label, required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 6),
        Text(value,
            style: AppTypography.labelMedium.copyWith(color: color)),
      ]),
    );
  }
}

// ── Quick actions grid ────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('💎', 'Buy Jewels',   'Top up balance',
          const Color(0xFF06B6D4), () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PaymentScreen()))),
      _Action('👥', 'Sub-Agency',   'Manage sub-agents',
          const Color(0xFFD946EF), () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SubAgencyScreen()))),
      _Action('🏢', 'Agency',       'Manage agency',
          const Color(0xFF5B5BD6), () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AgencyMainScreen()))),
      _Action('💰', 'My Income',    'Earnings & rewards',
          AppColors.gold, () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AgencyIncomeScreen()))),
      _Action('🏆', 'Rankings',     'Agency leaderboard',
          const Color(0xFFFF6B35), () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RankingScreen()))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) => _ActionCard(action: actions[i]),
    );
  }
}

class _Action {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _Action(this.emoji, this.title, this.subtitle, this.color, this.onTap);
}

class _ActionCard extends StatelessWidget {
  final _Action action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(
            color: action.color.withValues(alpha: 0.07),
            blurRadius: 8, offset: const Offset(0, 3),
          )],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(action.emoji,
                  style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(height: 8),
            Text(action.title,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(action.subtitle,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
