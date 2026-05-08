import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../widgets/agency_widgets.dart';

const _kPurple = AppColors.primaryPurple;
const _kText   = AppColors.textPrimary;
const _kSub    = AppColors.textSecondary;
const _kBorder = AppColors.border;

enum _TargetType { invite, diamondEarning, activeHours, giftSending, rechargeVolume }
enum _Tier { none, bronze, silver, gold, platinum }

class _AgentProgress {
  final String agentName;
  final double current;
  bool claimed;
  _AgentProgress({required this.agentName, required this.current, this.claimed = false});
}

class _Target {
  final String id, deadline, assignedTo;
  final _TargetType type;
  final double goal;
  final Map<_Tier, double> tierRewards;
  final List<_AgentProgress> agentProgress;
  const _Target({required this.id, required this.type, required this.goal,
      required this.deadline, required this.assignedTo,
      required this.tierRewards, required this.agentProgress});
  _Tier tierFor(double c) {
    final p = goal > 0 ? (c / goal * 100).clamp(0, 100) : 0;
    if (p >= 100) return _Tier.platinum;
    if (p >= 75)  return _Tier.gold;
    if (p >= 50)  return _Tier.silver;
    if (p >= 25)  return _Tier.bronze;
    return _Tier.none;
  }
  int get completedCount => agentProgress.where((a) => a.current >= goal).length;
}

final _fakeTargets = <_Target>[
  _Target(id: 't1', type: _TargetType.invite, goal: 50, deadline: '31 May 2026',
      assignedTo: 'All Agents',
      tierRewards: {_Tier.bronze: 100, _Tier.silver: 250, _Tier.gold: 500, _Tier.platinum: 1000},
      agentProgress: [
        _AgentProgress(agentName: 'Alice', current: 50),
        _AgentProgress(agentName: 'Bob', current: 38),
        _AgentProgress(agentName: 'youssif1', current: 21),
        _AgentProgress(agentName: 'Ahmed_Pro', current: 47)]),
  _Target(id: 't2', type: _TargetType.diamondEarning, goal: 10000, deadline: '31 May 2026',
      assignedTo: 'All Agents',
      tierRewards: {_Tier.bronze: 200, _Tier.silver: 500, _Tier.gold: 1000, _Tier.platinum: 2000},
      agentProgress: [
        _AgentProgress(agentName: 'Alice', current: 10000, claimed: true),
        _AgentProgress(agentName: 'Bob', current: 7200),
        _AgentProgress(agentName: 'youssif1', current: 4550),
        _AgentProgress(agentName: 'Ahmed_Pro', current: 9100)]),
  _Target(id: 't3', type: _TargetType.activeHours, goal: 100, deadline: '31 May 2026',
      assignedTo: 'youssif1',
      tierRewards: {_Tier.bronze: 150, _Tier.silver: 300, _Tier.gold: 600, _Tier.platinum: 1200},
      agentProgress: [_AgentProgress(agentName: 'youssif1', current: 2)]),
];

final _leaderboard = [
  {'name': 'Alice',     'completed': 3, 'diamonds': 3100.0},
  {'name': 'Ahmed_Pro', 'completed': 2, 'diamonds': 1500.0},
  {'name': 'Bob',       'completed': 2, 'diamonds': 1200.0},
  {'name': 'youssif1',  'completed': 0, 'diamonds': 0.0},
];

String _typeLabel(_TargetType t) {
  switch (t) {
    case _TargetType.invite:          return 'Invites';
    case _TargetType.diamondEarning:  return 'Diamond Earning';
    case _TargetType.activeHours:     return 'Active Hours';
    case _TargetType.giftSending:     return 'Gifts Sent';
    case _TargetType.rechargeVolume:  return 'Recharge Volume';
  }
}
String _typeIcon(_TargetType t) {
  switch (t) {
    case _TargetType.invite:          return '\u{1F465}';
    case _TargetType.diamondEarning:  return '\u{1FAA9}';
    case _TargetType.activeHours:     return '\u23F1\uFE0F';
    case _TargetType.giftSending:     return '\u{1F381}';
    case _TargetType.rechargeVolume:  return '\u{1F4B3}';
  }
}
Color _tierColor(_Tier t) {
  switch (t) {
    case _Tier.none:     return const Color(0xFFCCCCDD);
    case _Tier.bronze:   return const Color(0xFFCD7F32);
    case _Tier.silver:   return const Color(0xFFC0C0C0);
    case _Tier.gold:     return const Color(0xFFFFD700);
    case _Tier.platinum: return const Color(0xFF8B5CF6);
  }
}
// ── Root widget ──────────────────────────────────────────────────────────────

