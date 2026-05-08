
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../services/agency_api.dart';
import 'auth_screen.dart';
import 'payment_screen.dart';
import 'sub_agency_screen.dart';
import 'agency_main_screen.dart';
import 'agency_income_screen.dart';
import 'agency_host_management_screen.dart';
import 'ranking_screen.dart';
import 'create_agency_screen.dart';
import 'tabs/overview_tab.dart';
import 'tabs/applications_tab.dart';
import 'tabs/agents_tab.dart';
import 'tabs/hosts_tab.dart';
import 'tabs/earnings_tab.dart';
import 'tabs/users_tab.dart';
import 'tabs/targets_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colours
// ─────────────────────────────────────────────────────────────────────────────
const _kPink   = Color(0xFFD946EF);
const _kCyan   = Color(0xFF06B6D4);
const _kPurple = AppColors.primaryPurple;
const _kBlue   = Color(0xFF5B5BD6);

// ─────────────────────────────────────────────────────────────────────────────
// AdminDashboardScreen — now the "Profile" tab
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _mgmtTabs;
  Map<String, dynamic>? _analytics;

  static const _mgmtLabels = [
    '🏠 Overview', '📋 Apply', '🤝 Agents',
    '🎙 Hosts',    '💰 Earn',  '👥 Users', '🎯 Goals',
  ];

  @override
  void initState() {
    super.initState();
    _mgmtTabs = TabController(length: 7, vsync: this);
    _mgmtTabs.addListener(() => setState(() {}));
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final r = await AgencyApi.instance.getAnalytics();
    if (!mounted) return;
    if (r.ok) setState(() => _analytics = r.data);
  }

  @override
  void dispose() {
    _mgmtTabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = AgencyApi.instance.username ?? 'Admin';
    final initial  = username.isNotEmpty ? username[0].toUpperCase() : 'A';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                username: username,
                initial: initial,
                analytics: _analytics,
                onPayment:   () => _push(ctx, const PaymentScreen()),
                onSubAgency: () => _push(ctx, const SubAgencyScreen()),
                onLogout: () {
                  AgencyApi.instance.clearSession();
                  Navigator.pushReplacement(
                    ctx, MaterialPageRoute(builder: (_) => AgencyAuthScreen()));
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _FeatureRow(
                onAgency:       () => _push(ctx, const AgencyMainScreen()),
                onIncome:       () => _push(ctx, const AgencyIncomeScreen()),
                onRanking:      () => _push(ctx, const RankingScreen()),
                onHostMgmt:     () => _push(ctx, const AgencyHostManagementScreen()),
                onCreateAgency: () => _push(ctx, const CreateAgencyScreen()),
              ),
            ),
            const SliverToBoxAdapter(child: _SectionDivider(label: 'Management')),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PillTabDelegate(
                labels: _mgmtLabels,
                controller: _mgmtTabs,
              ),
            ),
          ],
          body: TabBarView(
            controller: _mgmtTabs,
            children: const [
              OverviewTab(),
              ApplicationsTab(),
              AgentsTab(),
              HostsTab(),
              EarningsTab(),
              UsersTab(),
              TargetsTab(),
            ],
          ),
        ),
      ),
    );
  }

  static void _push(BuildContext ctx, Widget page) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile header  (cover art + avatar card + stats + quick actions)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String username, initial;
  final Map<String, dynamic>? analytics;
  final VoidCallback onPayment, onSubAgency, onLogout;

  const _ProfileHeader({
    required this.username,
    required this.initial,
    required this.analytics,
    required this.onPayment,
    required this.onSubAgency,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CoverArt(),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16, right: 16,
          child: Row(children: [
            _Chip(
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shield_rounded, color: _kPurple, size: 13),
                SizedBox(width: 5),
                Text('Agency',
                    style: TextStyle(color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            const Spacer(),
            _CoverBtn(icon: Icons.diamond_rounded,   color: _kCyan,        onTap: onPayment),
            const SizedBox(width: 8),
            _CoverBtn(icon: Icons.group_add_rounded, color: _kPink,        onTap: onSubAgency),
            const SizedBox(width: 8),
            _CoverBtn(icon: Icons.logout_rounded,    color: Colors.white54, onTap: onLogout),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 108),
          child: _ProfileCard(
            username: username,
            initial: initial,
            analytics: analytics,
            onPayment: onPayment,
            onSubAgency: onSubAgency,
          ),
        ),
      ],
    );
  }
}

