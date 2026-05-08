import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/agency_api.dart';
import 'income_screen.dart';
import 'admin_dashboard_screen.dart';

/// Top-level shell with a bottom navigation bar.
/// Tab 0 → Income (home)
/// Tab 1 → Agency Dashboard
class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _current;

  static const _pages = [
    _IncomeShellPage(),
    _DashboardShellPage(),
  ];

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _current, children: _pages),
      bottomNavigationBar: _BottomBar(
        current: _current,
        onTap: (i) => setState(() => _current = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                current: current,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet_rounded,
                label: 'Income',
                activeColor: AppColors.gold,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                current: current,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                activeColor: AppColors.primaryPurple,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index, current;
  final IconData icon, activeIcon;
  final String label;
  final Color activeColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.white38,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page wrappers
// ─────────────────────────────────────────────────────────────────────────────

class _IncomeShellPage extends StatelessWidget {
  const _IncomeShellPage();
  @override
  Widget build(BuildContext context) => const IncomeShellContent();
}

class _DashboardShellPage extends StatelessWidget {
  const _DashboardShellPage();
  @override
  Widget build(BuildContext context) => const AdminDashboardScreen();
}

// ─────────────────────────────────────────────────────────────────────────────
// Income shell — natural home-screen style
// ─────────────────────────────────────────────────────────────────────────────

class IncomeShellContent extends StatefulWidget {
  const IncomeShellContent({super.key});
  @override
  State<IncomeShellContent> createState() => _IncomeShellContentState();
}

class _IncomeShellContentState extends State<IncomeShellContent>
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
    final username = AgencyApi.instance.username ?? 'Agent';
    final initial  = username.isNotEmpty ? username[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: _IncomeProfileHeader(
              username: username,
              initial: initial,
              onWithdraw: () => _showWithdrawSheet(context),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabDelegate(
              TabBar(
                controller: _tabs,
                indicatorColor: AppColors.primaryPurple,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: '💰 Overview'),
                  Tab(text: '🎁 Bonuses'),
                  Tab(text: '📋 History'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: const [
            IncomeOverviewContent(),
            IncomeBonusesContent(),
            IncomeHistoryContent(),
          ],
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const IncomeWithdrawSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Income profile header
// ─────────────────────────────────────────────────────────────────────────────

class _IncomeProfileHeader extends StatelessWidget {
  final String username, initial;
  final VoidCallback onWithdraw;
  const _IncomeProfileHeader({
    required this.username,
    required this.initial,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0840), Color(0xFF0F0F1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryPurple, Color(0xFFD946EF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $username 👋',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('Your income overview',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12)),
              ],
            ),
          ),
          // Withdraw button
          GestureDetector(
            onTap: onWithdraw,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, Color(0xFFD946EF)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.send_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text('Withdraw',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        // Balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D1B69), Color(0xFF1A0840)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.35)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Balance',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            const SizedBox(height: 6),
            const Text('🪙 12,450',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text('Diamonds',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            const SizedBox(height: 16),
            Row(children: [
              _MiniStat('Withdrawable', '8,200', Colors.greenAccent),
              _StatDivider(),
              _MiniStat('Frozen', '1,050', AppColors.gold),
              _StatDivider(),
              _MiniStat('Settling', '3,200', const Color(0xFF06B6D4)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text('🪙 $value',
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
      ]),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.1));
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sticky tab delegate (used by both Income and Dashboard)
// ─────────────────────────────────────────────────────────────────────────────

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabDelegate(this.tabBar);

  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabDelegate old) => old.tabBar != tabBar;
}