class TargetsTab extends StatefulWidget {
  const TargetsTab({super.key});
  @override
  State<TargetsTab> createState() => _TargetsTabState();
}

class _TargetsTabState extends State<TargetsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _inner;
  final List<_Target> _targets = List.from(_fakeTargets);

  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _inner.dispose(); super.dispose(); }

  void _deleteTarget(String id) =>
      setState(() => _targets.removeWhere((t) => t.id == id));
  void _addTarget(_Target t) => setState(() => _targets.insert(0, t));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: AppColors.background,
        child: TabBar(
          controller: _inner,
          indicatorColor: _kPurple,
          labelColor: _kText,
          unselectedLabelColor: _kSub,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: _kBorder,
          tabs: const [Tab(text: 'Targets'), Tab(text: 'Leaderboard')],
        ),
      ),
      Expanded(
        child: TabBarView(controller: _inner, children: [
          _TargetsListView(
            targets: _targets,
            onDelete: _deleteTarget,
            onAdd: () => _showCreateSheet(context),
          ),
          const _LeaderboardView(),
        ]),
      ),
    ]);
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateTargetSheet(onCreated: _addTarget),
    );
  }
}

// ── Targets list ──────────────────────────────────────────────────────────────

class _TargetsListView extends StatelessWidget {
  final List<_Target> targets;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;
  const _TargetsListView({required this.targets, required this.onDelete, required this.onAdd});

  int get _totalCompleted => targets.fold(0, (s, t) => s + t.completedCount);
  int get _totalAgents {
    final n = <String>{};
    for (final t in targets) for (final a in t.agentProgress) n.add(a.agentName);
    return n.length;
  }
  int get _unclaimed => targets.fold(0, (s, t) => s +
      t.agentProgress.where((a) => a.current >= t.goal && !a.claimed).length);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: _kPurple,
      backgroundColor: AppColors.background,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
          children: [
            StatCard(label: 'Active Targets', value: '${targets.length}',
                icon: Icons.flag_rounded, color: _kPurple),
            StatCard(label: 'Agents Assigned', value: '$_totalAgents',
                icon: Icons.people_rounded, color: const Color(0xFF06B6D4)),
            StatCard(label: 'Completed', value: '$_totalCompleted',
                icon: Icons.check_circle_rounded, color: Colors.green),
            StatCard(label: 'Unclaimed', value: '$_unclaimed',
                icon: Icons.card_giftcard_rounded, color: AppColors.gold),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_kPurple, Color(0xFFD946EF)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(
                  color: _kPurple.withValues(alpha: 0.25),
                  blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('New Target', style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
        const SectionHeader(title: 'All Targets'),
        if (targets.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(children: [
              Text('No targets yet.',
                  style: TextStyle(color: _kSub, fontSize: 13)),
            ]),
          ))
        else
          ...targets.map((t) => _TargetCard(
              target: t, onDelete: () => _confirmDelete(context, t))),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, _Target t) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Target',
          style: TextStyle(color: _kText, fontSize: 16, fontWeight: FontWeight.bold)),
      content: Text('Delete the "${_typeLabel(t.type)}" target? This cannot be undone.',
          style: const TextStyle(color: _kSub, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kSub))),
        ElevatedButton(
          onPressed: () { Navigator.pop(ctx); onDelete(t.id); },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text('Delete')),
      ],
    ));
  }
}

// ── Target card ───────────────────────────────────────────────────────────────

class _TargetCard extends StatefulWidget {
  final _Target target;
  final VoidCallback onDelete;
  const _TargetCard({required this.target, required this.onDelete});
  @override
  State<_TargetCard> createState() => _TargetCardState();
}

