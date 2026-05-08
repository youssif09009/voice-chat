
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../services/agency_api.dart';
import '../widgets/agency_widgets.dart';
import 'tab_helpers.dart';

const _kPink   = Color(0xFFD946EF);
const _kText   = Color(0xFF1A1A2E);
const _kSub    = Color(0xFF888899);
const _kBorder = Color(0xFFEEEEF5);

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
                onRefresh: _load, color: AppColors.primaryPurple,
                backgroundColor: AppColors.background,
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
    final d      = widget.data;
    final targets= (d['targets'] as List? ?? []).cast<Map<String, dynamic>>();
    final monthly= (d['monthly_earnings'] as num).toDouble();
    final weekly = (d['weekly_earnings']  as num).toDouble();
    final hours  = (d['total_hours'] as num).toDouble();
    final comm   = ((d['commission_rate'] as num) * 100).toStringAsFixed(0);
    final mGifts = (d['monthly_gifts_count'] as num).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(radius: 20,
                  backgroundColor: _kPink.withValues(alpha: 0.12),
                  child: Text((d['username'] as String)[0].toUpperCase(),
                      style: const TextStyle(color: _kPink,
                          fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['username'] as String, style: const TextStyle(
                    color: _kText, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(d['email'] as String,
                    style: const TextStyle(color: _kSub, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                StatusBadge(d['status'] as String),
                const SizedBox(height: 4),
                Text('$comm% comm.',
                    style: const TextStyle(color: _kSub, fontSize: 10)),
              ]),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textHint, size: 20),
            ]),
          ),
        ),
        QuickStatsRow(items: [
          QuickStatItem('Hours', '${hours}h', _kPink),
          QuickStatItem('Gifts/mo', '$mGifts', AppColors.gold),
          QuickStatItem('Monthly', '🪙${monthly.toStringAsFixed(0)}',
              Colors.green),
          QuickStatItem('Weekly', '🪙${weekly.toStringAsFixed(0)}',
              AppColors.primaryPurple),
        ]),
        if (_expanded && targets.isNotEmpty) ...[
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(children: [
              const Text('🎯 Targets', style: TextStyle(
                  color: _kText, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Text(widget.period,
                  style: const TextStyle(color: _kSub, fontSize: 11)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(children: targets.map((t) => TargetRow(
              metric:   t['metric'] as String,
              current:  (t['current'] as num).toDouble(),
              goal:     (t['goal'] as num).toDouble(),
              progress: (t['progress'] as num).toInt(),
              color:    _kPink,
            )).toList()),
          ),
        ],
        if (_expanded) ...[
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(child: Column(children: [
                Text('🪙${(d['total_earnings'] as num).toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.gold,
                        fontSize: 13, fontWeight: FontWeight.bold)),
                const Text('All-time Earnings',
                    style: TextStyle(color: _kSub, fontSize: 10)),
              ])),
              Expanded(child: Column(children: [
                Text('🪙${(d['total_gifts'] as num).toStringAsFixed(0)}',
                    style: const TextStyle(color: _kSub,
                        fontSize: 13, fontWeight: FontWeight.bold)),
                const Text('Gift Volume',
                    style: TextStyle(color: _kSub, fontSize: 10)),
              ])),
            ]),
          ),
        ],
      ]),
    );
  }
}
