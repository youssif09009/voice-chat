import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../widgets/agency_widgets.dart';
import 'tab_helpers.dart';

class HostsTab extends StatefulWidget {
  const HostsTab({super.key});
  @override
  State<HostsTab> createState() => _HostsTabState();
}

class _HostsTabState extends State<HostsTab> {
  List<Map<String, dynamic>> _rows = [];
  String? _period;
  bool _loading = true;
  String? _error;
  String? _filter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.getAdminHostsList(status: _filter);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.ok) {
        _rows   = (r.data!['rows'] as List).cast<Map<String, dynamic>>();
        _period = r.data!['period'] as String?;
      } else { _error = r.error; }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TabFilterBar(
        options: const [null, 'active', 'pending', 'suspended'],
        labels:  const ['All', 'Active', 'Pending', 'Suspended'],
        selected: _filter,
        onSelect: (v) { setState(() => _filter = v); _load(); },
      ),
      Expanded(
        child: _loading ? const LoadingPane()
            : _error != null ? ErrorPane(message: _error!, onRetry: _load)
            : _rows.isEmpty ? const TabEmpty(label: 'No hosts found')
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.primaryPurple,
                backgroundColor: AppColors.surface,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rows.length,
                  itemBuilder: (_, i) =>
                      HostCard(data: _rows[i], period: _period ?? ''),
                ),
              ),
      ),
    ]);
  }
}

class HostCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String period;
  const HostCard({super.key, required this.data, required this.period});
  @override
  State<HostCard> createState() => _HostCardState();
}

class _HostCardState extends State<HostCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d       = widget.data;
    final targets = (d['targets'] as List? ?? []).cast<Map<String, dynamic>>();
    final monthly = (d['monthly_earnings'] as num).toDouble();
    final weekly  = (d['weekly_earnings']  as num).toDouble();
    final hours   = (d['total_hours'] as num).toDouble();
    final comm    = ((d['commission_rate'] as num) * 100).toStringAsFixed(0);
    final mGifts  = (d['monthly_gifts_count'] as num).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.pink.withValues(alpha: 0.15),
                child: Text(
                  (d['username'] as String)[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['username'] as String, style: AppTypography.labelMedium),
                const SizedBox(height: 2),
                Text(d['email'] as String, style: AppTypography.caption),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                StatusBadge(d['status'] as String),
                const SizedBox(height: 4),
                Text('$comm% comm.', style: AppTypography.caption),
              ]),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textHint, size: 20),
            ]),
          ),
        ),
        QuickStatsRow(items: [
          QuickStatItem('Hours',    '${hours.toStringAsFixed(1)}h',    AppColors.pink),
          QuickStatItem('Gifts/mo', '$mGifts',                         AppColors.gold),
          QuickStatItem('Monthly',  '🪙${monthly.toStringAsFixed(0)}', AppColors.green),
          QuickStatItem('Weekly',   '🪙${weekly.toStringAsFixed(0)}',  AppColors.primaryPurple),
        ]),
        if (_expanded && targets.isNotEmpty) ...[
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(children: [
              Text('🎯 Targets', style: AppTypography.h3),
              const Spacer(),
              Text(widget.period, style: AppTypography.caption),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(children: targets.map((t) => TargetRow(
              metric:   t['metric'] as String,
              current:  (t['current'] as num).toDouble(),
              goal:     (t['goal'] as num).toDouble(),
              progress: (t['progress'] as num).toInt(),
              color:    AppColors.pink,
            )).toList()),
          ),
        ],
        if (_expanded) ...[
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(child: Column(children: [
                Text(
                  '🪙${(d['total_earnings'] as num).toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text('All-time Earnings', style: AppTypography.caption),
              ])),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(child: Column(children: [
                Text(
                  '🪙${(d['total_gifts'] as num).toStringAsFixed(0)}',
                  style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text('Gift Volume', style: AppTypography.caption),
              ])),
            ]),
          ),
        ],
      ]),
    );
  }
}
