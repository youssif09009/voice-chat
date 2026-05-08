import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Income Screen  (matches Heylla "My Income" UI)
// ─────────────────────────────────────────────────────────────────────────────

class AgencyIncomeScreen extends StatefulWidget {
  const AgencyIncomeScreen({super.key});
  @override
  State<AgencyIncomeScreen> createState() => _AgencyIncomeScreenState();
}

class _AgencyIncomeScreenState extends State<AgencyIncomeScreen> {
  String _period = 'Today';
  final _searchCtrl = TextEditingController();

  static const _periods = ['Today', 'Yesterday', 'This month', 'Last month'];

  // Empty — real data comes from backend
  final List<_AgencyRow> _rows = const [];

  @override
  void dispose() {
    _searchCtrl.dispose();
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
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('My Income',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        children: [
          // ── Decorative banner ──────────────────────────────────────
          _IncomeBanner(),
          const SizedBox(height: 4),

          // ── Rewards grid ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(children: [
                _RewardRow(
                  left:  _RewardCell(label: "Last Month's Rewards", value: '0\$'),
                  right: _RewardCell(label: "Last Month's Income",  value: '0\$'),
                ),
                const _RowDivider(),
                _RewardRow(
                  left:  _RewardCell(label: "This Month's Rewards", value: '0\$'),
                  right: _RewardCell(label: "This Month's Income",  value: '0\$'),
                ),
                const _RowDivider(),
                _RewardRow(
                  left:  _RewardCell(label: 'Agency Number', value: '0'),
                  right: _RewardCell(
                      label: 'Number Game Rewards',
                      value: '0',
                      hasDetails: true),
                ),
                const _RowDivider(),
                _RewardRow(
                  left:  _RewardCell(
                      label: 'Agent Game Rewards',
                      value: '0\$',
                      hasDetails: true),
                  right: _RewardCell(
                      label: 'Invite Agent Income',
                      value: '0',
                      hasDetails: true),
                ),
                const _RowDivider(),
                _RewardRow(
                  left: _RewardCell(
                      label: 'Member Refund',
                      value: '0\$',
                      hasDetails: true),
                  right: const SizedBox(),
                ),
                const SizedBox(height: 4),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ── Agency Data section ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Agency Data',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              // Add Agent button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Add Agent',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              // Period picker
              GestureDetector(
                onTap: () => _showPeriodPicker(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_period,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 12)),
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
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Enter Agency ID',
                  hintStyle:
                      TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Color(0xFFBBBBBB), size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Table header ───────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(flex: 2, child: _TableHeader('Agency ID')),
              Expanded(flex: 2, child: _TableHeader('Name')),
              Expanded(flex: 1, child: _TableHeader('Member', center: true)),
              Expanded(flex: 2, child: _TableHeader('Income', center: true)),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Table rows ─────────────────────────────────────────────
          if (_rows.isEmpty)
            _EmptyState()
          else
            ..._rows.map((r) => _AgencyDataRow(row: r)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ..._periods.map((p) => ListTile(
                title: Text(p,
                    style: TextStyle(
                        color: p == _period
                            ? AppColors.primaryPurple
                            : Colors.black87,
                        fontWeight: p == _period
                            ? FontWeight.bold
                            : FontWeight.normal)),
                trailing: p == _period
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primaryPurple)
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

// ── Decorative income banner ──────────────────────────────────────────────────

class _IncomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: 20,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💎 × 1',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('My Income',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
              ],
            ),
          ),
          // Left avatar
          Positioned(
            left: 16, top: 0, bottom: 0,
            child: Center(
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: AppColors.primaryPurple,
                ),
                child: const Center(
                  child: Text('A',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
            ),
          ),
          // Right avatar
          Positioned(
            right: 16, top: 0, bottom: 0,
            child: Center(
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: const Color(0xFF06B6D4),
                ),
                child: const Center(
                  child: Text('B',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reward grid widgets ───────────────────────────────────────────────────────

class _RewardRow extends StatelessWidget {
  final Widget left, right;
  const _RewardRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: left),
          Container(width: 1, color: AppColors.border),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _RewardCell extends StatelessWidget {
  final String label, value;
  final bool hasDetails;
  const _RewardCell(
      {required this.label,
      required this.value,
      this.hasDetails = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF888888), fontSize: 11)),
        const SizedBox(height: 6),
        Row(children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          if (hasDetails) ...[
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Details >',
                  style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.border);
}

// ── Table widgets ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final String text;
  final bool center;
  const _TableHeader(this.text, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 12,
            fontWeight: FontWeight.w500));
  }
}

class _AgencyRow {
  final String id, name;
  final int members;
  final double income;
  const _AgencyRow(
      {required this.id,
      required this.name,
      required this.members,
      required this.income});
}

class _AgencyDataRow extends StatelessWidget {
  final _AgencyRow row;
  const _AgencyDataRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(row.id,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 12))),
        Expanded(
            flex: 2,
            child: Text(row.name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500))),
        Expanded(
            flex: 1,
            child: Text('${row.members}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 12))),
        Expanded(
            flex: 2,
            child: Text('\$${row.income.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: row.income > 0
                        ? Colors.green.shade600
                        : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEFF),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.inbox_rounded,
              color: AppColors.primaryPurple, size: 40),
        ),
        const SizedBox(height: 16),
        const Text('No data yet',
            style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
      ]),
    );
  }
}
