import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../services/agency_api.dart';
import 'auth_screen.dart';
import 'widgets/agency_widgets.dart';

const _kPink   = Color(0xFFD946EF);
const _kPurple = AppColors.primaryPurple;
const _kText   = Color(0xFF1A1A2E);
const _kSub    = Color(0xFF888899);
const _kBorder = Color(0xFFEEEEF5);

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});
  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
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
              color: _kPink.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mic_rounded, color: _kPink, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Host Dashboard', style: TextStyle(color: _kText,
                fontSize: 15, fontWeight: FontWeight.bold)),
            Text(AgencyApi.instance.username ?? '',
                style: const TextStyle(color: _kSub, fontSize: 11)),
          ]),
        ]),
        actions: [
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
          indicatorColor: _kPink,
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
          _HostOverviewTab(),
          _HostTargetsTab(),
          _HostEarningsTab(),
        ],
      ),
    );
  }
}

// ── Overview ──────────────────────────────────────────────────────────────────

class _HostOverviewTab extends StatefulWidget {
  const _HostOverviewTab();
  @override
  State<_HostOverviewTab> createState() => _HostOverviewTabState();
}

class _HostOverviewTabState extends State<_HostOverviewTab> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getHostDashboard();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) _data = r.data; else _error = r.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingPane();
    if (_error != null) return ErrorPane(message: _error!, onRetry: _load);

    final host    = _data!['host']    as Map<String, dynamic>;
    final stats   = _data!['stats']   as Map<String, dynamic>;
    final rank    = (_data!['rank']   as num).toInt();
    final targets = (_data!['targets'] as List? ?? []).cast<Map<String, dynamic>>();

    return RefreshIndicator(
      onRefresh: _load, color: _kPink, backgroundColor: AppColors.background,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        // Rank banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Text(rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '🎙',
                style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rank #$rank', style: const TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Among all active hosts',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12)),
            ])),
            StatusBadge(host['status'] as String),
          ]),
        ),
        const SizedBox(height: 16),

        // Stats grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35,
          children: [
            StatCard(label: 'Room Hours',
                value: '${host['totalRoomTimeHours']}h',
                icon: Icons.timer_rounded, color: _kPink),
            StatCard(label: 'Gifts Received',
                value: '${host['totalGiftsCount']}',
                icon: Icons.card_giftcard_rounded, color: AppColors.gold,
                subtitle: '🪙 ${(host['totalGiftsVolume'] as num).toStringAsFixed(0)}'),
            StatCard(label: 'Total Earnings',
                value: '🪙 ${(host['totalEarnings'] as num).toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_rounded, color: Colors.green),
            StatCard(label: 'Commission',
                value: '${((host['commissionRate'] as num) * 100).toStringAsFixed(0)}%',
                icon: Icons.percent_rounded, color: _kPurple,
                subtitle: 'per gift'),
          ],
        ),
        const SizedBox(height: 16),

        // Period stats
        const SectionHeader(title: '📈 Period Stats'),
        Row(children: [
          Expanded(child: _PeriodCard(
            label: "Today's Gifts",
            value: '${stats['dailyGiftsCount']} gifts',
            sub: '🪙 ${(stats['dailyGiftsTotal'] as num).toStringAsFixed(0)}',
            color: AppColors.gold,
          )),
          const SizedBox(width: 12),
          Expanded(child: _PeriodCard(
            label: 'This Week',
            value: '🪙 ${(stats['weeklyEarnings'] as num).toStringAsFixed(0)}',
            sub: 'earnings',
            color: _kPink,
          )),
        ]),
        const SizedBox(height: 12),
        _PeriodCard(
          label: 'This Month',
          value: '🪙 ${(stats['monthlyEarnings'] as num).toStringAsFixed(0)} coins',
          sub: 'total monthly earnings',
          color: _kPurple,
          wide: true,
        ),

        if (targets.isNotEmpty) ...[
          const SectionHeader(title: '🎯 Monthly Targets'),
          ...targets.map((t) => TargetRow(
            metric:   t['metric'] as String,
            current:  (t['current'] as num).toDouble(),
            goal:     (t['goal'] as num).toDouble(),
            progress: (t['progress'] as num).toInt(),
            color:    _kPink,
          )),
        ],
      ]),
    );
  }
}

// ── Targets ───────────────────────────────────────────────────────────────────

class _HostTargetsTab extends StatefulWidget {
  const _HostTargetsTab();
  @override
  State<_HostTargetsTab> createState() => _HostTargetsTabState();
}

class _HostTargetsTabState extends State<_HostTargetsTab> {
  List<Map<String, dynamic>> _targets = [];
  String _period = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getHostTargets();
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