class _TargetCardState extends State<_TargetCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.target;
    final highestTier = t.agentProgress.fold<_Tier>(_Tier.none, (best, a) {
      final tier = t.tierFor(a.current);
      return tier.index > best.index ? tier : best;
    });
    final tc = _tierColor(highestTier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: highestTier == _Tier.none ? _kBorder : tc.withValues(alpha: 0.35)),
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
              Container(width: 44, height: 44,
                decoration: BoxDecoration(
                    color: _kPurple.withValues(alpha: 0.08),
                    shape: BoxShape.circle),
                child: Center(child: Text(_typeIcon(t.type),
                    style: const TextStyle(fontSize: 20)))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_typeLabel(t.type), style: const TextStyle(
                    color: _kText, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Goal: ${t.goal.toStringAsFixed(0)}  Due: ${t.deadline}',
                    style: const TextStyle(color: _kSub, fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: tc.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tc.withValues(alpha: 0.35))),
                child: Text(highestTier.name.toUpperCase(),
                    style: TextStyle(color: tc, fontSize: 9,
                        fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textHint, size: 20),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(children: [
            Expanded(child: Column(children: [
              Text(t.assignedTo, style: const TextStyle(
                  color: Color(0xFF06B6D4), fontSize: 12,
                  fontWeight: FontWeight.bold)),
              const Text('Assigned', style: TextStyle(color: _kSub, fontSize: 10)),
            ])),
            Expanded(child: Column(children: [
              Text('${t.completedCount}/${t.agentProgress.length}',
                  style: const TextStyle(color: Colors.green, fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const Text('Completed', style: TextStyle(color: _kSub, fontSize: 10)),
            ])),
            Expanded(child: Column(children: [
              Text('🪙${t.tierRewards[_Tier.platinum]!.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.gold, fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const Text('Top Reward', style: TextStyle(color: _kSub, fontSize: 10)),
            ])),
          ]),
        ),
        if (_expanded) ...[
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: const Text('Agent Progress', style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ...t.agentProgress.map((a) {
            final pct = t.goal > 0
                ? (a.current / t.goal * 100).clamp(0, 100).round() : 0;
            final tier = t.tierFor(a.current);
            final tc2 = _tierColor(tier);
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(radius: 14,
                      backgroundColor: _kPurple.withValues(alpha: 0.10),
                      child: Text(a.agentName[0].toUpperCase(),
                          style: const TextStyle(color: _kPurple,
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a.agentName,
                      style: const TextStyle(color: _kText, fontSize: 13,
                          fontWeight: FontWeight.w500))),
                  Text('${a.current.toStringAsFixed(0)}/${t.goal.toStringAsFixed(0)}',
                      style: const TextStyle(color: _kSub, fontSize: 11)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100, minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        a.current >= t.goal ? Colors.green : tc2)),
                ),
                const SizedBox(height: 3),
                Text(
                  a.current >= t.goal
                      ? (a.claimed ? 'Claimed' : 'Ready to Claim')
                      : '$pct% complete',
                  style: TextStyle(
                      color: a.current >= t.goal
                          ? (a.claimed ? Colors.green : AppColors.gold) : _kSub,
                      fontSize: 10)),
              ]),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.4))),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626), size: 16),
                    SizedBox(width: 6),
                    Text('Delete Target', style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Leaderboard ───────────────────────────────────────────────────────────────

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SectionHeader(title: 'Target Completion Leaderboard'),
      const Text('Ranked by targets completed this month',
          style: TextStyle(color: _kSub, fontSize: 12)),
      const SizedBox(height: 16),
      ..._leaderboard.asMap().entries.map((e) => LeaderboardRow(
        rank: e.key + 1,
        username: e.value['name'] as String,
        primaryValue: '${e.value["completed"]} targets',
        primaryLabel: 'completed',
        secondaryValue: '🪙${(e.value["diamonds"] as double).toStringAsFixed(0)}',
        secondaryLabel: 'earned',
      )),
      const SectionHeader(title: 'Tier System'),
      ...const [
        (_Tier.bronze,   '1-25%',   'Bronze',   'Small reward'),
        (_Tier.silver,   '26-50%',  'Silver',   'Medium reward'),
        (_Tier.gold,     '51-75%',  'Gold',     'Large reward'),
        (_Tier.platinum, '76-100%', 'Platinum', 'Maximum reward'),
      ].map((r) => _TierRow(tier: r.$1, range: r.$2, label: r.$3, desc: r.$4)),
    ]);
  }
}