// ── Cover art ─────────────────────────────────────────────────────────────────

class _CoverArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D0B6B), Color(0xFF0F0F1E), Color(0xFF1A0840)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(top: -30, right: -30,
            child: _Circle(160, _kPurple, 0.18)),
        Positioned(bottom: -20, left: 40,
            child: _Circle(100, _kPink, 0.12)),
        Positioned(top: 20, left: -20,
            child: _Circle(80, _kCyan, 0.10)),
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent,
                  AppColors.background.withValues(alpha: 0.92)],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Circle(this.size, this.color, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

// ── Cover button ──────────────────────────────────────────────────────────────

class _CoverBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CoverBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: color, size: 16),
    ),
  );
}

class _Chip extends StatelessWidget {
  final Widget child;
  const _Chip({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: child,
  );
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String username, initial;
  final Map<String, dynamic>? analytics;
  final VoidCallback onPayment, onSubAgency;
  const _ProfileCard({
    required this.username, required this.initial,
    required this.analytics,
    required this.onPayment, required this.onSubAgency,
  });

  String _fmt(dynamic v) {
    if (v == null) return '—';
    final n = (v as num).toInt();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final users   = analytics?['users']   as Map<String, dynamic>?;
    final agents  = analytics?['agents']  as Map<String, dynamic>?;
    final hosts   = analytics?['hosts']   as Map<String, dynamic>?;
    final gifts   = analytics?['gifts']   as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        // ── Avatar + name ─────────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -28),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPurple, _kPink],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
                boxShadow: [BoxShadow(
                  color: _kPurple.withValues(alpha: 0.5),
                  blurRadius: 16, offset: const Offset(0, 4),
                )],
              ),
              child: Center(child: Text(initial,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(username, style: AppTypography.h1),
                  const SizedBox(height: 5),
                  Row(children: [
                    _Badge('👑 Admin', gradient: const [_kPurple, _kPink]),
                    const SizedBox(width: 6),
                    _Badge('● Online', color: AppColors.green, border: true),
                  ]),
                ]),
              ),
            ),
          ]),
        ),

        // ── Live stats row ────────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -10),
          child: Row(children: [
            _StatPill(_fmt(users?['total']),  'Users',   _kCyan),
            _VDivider(),
            _StatPill(_fmt(agents?['active']), 'Agents', _kPurple),
            _VDivider(),
            _StatPill(_fmt(hosts?['active']),  'Hosts',  _kPink),
            _VDivider(),
            _StatPill('🪙 ${_fmt(gifts?['volume'])}', 'Volume', AppColors.gold),
          ]),
        ),

        const SizedBox(height: 4),

        // ── Action buttons ────────────────────────────────────────────
        Row(children: [
          Expanded(child: _OutlineBtn('💎 Buy Jewels', _kCyan,  onPayment)),
          const SizedBox(width: 10),
          Expanded(child: _OutlineBtn('👥 Sub-Agency', _kPink, onSubAgency)),
        ]),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final List<Color>? gradient;
  final Color? color;
  final bool border;
  const _Badge(this.label, {this.gradient, this.color, this.border = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      gradient: gradient != null ? LinearGradient(colors: gradient!) : null,
      color: color != null && gradient == null
          ? color!.withValues(alpha: 0.12) : null,
      borderRadius: BorderRadius.circular(10),
      border: border && color != null
          ? Border.all(color: color!.withValues(alpha: 0.4)) : null,
    ),
    child: Text(label, style: TextStyle(
        color: gradient != null ? Colors.white : color,
        fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: AppTypography.labelMedium.copyWith(color: color)),
    const SizedBox(height: 3),
    Text(label, style: AppTypography.caption),
  ]));
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28,
          color: AppColors.border);
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn(this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Center(child: Text(label,
          style: AppTypography.buttonSmall.copyWith(color: color))),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature row  (5 Heylla feature cards)
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final VoidCallback onAgency, onIncome, onRanking, onHostMgmt, onCreateAgency;
  const _FeatureRow({
    required this.onAgency,
    required this.onIncome,
    required this.onRanking,
    required this.onHostMgmt,
    required this.onCreateAgency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Row 1 — 3 cards
        Row(children: [
          _FeatureCard(
            emoji: '🏢',
            label: 'Agency',
            sublabel: 'Manage',
            color: _kBlue,
            onTap: onAgency,
          ),
          const SizedBox(width: 10),
          _FeatureCard(
            emoji: '💰',
            label: 'My Income',
            sublabel: 'Earnings',
            color: AppColors.gold,
            onTap: onIncome,
          ),
          const SizedBox(width: 10),
          _FeatureCard(
            emoji: '🏆',
            label: 'Rankings',
            sublabel: 'Leaderboard',
            color: const Color(0xFFFF6B35),
            onTap: onRanking,
          ),
        ]),
        const SizedBox(height: 10),
        // Row 2 — 2 cards
        Row(children: [
          _FeatureCard(
            emoji: '🎙',
            label: 'Hosts',
            sublabel: 'Management',
            color: _kPink,
            onTap: onHostMgmt,
          ),
          const SizedBox(width: 10),
          _FeatureCard(
            emoji: '➕',
            label: 'New Agency',
            sublabel: 'Create',
            color: _kCyan,
            onTap: onCreateAgency,
          ),
          const SizedBox(width: 10),
          // Empty spacer to keep grid aligned
          const Expanded(child: SizedBox()),
        ]),
      ]),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji, label, sublabel;
  final Color color;
  final VoidCallback onTap;
  const _FeatureCard({
    required this.emoji, required this.label,
    required this.sublabel, required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 3),
            Text(sublabel, style: AppTypography.caption.copyWith(color: color),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section divider
// ─────────────────────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(children: [
        Text(label, style: AppTypography.h3),
        const SizedBox(width: 10),
        Expanded(child: Container(
            height: 1,
            color: AppColors.border)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────

class _PillTabDelegate extends SliverPersistentHeaderDelegate {
  final List<String> labels;
  final TabController controller;
  const _PillTabDelegate({required this.labels, required this.controller});

  @override double get minExtent => 52;
  @override double get maxExtent => 52;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) =>
      Container(
        color: AppColors.background,
        child: _PillTabRow(labels: labels, controller: controller),
      );

  @override
  bool shouldRebuild(_PillTabDelegate old) =>
      old.labels != labels || old.controller != controller;
}

class _PillTabRow extends StatefulWidget {
  final List<String> labels;
  final TabController controller;
  const _PillTabRow({required this.labels, required this.controller});
  @override
  State<_PillTabRow> createState() => _PillTabRowState();
}

class _PillTabRowState extends State<_PillTabRow> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }
  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.labels.length,
        itemBuilder: (_, i) {
          final active = widget.controller.index == i;
          return GestureDetector(
            onTap: () => widget.controller.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [_kPurple, _kPink])
                    : null,
                color: active ? null : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? Colors.transparent : AppColors.border,
                ),
                boxShadow: active ? [BoxShadow(
                  color: _kPurple.withValues(alpha: 0.4),
                  blurRadius: 8, offset: const Offset(0, 3),
                )] : null,
              ),
              child: Text(widget.labels[i], style: AppTypography.labelSmall.copyWith(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              )),
            ),
          );
        },
      ),
    );
  }
}
