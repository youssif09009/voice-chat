import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../services/agency_api.dart';

class AgencyIncomeScreen extends StatefulWidget {
  const AgencyIncomeScreen({super.key});
  @override
  State<AgencyIncomeScreen> createState() => _AgencyIncomeScreenState();
}

class _AgencyIncomeScreenState extends State<AgencyIncomeScreen> {
  String _period = 'Today';
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _agents = [];
  bool _loadingAgents = true;

  static const _periods = ['Today', 'Yesterday', 'This month', 'Last month'];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    setState(() => _loadingAgents = true);
    final r = await AgencyApi.instance.getAdminAgentsList();
    if (!mounted) return;
    setState(() {
      _loadingAgents = false;
      if (r.ok) {
        _agents = (r.data!['rows'] as List).cast<Map<String, dynamic>>();
      }
    });
  }

  List<Map<String, dynamic>> get _filteredAgents {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _agents;
    return _agents.where((a) =>
        (a['username'] as String).toLowerCase().contains(q) ||
        (a['id'] as String).toLowerCase().contains(q)).toList();
  }

  void _showAddAgentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAgentSheet(
        onAdded: () {
          _loadAgents();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Agent added successfully!'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('My Income',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAgents,
        color: AppColors.primaryPurple,
        backgroundColor: AppColors.surface,
        child: ListView(
          children: [
            // ── Income summary banner ──────────────────────────────────
            _IncomeBanner(),
            const SizedBox(height: 8),

            // ── Rewards grid ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(children: [
                  _RewardRow(
                    left:  const _RewardCell(label: "Last Month's Rewards", value: '0\$'),
                    right: const _RewardCell(label: "Last Month's Income",  value: '0\$'),
                  ),
                  _Divider(),
                  _RewardRow(
                    left:  const _RewardCell(label: "This Month's Rewards", value: '0\$'),
                    right: const _RewardCell(label: "This Month's Income",  value: '0\$'),
                  ),
                  _Divider(),
                  _RewardRow(
                    left:  const _RewardCell(label: 'Agency Number', value: '0'),
                    right: const _RewardCell(label: 'Number Game Rewards', value: '0', hasDetails: true),
                  ),
                  _Divider(),
                  _RewardRow(
                    left:  const _RewardCell(label: 'Agent Game Rewards',  value: '0\$', hasDetails: true),
                    right: const _RewardCell(label: 'Invite Agent Income', value: '0',  hasDetails: true),
                  ),
                  _Divider(),
                  _RewardRow(
                    left:  const _RewardCell(label: 'Member Refund', value: '0\$', hasDetails: true),
                    right: const SizedBox(),
                  ),
                  const SizedBox(height: 4),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // ── Agency Data header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('Agency Data', style: AppTypography.h2),
                const SizedBox(width: 12),
                // ── ADD AGENT BUTTON ──────────────────────────────────
                GestureDetector(
                  onTap: _showAddAgentSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.pink],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.35),
                          blurRadius: 8, offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.person_add_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text('Add Agent',
                          style: TextStyle(color: Colors.white,
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                const Spacer(),
                // Period picker
                GestureDetector(
                  onTap: _showPeriodPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_period, style: AppTypography.labelSmall),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppColors.textSecondary),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID',
                    hintStyle: AppTypography.caption,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textHint, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Table header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(flex: 3, child: Text('Agent', style: AppTypography.caption)),
                Expanded(flex: 2, child: Text('Invites', textAlign: TextAlign.center, style: AppTypography.caption)),
                Expanded(flex: 2, child: Text('Monthly 🪙', textAlign: TextAlign.center, style: AppTypography.caption)),
                Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.center, style: AppTypography.caption)),
              ]),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 1, color: AppColors.border,
            ),

            // ── Agent rows ─────────────────────────────────────────────
            if (_loadingAgents)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(
                    color: AppColors.primaryPurple, strokeWidth: 2.5)),
              )
            else if (_filteredAgents.isEmpty)
              _EmptyAgents(hasSearch: _searchCtrl.text.isNotEmpty)
            else
              ..._filteredAgents.map((a) => _AgentRow(agent: a)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          ..._periods.map((p) => ListTile(
            title: Text(p, style: AppTypography.body.copyWith(
                color: p == _period
                    ? AppColors.primaryPurple
                    : AppColors.textPrimary,
                fontWeight: p == _period ? FontWeight.bold : FontWeight.normal)),
            trailing: p == _period
                ? const Icon(Icons.check_rounded, color: AppColors.primaryPurple)
                : null,
            onTap: () {
              setState(() => _period = p);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Agent bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddAgentSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddAgentSheet({required this.onAdded});
  @override
  State<_AddAgentSheet> createState() => _AddAgentSheetState();
}

class _AddAgentSheetState extends State<_AddAgentSheet> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter an email address');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }

    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.createAgent(email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (r.ok) {
      setState(() => _result = r.data);
      widget.onAdded();
    } else {
      setState(() => _error = r.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),

          // Title
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.pink]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_add_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Agent', style: AppTypography.h2),
              Text('Enter the user\'s email address',
                  style: AppTypography.caption),
            ]),
          ]),
          const SizedBox(height: 24),

          // Success state
          if (_result != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(_result!['message'] as String,
                      style: AppTypography.labelMedium.copyWith(
                          color: AppColors.green)),
                ]),
                if (_result!['inviteCode'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.key_rounded,
                          color: AppColors.primaryPurple, size: 16),
                      const SizedBox(width: 8),
                      Text('Invite Code: ',
                          style: AppTypography.caption),
                      Text(_result!['inviteCode'] as String,
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.accentPurple,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2)),
                    ]),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: AppColors.border)),
                ),
                child: const Text('Done'),
              ),
            ),
          ] else ...[
            // Error banner
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.red))),
                ]),
              ),
              const SizedBox(height: 14),
            ],

            // Email field
            Text('Email Address', style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: AppTypography.body,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'user@example.com',
                hintStyle: AppTypography.caption,
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.textHint, size: 18),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primaryPurple, width: 1.5)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The user must already have an account. They will be immediately activated as an agent.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Add Agent',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Agent row in the table
// ─────────────────────────────────────────────────────────────────────────────

