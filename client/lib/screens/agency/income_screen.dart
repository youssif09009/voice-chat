
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import 'widgets/agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Static fake data — Heylla-style income system
// ─────────────────────────────────────────────────────────────────────────────

// Monthly income data
const _kCurrentMonth  = 'May 2026';
const _kPreviousMonth = 'Apr 2026';
const _kCurrentTotal  = 4_820.50;
const _kPreviousTotal = 3_210.00;
const _kTrendPct      = 50.2; // positive = up

// Balance breakdown
const _kTotalBalance      = 12_450.00;
const _kWithdrawable      = 8_200.00;
const _kFrozen            = 1_050.00;
const _kPendingSettlement = 3_200.00;

// Income sources (current month)
final _incomeSources = [
  _IncomeSource('Gift Commissions',   '🎁', 2_340.00, const Color(0xFFD946EF)),
  _IncomeSource('Invite Bonuses',     '👥', 1_200.00, const Color(0xFF06B6D4)),
  _IncomeSource('Sub-Agency Override','🤝',   780.50, AppColors.primaryPurple),
  _IncomeSource('Target Rewards',     '🎯',   500.00, AppColors.gold),
];

// Daily income last 7 days
final _dailyIncome = [
  _DailyEntry('Mon', 320.0),
  _DailyEntry('Tue', 580.0),
  _DailyEntry('Wed', 210.0),
  _DailyEntry('Thu', 940.0),
  _DailyEntry('Fri', 760.0),
  _DailyEntry('Sat', 1_100.0),
  _DailyEntry('Sun', 910.5),
];

// Bonus milestones
final _bonuses = [
  _Bonus('Invite 30 Users',    '👥', 30,  34,  500.0,  true,  false),
  _Bonus('Earn 10K Diamonds',  '🪙', 10000, 4820, 1000.0, false, false),
  _Bonus('5 Active Sub-Agents','🤝', 5,   3,   750.0,  false, false),
  _Bonus('Complete 3 Targets', '🎯', 3,   3,   600.0,  true,  true),
];

// Withdrawal history
final _withdrawals = [
  _Withdrawal('WD-0041', 1_000.0, 'Vodafone Cash', '01012345678', 'approved', DateTime(2026, 4, 28)),
  _Withdrawal('WD-0040',   500.0, 'InstaPay',       'user@bank',  'approved', DateTime(2026, 4, 15)),
  _Withdrawal('WD-0039',   200.0, 'Bank Transfer',  'IBAN-EG123', 'rejected', DateTime(2026, 4, 2)),
  _Withdrawal('WD-0038',   800.0, 'Vodafone Cash',  '01012345678','approved', DateTime(2026, 3, 20)),
];

// Transaction log
final _transactions = [
  _Transaction('Gift commission from Sara_Elite',  '🎁', 250.0,  DateTime(2026, 5, 6, 14, 32)),
  _Transaction('Invite bonus — 30 users reached',  '🎉', 500.0,  DateTime(2026, 5, 5, 9,  0)),
  _Transaction('Sub-agency override — Ahmed_Pro',  '🤝', 120.5,  DateTime(2026, 5, 4, 18, 45)),
  _Transaction('Gift commission from Karim_VIP',   '🎁', 180.0,  DateTime(2026, 5, 3, 11, 20)),
  _Transaction('Target reward — 3 targets done',   '🎯', 600.0,  DateTime(2026, 5, 2, 8,  0)),
  _Transaction('Gift commission from Nour_Star',   '🎁', 90.0,   DateTime(2026, 5, 1, 16, 10)),
  _Transaction('Withdrawal processed',             '💸', -1000.0,DateTime(2026, 4, 28, 10, 0)),
  _Transaction('Gift commission from Bob',         '🎁', 340.0,  DateTime(2026, 4, 27, 13, 55)),
];

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _IncomeSource {
  final String label, icon;
  final double amount;
  final Color color;
  const _IncomeSource(this.label, this.icon, this.amount, this.color);
}

