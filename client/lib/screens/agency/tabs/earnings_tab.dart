import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../widgets/agency_widgets.dart';

class EarningsTab extends StatefulWidget {
  const EarningsTab({super.key});
  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  Map<String, dynamic>? _d;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getEarningsBreakdown();
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

    final byType    = (_d!['byType']    as List).cast<Map<String, dynamic>>();
    final topHosts  = (_d!['topHosts']  as List).cast<Map<String, dynamic>>();
    final topAgents = (_d!['topAgents'] as List).cast<Map<String, dynamic>>();
    final daily     = (_d!['daily']     as List).cast<Map<String, dynamic>>();
    final period    = _d!['period'] as String;

    double hostTotal = 0, agentTotal = 0;
    for (final t in byType) {
      if (t['type'] == 'host_commission')  hostTotal  = (t['total'] as num).toDouble();
      if (t['type'] == 'agent_commission') agentTotal = (t['total'] as num).toDouble();
    }
    final grand = hostTotal + agentTotal;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primaryPurple,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GrandTotal(value: grand),
          const SizedBox(height: 12),
          _SplitRow(hostTotal: hostTotal, agentTotal: agentTotal, grand: grand),
          if (daily.isNotEmpty) ...[
            const SectionHeader(title: '📈 Last 7 Days'),
            _DailyChart(daily: daily),
            const SizedBox(height: 16),
          ],
          SectionHeader(title: '🎙 Top Hosts — $period'),
          ..._buildLeaderboard(topHosts, 'monthly_earnings', 'earned', 'hours', 'room time'),
          const SizedBox(height: 16),
          SectionHeader(title: '🤝 Top Agents — $period'),
          ..._buildLeaderboard(topAgents, 'monthly_earnings', 'earned', 'total_invites', 'invites'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildLeaderboard(List<Map<String, dynamic>> items,
      String pk, String pl, String sk, String sl) {
    return [
      for (int i = 0; i < items.length; i++)
        LeaderboardRow(
          rank: i + 1,
          username: items[i]['username'] as String,
          primaryValue: '🪙 ${(items[i][pk] as num).toStringAsFixed(0)}',
          primaryLabel: pl,
          secondaryValue: '${items[i][sk]}',
          secondaryLabel: sl,
        ),
    ];
  }
}

// ── Grand total banner ────────────────────────────────────────────────────────

class _GrandTotal extends StatelessWidget {
  final double value;
  const _GrandTotal({required this.value});

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
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('💰', style: TextStyle(fontSize: 24))),
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

// ── Split row ─────────────────────────────────────────────────────────────────

class _SplitRow extends StatelessWidget {
  final double hostTotal, agentTotal, grand;
  const _SplitRow({required this.hostTotal, required this.agentTotal,
      required this.grand});

  @override
  Widget build(BuildContext context) {
    final hPct = grand > 0 ? (hostTotal  / grand * 100).round() : 0;
    final aPct = grand > 0 ? (agentTotal / grand * 100).round() : 0;
    return Row(children: [
      Expanded(child: _SplitCard(
          label: 'Host Commissions', value: hostTotal,
          color: AppColors.pink, icon: Icons.mic_rounded, pct: hPct)),
      const SizedBox(width: 12),
      Expanded(child: _SplitCard(
          label: 'Agent Commissions', value: agentTotal,
          color: AppColors.cyan, icon: Icons.handshake_rounded, pct: aPct)),
    ]);
  }
}

class _SplitCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final int pct;
  const _SplitCard({required this.label, required this.value,
      required this.color, required this.icon, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const Spacer(),
          Text('$pct%', style: AppTypography.labelSmall.copyWith(
              color: color, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text('🪙 ${value.toStringAsFixed(0)}',
            style: AppTypography.labelLarge.copyWith(color: color)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100, minHeight: 5,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}

// ── Daily chart ───────────────────────────────────────────────────────────────

class _DailyChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily;
  const _DailyChart({required this.daily});

  @override
  Widget build(BuildContext context) {
    final maxVal = daily.fold<double>(0, (m, r) =>
        ((r['host_earnings'] as num) + (r['agent_earnings'] as num))
            .toDouble().clamp(m, double.infinity));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: daily.map((row) {
        final total = (row['host_earnings'] as num).toDouble() +
            (row['agent_earnings'] as num).toDouble();
        final barW = maxVal > 0 ? (total / maxVal) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 76,
                child: Text(row['day'] as String, style: AppTypography.caption)),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: barW.toDouble(), minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryPurple),
              ),
            )),
            const SizedBox(width: 10),
            Text('🪙${total.toStringAsFixed(0)}',
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        );
      }).toList()),
    );
  }
}