class _AgentRow extends StatelessWidget {
  final Map<String, dynamic> agent;
  const _AgentRow({required this.agent});

  @override
  Widget build(BuildContext context) {
    final monthly = (agent['monthly_earnings'] as num).toDouble();
    final status  = agent['status'] as String;
    final statusColor = status == 'active'
        ? AppColors.green
        : status == 'pending'
            ? AppColors.amber
            : AppColors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Avatar + name
        Expanded(flex: 3, child: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
            child: Text(
              (agent['username'] as String)[0].toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(agent['username'] as String,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(agent['id'] as String,
                style: AppTypography.caption,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ])),
        // Invites
        Expanded(flex: 2, child: Text(
          '${agent['total_invites']}',
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
              color: AppColors.cyan, fontWeight: FontWeight.w600),
        )),
        // Monthly earnings
        Expanded(flex: 2, child: Text(
          monthly > 0 ? monthly.toStringAsFixed(0) : '—',
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
              color: monthly > 0 ? AppColors.gold : AppColors.textHint,
              fontWeight: FontWeight.w600),
        )),
        // Status dot
        Expanded(flex: 2, child: Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(status,
              style: TextStyle(
                  color: statusColor, fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4)),
        ))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyAgents extends StatelessWidget {
  final bool hasSearch;
  const _EmptyAgents({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people_outline_rounded,
              color: AppColors.primaryPurple, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          hasSearch ? 'No agents match your search' : 'No agents yet',
          style: AppTypography.h3,
        ),
        const SizedBox(height: 6),
        Text(
          hasSearch
              ? 'Try a different name or ID'
              : 'Tap Add Agent to add your first agent',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _IncomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D0B6B), Color(0xFF1A0840)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
      ),
      child: Stack(children: [
        Positioned(top: -20, right: -20,
            child: Container(width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: AppColors.primaryPurple.withValues(alpha: 0.12)))),
        Positioned(bottom: -20, left: 20,
            child: Container(width: 70, height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: AppColors.pink.withValues(alpha: 0.10)))),
        Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💎 Agency Income',
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Track your agents & earnings',
                style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6))),
          ],
        )),
      ]),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final Widget left, right;
  const _RewardRow({required this.left, required this.right});
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(children: [
      Expanded(child: left),
      Container(width: 1, color: AppColors.border),
      Expanded(child: right),
    ]),
  );
}

class _RewardCell extends StatelessWidget {
  final String label, value;
  final bool hasDetails;
  const _RewardCell({required this.label, required this.value,
      this.hasDetails = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 6),
        Row(children: [
          Text(value, style: AppTypography.labelMedium),
          if (hasDetails) ...[
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text('Details >',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.border);
}