class _DailyEntry {
  final String day;
  final double amount;
  const _DailyEntry(this.day, this.amount);
}

class _Bonus {
  final String label, icon;
  final int goal, current;
  final double reward;
  final bool met, claimed;
  const _Bonus(this.label, this.icon, this.goal, this.current,
      this.reward, this.met, this.claimed);
  int get pct => (current / goal * 100).clamp(0, 100).round();
}

class _Withdrawal {
  final String id, method, account, status;
  final double amount;
  final DateTime date;
  const _Withdrawal(this.id, this.amount, this.method, this.account,
      this.status, this.date);
}

class _Transaction {
  final String label, icon;
  final double amount;
  final DateTime date;
  const _Transaction(this.label, this.icon, this.amount, this.date);
}

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});
  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen>
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Income',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.gold, size: 22),
            tooltip: 'Withdraw',
            onPressed: () => _showWithdrawSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primaryPurple,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '💰 Overview'),
            Tab(text: '🎁 Bonuses'),
            Tab(text: '📋 History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _OverviewTab(),
          _BonusesTab(),
          IncomeHistoryContent(),
        ],
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
// TAB 1 — Overview
// ─────────────────────────────────────────────────────────────────────────────

/// Public alias so AppShell / IncomeShellContent can embed this tab directly.
class IncomeOverviewContent extends StatelessWidget {
  const IncomeOverviewContent({super.key});
  @override
  Widget build(BuildContext context) => const _OverviewTab();
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _BalanceCard(),
        SizedBox(height: 16),
        _MonthComparisonCard(),
        SizedBox(height: 16),
        _DailyChartCard(),
        SizedBox(height: 16),
        _IncomeSourcesCard(),
      ],
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF1A0840)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('💰', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('Total Balance',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                  const ClipboardData(text: '$_kTotalBalance'));
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4)),
              ),
              child: const Text('Withdraw',
                  style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const Text(
          '🪙 12,450',
          style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text('Diamonds',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        const SizedBox(height: 20),
        // Three balance sub-items
        Row(children: [
          _BalanceItem('Withdrawable', '🪙 8,200', Colors.greenAccent),
          _BalanceItem('Frozen',       '🪙 1,050', AppColors.gold),
          _BalanceItem('Settling',     '🪙 3,200', const Color(0xFF06B6D4)),
        ]),
      ]),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BalanceItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
      ]),
    );
  }
}

// ── Month comparison card ─────────────────────────────────────────────────────

class _MonthComparisonCard extends StatelessWidget {
  const _MonthComparisonCard();

  @override
  Widget build(BuildContext context) {
    final isUp = _kCurrentTotal >= _kPreviousTotal;
    final diff = (_kCurrentTotal - _kPreviousTotal).abs();
    final pct  = _kPreviousTotal > 0
        ? (diff / _kPreviousTotal * 100).toStringAsFixed(1)
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('📈', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          const Text('Monthly Income',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isUp ? Colors.greenAccent : AppColors.red)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                isUp
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isUp ? Colors.greenAccent : AppColors.red,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text('$pct%',
                  style: TextStyle(
                      color: isUp ? Colors.greenAccent : AppColors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _MonthBlock(_kCurrentMonth, _kCurrentTotal, true)),
          Container(
              width: 1, height: 50, color: Colors.white.withValues(alpha: 0.08)),
          Expanded(child: _MonthBlock(_kPreviousMonth, _kPreviousTotal, false)),
        ]),
      ]),
    );
  }
}

class _MonthBlock extends StatelessWidget {
  final String month;
  final double amount;
  final bool isCurrent;
  const _MonthBlock(this.month, this.amount, this.isCurrent);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(month,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
      const SizedBox(height: 6),
      Text('🪙 ${amount.toStringAsFixed(0)}',
          style: TextStyle(
              color: isCurrent ? Colors.white : Colors.white54,
              fontSize: isCurrent ? 20 : 16,
              fontWeight: FontWeight.bold)),
      if (isCurrent)
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('Current',
              style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ),
    ]);
  }
}