class _TierRow extends StatelessWidget {
  final _Tier tier;
  final String range, label, desc;
  const _TierRow({required this.tier, required this.range,
      required this.label, required this.desc});
  @override
  Widget build(BuildContext context) {
    final c = _tierColor(tier);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
              color: c.withValues(alpha: 0.10), shape: BoxShape.circle),
          child: Center(child: Text(label[0],
              style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: c,
              fontWeight: FontWeight.bold, fontSize: 13)),
          Text(desc, style: const TextStyle(color: _kSub, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: c.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.withValues(alpha: 0.3))),
          child: Text(range, style: TextStyle(color: c, fontSize: 11,
              fontWeight: FontWeight.bold))),
      ]),
    );
  }
}

// ── Create target sheet ───────────────────────────────────────────────────────

class _CreateTargetSheet extends StatefulWidget {
  final ValueChanged<_Target> onCreated;
  const _CreateTargetSheet({required this.onCreated});
  @override
  State<_CreateTargetSheet> createState() => _CreateTargetSheetState();
}

class _CreateTargetSheetState extends State<_CreateTargetSheet> {
  _TargetType _type = _TargetType.invite;
  final _goalCtrl     = TextEditingController();
  final _deadlineCtrl = TextEditingController(text: '31 May 2026');
  final _assignCtrl   = TextEditingController(text: 'All Agents');
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _goalCtrl.dispose(); _deadlineCtrl.dispose(); _assignCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final goal = double.tryParse(_goalCtrl.text.trim());
    if (goal == null || goal <= 0) {
      setState(() => _error = 'Enter a valid goal'); return;
    }
    setState(() { _saving = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.onCreated(_Target(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      type: _type, goal: goal,
      deadline: _deadlineCtrl.text.trim(),
      assignedTo: _assignCtrl.text.trim(),
      tierRewards: {_Tier.bronze: 100, _Tier.silver: 250,
          _Tier.gold: 500, _Tier.platinum: 1000},
      agentProgress: [],
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _kBorder,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('New Target', style: TextStyle(color: _kText,
              fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.4))),
              child: Text(_error!, style: const TextStyle(
                  color: Color(0xFFDC2626), fontSize: 13))),
            const SizedBox(height: 12),
          ],
          const Text('Type', style: TextStyle(color: _kSub, fontSize: 12,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: _TargetType.values.map((t) {
              final sel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? _kPurple : const Color(0xFFF7F7FB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel ? _kPurple : _kBorder)),
                  child: Text(_typeLabel(t), style: TextStyle(
                      color: sel ? Colors.white : _kSub,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal))));
            }).toList()),
          const SizedBox(height: 16),
          const Text('Goal', style: TextStyle(color: _kSub, fontSize: 12,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _SheetField(ctrl: _goalCtrl, hint: 'e.g. 50',
              keyboard: TextInputType.number),
          const SizedBox(height: 14),
          const Text('Deadline', style: TextStyle(color: _kSub, fontSize: 12,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _SheetField(ctrl: _deadlineCtrl, hint: 'e.g. 31 May 2026'),
          const SizedBox(height: 14),
          const Text('Assign To', style: TextStyle(color: _kSub, fontSize: 12,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _SheetField(ctrl: _assignCtrl, hint: 'All Agents or name'),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple, foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26))),
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Create Target', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)))),
        ],
      )),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType keyboard;
  const _SheetField({required this.ctrl, required this.hint,
      this.keyboard = TextInputType.text});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, keyboardType: keyboard,
    style: const TextStyle(color: _kText, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kSub, fontSize: 14),
      filled: true, fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPurple, width: 1.5))));
}