    final avgProgress = _targets.isEmpty ? 0
        : (_targets.map((t) => (t['progress'] as num).toInt())
                .reduce((a, b) => a + b) / _targets.length).round();

    return RefreshIndicator(
      onRefresh: _load, color: _kPink, backgroundColor: AppColors.background,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const Text('🎯', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Text('Monthly Targets', style: TextStyle(color: _kText,
              fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(_period, style: const TextStyle(color: _kSub, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 12),

        // Overall progress
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kPink.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            SizedBox(width: 64, height: 64,
              child: Stack(fit: StackFit.expand, children: [
                CircularProgressIndicator(
                  value: avgProgress / 100, strokeWidth: 6,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(
                      avgProgress >= 100 ? Colors.green : _kPink),
                ),
                Center(child: Text('$avgProgress%',
                    style: const TextStyle(color: _kText, fontSize: 13,
                        fontWeight: FontWeight.bold))),
              ]),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Overall Completion', style: TextStyle(color: _kText,
                  fontSize: 14, fontWeight: FontWeight.bold)),
              Text('${_targets.length} active targets',
                  style: const TextStyle(color: _kSub, fontSize: 12)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        ..._targets.map((t) => TargetRow(
          metric:   t['metric'] as String,
          current:  (t['current'] as num).toDouble(),
          goal:     (t['goal'] as num).toDouble(),
          progress: (t['progress'] as num).toInt(),
          color:    _kPink,
        )),
      ]),
    );
  }
}

// ── Earnings ──────────────────────────────────────────────────────────────────

class _HostEarningsTab extends StatefulWidget {
  const _HostEarningsTab();
  @override
  State<_HostEarningsTab> createState() => _HostEarningsTabState();
}

class _HostEarningsTabState extends State<_HostEarningsTab> {
  List<Map<String, dynamic>> _rows = [];
  Map<String, dynamic>? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getHostEarnings();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) {
        _rows    = (r.data!['rows'] as List).cast<Map<String, dynamic>>();
        _summary = r.data!['summary'] as Map<String, dynamic>?;
      } else { _error = r.error; }
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
          Text('🎙', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No earnings yet', style: TextStyle(color: _kSub, fontSize: 15)),
          SizedBox(height: 6),
          Text('Go live and receive gifts to start earning',
              style: TextStyle(color: _kSub, fontSize: 12)),
        ],
      ));
    }

    return RefreshIndicator(
      onRefresh: _load, color: _kPink, backgroundColor: AppColors.background,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        if (_summary != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: _SummaryItem(label: 'Total Earned',
                  value: '🪙 ${(_summary!['total_earned'] as num).toStringAsFixed(2)}',
                  color: Colors.white)),
              Container(width: 1, height: 36,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(child: _SummaryItem(label: 'Gift Volume',
                  value: '🪙 ${(_summary!['total_gifts_volume'] as num).toStringAsFixed(0)}',
                  color: Colors.white)),
              Container(width: 1, height: 36,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(child: _SummaryItem(label: 'Transactions',
                  value: '${(_summary!['total_transactions'] as num).toInt()}',
                  color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 16),
        ],
        ..._rows.map((row) => _EarningRow(row: row)),
      ]),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 13,
        fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(
        color: color.withValues(alpha: 0.75), fontSize: 10)),
  ]);
}

class _EarningRow extends StatelessWidget {
  final Map<String, dynamic> row;
  const _EarningRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final amount     = (row['amount'] as num).toDouble();
    final giftAmount = (row['gift_amount'] as num?)?.toDouble();
    final sender     = row['sender_username'] as String? ?? '—';
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
        Container(width: 42, height: 42,
          decoration: BoxDecoration(
            color: _kPink.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('🎁', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gift from $sender', style: const TextStyle(color: _kText,
              fontSize: 13, fontWeight: FontWeight.w600)),
          Text(giftAmount != null
              ? 'Gift: 🪙${giftAmount.toStringAsFixed(0)}  •  $dateStr'
              : dateStr,
              style: const TextStyle(color: _kSub, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('+${amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green,
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const Text('coins', style: TextStyle(color: _kSub, fontSize: 10)),
        ]),
      ]),
    );
  }
}

// ── Period card ───────────────────────────────────────────────────────────────

class _PeriodCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final bool wide;
  const _PeriodCard({required this.label, required this.value,
      required this.sub, required this.color, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: wide
          ? Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_month_rounded, color: color, size: 20)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(color: _kSub, fontSize: 11)),
                Text(value, style: const TextStyle(color: _kText,
                    fontSize: 18, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: _kSub, fontSize: 11)),
              ]),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: _kSub, fontSize: 11)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: _kText,
                  fontSize: 16, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(color: _kSub, fontSize: 11)),
            ]),
    );
  }
}