// ── Daily chart card ──────────────────────────────────────────────────────────

class _DailyChartCard extends StatelessWidget {
  const _DailyChartCard();

  @override
  Widget build(BuildContext context) {
    final maxVal = _dailyIncome.fold<double>(
        0, (m, e) => e.amount > m ? e.amount : m);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('📊', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          const Text('Last 7 Days',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const Spacer(),
          Text(
            'Total: 🪙${_dailyIncome.fold<double>(0, (s, e) => s + e.amount).toStringAsFixed(0)}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _dailyIncome.map((e) {
              final ratio = maxVal > 0 ? e.amount / maxVal : 0.0;
              final isMax = e.amount == maxVal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isMax)
                        Text(
                          '🪙${e.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: (ratio * 60).clamp(4, 60),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isMax
                                ? [AppColors.gold, AppColors.gold.withValues(alpha: 0.6)]
                                : [AppColors.primaryPurple, AppColors.primaryPurple.withValues(alpha: 0.5)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(e.day,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 9)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Income sources card ───────────────────────────────────────────────────────

class _IncomeSourcesCard extends StatelessWidget {
  const _IncomeSourcesCard();

  @override
  Widget build(BuildContext context) {
    final total = _incomeSources.fold<double>(0, (s, e) => s + e.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🔍', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          const Text('Income Sources',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const Spacer(),
          Text('This Month',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        ..._incomeSources.map((s) => _SourceRow(source: s, total: total)),
      ]),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final _IncomeSource source;
  final double total;
  const _SourceRow({required this.source, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? source.amount / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(source.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(source.label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          Text('🪙 ${source.amount.toStringAsFixed(0)}',
              style: TextStyle(
                  color: source.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.07),
            valueColor: AlwaysStoppedAnimation(source.color),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Bonuses
// ─────────────────────────────────────────────────────────────────────────────

/// Public alias so AppShell / IncomeShellContent can embed this tab directly.
class IncomeBonusesContent extends StatelessWidget {
  const IncomeBonusesContent({super.key});
  @override
  Widget build(BuildContext context) => const _BonusesTab();
}

class _BonusesTab extends StatefulWidget {
  const _BonusesTab();
  @override
  State<_BonusesTab> createState() => _BonusesTabState();
}

class _BonusesTabState extends State<_BonusesTab> {
  late final List<_BonusState> _states;

  @override
  void initState() {
    super.initState();
    _states = _bonuses
        .map((b) => _BonusState(bonus: b, claimed: b.claimed))
        .toList();
  }

  void _claim(int i) {
    setState(() => _states[i] = _BonusState(bonus: _states[i].bonus, claimed: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅  🪙${_states[i].bonus.reward.toStringAsFixed(0)} reward claimed!'),
        backgroundColor: Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalClaimed = _states
        .where((s) => s.claimed)
        .fold<double>(0, (sum, s) => sum + s.bonus.reward);
    final pendingCount = _states.where((s) => s.bonus.met && !s.claimed).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.gold.withValues(alpha: 0.15),
              AppColors.primaryPurple.withValues(alpha: 0.08),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bonus Rewards',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text('🪙 ${totalClaimed.toStringAsFixed(0)} claimed',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12)),
              ],
            )),
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$pendingCount to claim',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
          ]),
        ),
        const SizedBox(height: 16),

        const SectionHeader(title: '🎁 Your Bonuses'),
        ..._states.asMap().entries.map((e) => _BonusCard(
              state: e.value,
              onClaim: e.value.bonus.met && !e.value.claimed
                  ? () => _claim(e.key)
                  : null,
            )),
      ],
    );
  }
}

class _BonusState {
  final _Bonus bonus;
  final bool claimed;
  const _BonusState({required this.bonus, required this.claimed});
}

class _BonusCard extends StatelessWidget {
  final _BonusState state;
  final VoidCallback? onClaim;
  const _BonusCard({required this.state, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final b = state.bonus;
    final isComplete = b.met;
    final isClaimed  = state.claimed;
    final barColor   = isComplete ? Colors.greenAccent : AppColors.primaryPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? (isClaimed
                  ? Colors.greenAccent.withValues(alpha: 0.2)
                  : AppColors.gold.withValues(alpha: 0.4))
              : Colors.white.withValues(alpha: 0.07),
          width: isComplete && !isClaimed ? 1.5 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(b.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text('Reward: 🪙${b.reward.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11)),
            ],
          )),
          // Status badge
          if (isClaimed)
            _StatusPill('✅ Claimed', Colors.greenAccent)
          else if (isComplete)
            _StatusPill('🎁 Ready!', AppColors.gold)
          else
            _StatusPill('${b.pct}%', AppColors.primaryPurple),
        ]),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: b.pct / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.07),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Text('${b.current} / ${b.goal}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          const Spacer(),
          Text(
            isComplete ? 'Completed!' : '${b.goal - b.current} remaining',
            style: TextStyle(
                color: isComplete
                    ? Colors.greenAccent
                    : Colors.white.withValues(alpha: 0.3),
                fontSize: 11),
          ),
        ]),

        // Claim button
        if (isComplete && !isClaimed) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onClaim,
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.gold, Color(0xFFFF8C00)]),
                borderRadius: BorderRadius.circular(21),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('Claim Reward 🎁',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — History (transactions + withdrawals)
// ─────────────────────────────────────────────────────────────────────────────

/// Public alias so AppShell / IncomeShellContent can embed this tab directly.
class IncomeHistoryContent extends StatefulWidget {
  const IncomeHistoryContent({super.key});
  @override
  State<IncomeHistoryContent> createState() => _HistoryTabState();
}

// Private alias kept for backward compat inside this file.
// typedef removed — use IncomeHistoryContent directly.

class _HistoryTabState extends State<IncomeHistoryContent>
    with SingleTickerProviderStateMixin {
  late final TabController _inner;

  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: AppColors.background,
        child: TabBar(
          controller: _inner,
          indicatorColor: AppColors.primaryPurple,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: '📜 Transactions'),
            Tab(text: '💸 Withdrawals'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _inner,
          children: const [
            _TransactionList(),
            _WithdrawalList(),
          ],
        ),
      ),
    ]);
  }
}

