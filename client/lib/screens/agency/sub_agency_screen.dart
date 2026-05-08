import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import 'widgets/agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models (UI-only)
// ─────────────────────────────────────────────────────────────────────────────

class _SubAgent {
  final String id;
  final String name;
  final String inviteCode;
  final String status;
  final int totalInvites;
  final double earnings;
  final double commissionRate;
  final DateTime joinedAt;

  const _SubAgent({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.status,
    required this.totalInvites,
    required this.earnings,
    required this.commissionRate,
    required this.joinedAt,
  });
}

// Fake data
final _fakeSubAgents = [
  _SubAgent(
    id: 'sa1',
    name: 'Ahmed_Pro',
    inviteCode: 'AHM2024',
    status: 'active',
    totalInvites: 34,
    earnings: 1240.50,
    commissionRate: 0.08,
    joinedAt: DateTime(2026, 3, 10),
  ),
  _SubAgent(
    id: 'sa2',
    name: 'Sara_Elite',
    inviteCode: 'SAR8877',
    status: 'active',
    totalInvites: 21,
    earnings: 780.00,
    commissionRate: 0.08,
    joinedAt: DateTime(2026, 3, 22),
  ),
  _SubAgent(
    id: 'sa3',
    name: 'Karim_VIP',
    inviteCode: 'KRM5512',
    status: 'pending',
    totalInvites: 0,
    earnings: 0,
    commissionRate: 0.08,
    joinedAt: DateTime(2026, 4, 5),
  ),
  _SubAgent(
    id: 'sa4',
    name: 'Nour_Star',
    inviteCode: 'NUR3301',
    status: 'suspended',
    totalInvites: 8,
    earnings: 210.00,
    commissionRate: 0.05,
    joinedAt: DateTime(2026, 2, 14),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class SubAgencyScreen extends StatefulWidget {
  const SubAgencyScreen({super.key});

  @override
  State<SubAgencyScreen> createState() => _SubAgencyScreenState();
}

class _SubAgencyScreenState extends State<SubAgencyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final List<_SubAgent> _agents = List.from(_fakeSubAgents);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _addSubAgent(_SubAgent agent) {
    setState(() => _agents.insert(0, agent));
  }

  void _toggleStatus(String id) {
    setState(() {
      final idx = _agents.indexWhere((a) => a.id == id);
      if (idx == -1) return;
      final a = _agents[idx];
      final newStatus = a.status == 'active' ? 'suspended' : 'active';
      _agents[idx] = _SubAgent(
        id: a.id, name: a.name, inviteCode: a.inviteCode,
        status: newStatus, totalInvites: a.totalInvites,
        earnings: a.earnings, commissionRate: a.commissionRate,
        joinedAt: a.joinedAt,
      );
    });
  }

  void _deleteSubAgent(String id) {
    setState(() => _agents.removeWhere((a) => a.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings = _agents.fold<double>(0, (s, a) => s + a.earnings);
    final activeCount   = _agents.where((a) => a.status == 'active').length;

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
        title: const Text('Sub-Agency',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, Color(0xFFD946EF)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => _showAddSheet(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primaryPurple,
          labelColor: const Color(0xFF1A1A2E),
          unselectedLabelColor: const Color(0xFF888899),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '👥 Sub-Agents'),
            Tab(text: '📊 Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _SubAgentsList(
            agents: _agents,
            onToggle: _toggleStatus,
            onDelete: _deleteSubAgent,
          ),
          _SubAgencyOverview(
            agents: _agents,
            totalEarnings: totalEarnings,
            activeCount: activeCount,
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSubAgentSheet(onAdd: _addSubAgent),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Sub-agents list
// ─────────────────────────────────────────────────────────────────────────────

class _SubAgentsList extends StatelessWidget {
  final List<_SubAgent> agents;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  const _SubAgentsList({
    required this.agents,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (agents.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('👥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No sub-agents yet',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 15)),
          const SizedBox(height: 6),
          Text('Tap + to add your first sub-agent',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25), fontSize: 12)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agents.length,
      itemBuilder: (_, i) => _SubAgentCard(
        agent: agents[i],
        onToggle: () => onToggle(agents[i].id),
        onDelete: () => onDelete(agents[i].id),
      ),
    );
  }
}

class _SubAgentCard extends StatefulWidget {
  final _SubAgent agent;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubAgentCard({
    required this.agent,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_SubAgentCard> createState() => _SubAgentCardState();
}

class _SubAgentCardState extends State<_SubAgentCard> {
  bool _expanded = false;

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 22),
          SizedBox(width: 10),
          Text('Delete Sub-Agent',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nThis action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.agent;
    final isActive = a.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(children: [
        // ── Header ──────────────────────────────────────────────────────
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Avatar
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [const Color(0xFF06B6D4), AppColors.primaryPurple]
                        : [const Color(0xFFEEEEF5), const Color(0xFFDDDDEE)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(a.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text('Code: ${a.inviteCode}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          letterSpacing: 1)),
                ],
              )),
              StatusBadge(a.status),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textHint, size: 20),
            ]),
          ),
        ),

        // ── Quick stats ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(children: [
            _Stat(label: 'Invites', value: '${a.totalInvites}',
                color: const Color(0xFF06B6D4)),
            _Stat(label: 'Earnings', value: '🪙${a.earnings.toStringAsFixed(0)}',
                color: AppColors.gold),
            _Stat(label: 'Commission', value: '${(a.commissionRate * 100).toStringAsFixed(0)}%',
                color: AppColors.primaryPurple),
          ]),
        ),

        // ── Expanded details ─────────────────────────────────────────────
        if (_expanded) ...[
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              // Joined date
              Row(children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Joined ${a.joinedAt.day}/${a.joinedAt.month}/${a.joinedAt.year}',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12),
                ),
              ]),
              const SizedBox(height: 12),

              // Copy invite code
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: a.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite code copied!'),
                      backgroundColor: AppColors.background,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.copy_rounded,
                        color: AppColors.primaryPurple, size: 16),
                    const SizedBox(width: 8),
                    Text('Copy Invite Code: ${a.inviteCode}',
                        style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),

              // Toggle status button
              GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.red.withValues(alpha: 0.1)
                        : Colors.greenAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? AppColors.red.withValues(alpha: 0.3)
                          : Colors.greenAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isActive ? 'Suspend Sub-Agent' : 'Activate Sub-Agent',
                      style: TextStyle(
                        color: isActive ? AppColors.red : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Delete button
              GestureDetector(
                onTap: () => _confirmDelete(context, a.name),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          color: AppColors.red, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Delete Sub-Agent',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Overview
// ─────────────────────────────────────────────────────────────────────────────

class _SubAgencyOverview extends StatelessWidget {
  final List<_SubAgent> agents;
  final double totalEarnings;
  final int activeCount;

  const _SubAgencyOverview({
    required this.agents,
    required this.totalEarnings,
    required this.activeCount,
  });

  /// Builds top-3 leaderboard rows — extracted to avoid DDC cascade crash.
  List<Widget> _buildTopPerformers(List<_SubAgent> agents) {
    final active = agents.where((a) => a.status == 'active').toList();
    active.sort((a, b) => b.earnings.compareTo(a.earnings));
    final top = active.take(3).toList();
    final rows = <Widget>[];
    for (int i = 0; i < top.length; i++) {
      rows.add(LeaderboardRow(
        rank: i + 1,
        username: top[i].name,
        primaryValue: '🪙 ${top[i].earnings.toStringAsFixed(0)}',
        primaryLabel: 'earned',
        secondaryValue: '${top[i].totalInvites}',
        secondaryLabel: 'invites',
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final totalInvites = agents.fold<int>(0, (s, a) => s + a.totalInvites);
    final pending = agents.where((a) => a.status == 'pending').length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Earnings banner ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryPurple.withValues(alpha: 0.2),
              const Color(0xFFD946EF).withValues(alpha: 0.1),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Text('💰', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Sub-Agency Earnings',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12)),
              Text('🪙 ${totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Stats grid ───────────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            StatCard(
              label: 'Total Sub-Agents',
              value: '${agents.length}',
              icon: Icons.people_rounded,
              color: AppColors.primaryPurple,
            ),
            StatCard(
              label: 'Active',
              value: '$activeCount',
              icon: Icons.check_circle_rounded,
              color: Colors.greenAccent,
              subtitle: '$pending pending',
            ),
            StatCard(
              label: 'Total Invites',
              value: '$totalInvites',
              icon: Icons.person_add_rounded,
              color: const Color(0xFF06B6D4),
            ),
            StatCard(
              label: 'Avg Commission',
              value: '8%',
              icon: Icons.percent_rounded,
              color: AppColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Top performers ───────────────────────────────────────────────
        const SectionHeader(title: '🏆 Top Performers'),
        ..._buildTopPerformers(agents),

        const SizedBox(height: 20),

        // ── How sub-agency works ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️  How Sub-Agency Works',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(height: 10),
              ...[
                '• You invite sub-agents using your invite code',
                '• Sub-agents earn 8% commission on their invitees\' gifts',
                '• You earn an additional 2% from sub-agent activity',
                '• Sub-agents can invite users but not other sub-agents',
                '• You can suspend or activate sub-agents at any time',
              ].map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(s,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12)),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add sub-agent bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddSubAgentSheet extends StatefulWidget {
  final ValueChanged<_SubAgent> onAdd;
  const _AddSubAgentSheet({required this.onAdd});

  @override
  State<_AddSubAgentSheet> createState() => _AddSubAgentSheetState();
}

class _AddSubAgentSheetState extends State<_AddSubAgentSheet> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  double _commission = 0.08;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim().toUpperCase();

    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (code.length < 4) {
      setState(() => _error = 'Invite code must be at least 4 characters');
      return;
    }

    setState(() { _saving = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final newAgent = _SubAgent(
      id: 'sa_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      inviteCode: code,
      status: 'pending',
      totalInvites: 0,
      earnings: 0,
      commissionRate: _commission,
      joinedAt: DateTime.now(),
    );

    widget.onAdd(newAgent);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅  $name added as sub-agent'),
        backgroundColor: Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Add Sub-Agent',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Sub-agents earn commission and report to you',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12)),
            const SizedBox(height: 24),

            // Error
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.red, fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],

            // Name field
            _SheetLabel('Sub-Agent Name'),
            _SheetField(ctrl: _nameCtrl, hint: 'e.g. Ahmed_Pro',
                icon: Icons.person_outline),
            const SizedBox(height: 14),

            // Invite code field
            _SheetLabel('Invite Code'),
            _SheetField(ctrl: _codeCtrl, hint: 'e.g. AHM2024',
                icon: Icons.qr_code_rounded),
            const SizedBox(height: 14),

            // Commission slider
            _SheetLabel('Commission Rate: ${(_commission * 100).toStringAsFixed(0)}%'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primaryPurple,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primaryPurple,
                overlayColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _commission,
                min: 0.03,
                max: 0.15,
                divisions: 12,
                onChanged: (v) => setState(() => _commission = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('3%', style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
                Text('15%', style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _saving ? null : _submit,
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
                    child: _saving
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Add Sub-Agent',
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 10)),
      ]),
    );
  }
}

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
  final IconData icon;

  const _SheetField({required this.ctrl, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
        prefixIcon: Icon(icon,
            color: Colors.white.withValues(alpha: 0.3), size: 18),
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