// ── Transaction list ──────────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (_, i) => _TxRow(tx: _transactions[i]),
    );
  }
}

class _TxRow extends StatelessWidget {
  final _Transaction tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount >= 0;
    final color = isPositive ? Colors.greenAccent : AppColors.red;
    final dateStr =
        '${tx.date.day.toString().padLeft(2, '0')}/'
        '${tx.date.month.toString().padLeft(2, '0')}/'
        '${tx.date.year}  '
        '${tx.date.hour.toString().padLeft(2, '0')}:'
        '${tx.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(tx.icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(dateStr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 10)),
          ],
        )),
        Text(
          '${isPositive ? '+' : ''}${tx.amount.toStringAsFixed(0)}',
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }
}

// ── Withdrawal list ───────────────────────────────────────────────────────────

class _WithdrawalList extends StatelessWidget {
  const _WithdrawalList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _withdrawals.length,
      itemBuilder: (_, i) => _WdRow(wd: _withdrawals[i]),
    );
  }
}

class _WdRow extends StatelessWidget {
  final _Withdrawal wd;
  const _WdRow({required this.wd});

  Color get _statusColor {
    switch (wd.status) {
      case 'approved': return Colors.greenAccent;
      case 'rejected': return AppColors.red;
      default:         return AppColors.gold;
    }
  }

  IconData get _statusIcon {
    switch (wd.status) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default:         return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${wd.date.day.toString().padLeft(2, '0')}/'
        '${wd.date.month.toString().padLeft(2, '0')}/'
        '${wd.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_statusIcon, color: _statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wd.id,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            Text('${wd.method}  •  $dateStr',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🪙 ${wd.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: _statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(wd.status.toUpperCase(),
                style: TextStyle(
                    color: _statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdrawal bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

/// Public so IncomeShellContent can open it directly.
class IncomeWithdrawSheet extends StatefulWidget {
  const IncomeWithdrawSheet({super.key});
  @override
  State<IncomeWithdrawSheet> createState() => _WithdrawSheetState();
}

// Private alias kept for backward compat inside this file.
// typedef removed — use IncomeWithdrawSheet directly.

class _WithdrawSheetState extends State<IncomeWithdrawSheet> {
  final _amountCtrl  = TextEditingController();
  final _accountCtrl = TextEditingController();
  String _method     = 'vodafone_cash';
  String? _error;
  bool _submitted    = false;
  bool _loading      = false;

  static const _methods = [
    ('vodafone_cash', '📱 Vodafone Cash'),
    ('instapay',      '⚡ InstaPay'),
    ('bank',          '🏦 Bank Transfer'),
    ('usdt',          '₿  USDT'),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (amount < 50) {
      setState(() => _error = 'Minimum withdrawal is 🪙50');
      return;
    }
    if (amount > _kWithdrawable) {
      setState(() => _error = 'Exceeds withdrawable balance (🪙${_kWithdrawable.toStringAsFixed(0)})');
      return;
    }
    if (_accountCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Enter account details');
      return;
    }

    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() { _loading = false; _submitted = true; });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12112A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: _submitted ? _ConfirmationView() : _FormView(
          amountCtrl: _amountCtrl,
          accountCtrl: _accountCtrl,
          method: _method,
          error: _error,
          loading: _loading,
          onMethodChanged: (m) => setState(() => _method = m),
          onSubmit: _submit,
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController amountCtrl, accountCtrl;
  final String method;
  final String? error;
  final bool loading;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback onSubmit;

  const _FormView({
    required this.amountCtrl,
    required this.accountCtrl,
    required this.method,
    required this.error,
    required this.loading,
    required this.onMethodChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        const SizedBox(height: 20),

        const Text('Withdraw Income',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Available: 🪙${_kWithdrawable.toStringAsFixed(0)}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
        const SizedBox(height: 20),

        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
            ),
            child: Text(error!,
                style: const TextStyle(color: AppColors.red, fontSize: 13)),
          ),
          const SizedBox(height: 12),
        ],

        // Amount
        _SheetLabel('Amount (Diamonds)'),
        _SheetField(ctrl: amountCtrl, hint: 'Min 50', keyboard: TextInputType.number),
        const SizedBox(height: 14),

        // Method
        _SheetLabel('Payment Method'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _WithdrawSheetState._methods.map((m) {
            final sel = method == m.$1;
            return GestureDetector(
              onTap: () => onMethodChanged(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryPurple.withValues(alpha: 0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel
                        ? AppColors.primaryPurple
                        : Colors.white.withValues(alpha: 0.08),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(m.$2,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: sel
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Account details
        _SheetLabel('Account Details'),
        _SheetField(ctrl: accountCtrl, hint: 'Phone / IBAN / Wallet address'),
        const SizedBox(height: 24),

        // Submit
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: loading ? null : onSubmit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, Color(0xFFD946EF)]),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Submit Request',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Center(
              child: Icon(Icons.check_rounded,
                  color: Colors.greenAccent, size: 36)),
        ),
        const SizedBox(height: 16),
        const Text('Request Submitted!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Your withdrawal request is pending review.\nYou\'ll be notified once it\'s processed.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: Text('Close',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4)),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType keyboard;
  const _SheetField(
      {required this.ctrl,
      required this.hint,
      this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.07))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryPurple)),
      ),
    );
  }
}
