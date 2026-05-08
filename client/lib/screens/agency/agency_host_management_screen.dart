import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import 'create_agency_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Agency Host Management Screen
// ─────────────────────────────────────────────────────────────────────────────

class AgencyHostManagementScreen extends StatefulWidget {
  final AgencyData? agency;
  const AgencyHostManagementScreen({super.key, this.agency});
  @override
  State<AgencyHostManagementScreen> createState() =>
      _AgencyHostManagementScreenState();
}

class _AgencyHostManagementScreenState
    extends State<AgencyHostManagementScreen> {
  String _period = 'Today';
  String _sort   = 'Stars';
  final _searchCtrl = TextEditingController();

  static const _periods = ['Today', 'Yesterday', 'This month', 'Last month'];

  // Empty host list — real data comes from backend
  final List<_HostRow> _hosts = const [];

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
        title: const Text('Agency',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        // ── Header card ────────────────────────────────────────
        _HeaderCard(agency: widget.agency),

        // ── Host Data label + sort ─────────────────────────────────
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Text('Host Data:',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: _showSortPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_sort,
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

        // ── Period filter pills ────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _periods.length,
            itemBuilder: (_, i) {
              final p = _periods[i];
              final active = p == _period;
              return GestureDetector(
                onTap: () => setState(() => _period = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active
                          ? AppColors.primaryPurple
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Text(p,
                      style: TextStyle(
                          color: active ? Colors.white : Colors.black54,
                          fontSize: 12,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // ── Search bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded,
                  color: Color(0xFFBBBBBB), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter host ID',
                    hintStyle: TextStyle(
                        color: Color(0xFFBBBBBB), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Color(0xFFBBBBBB), size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() {});
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // ── Table header ───────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Text('Host information',
                    style: TextStyle(
                        color: Color(0xFF888888), fontSize: 11))),
            Expanded(
                flex: 2,
                child: Text('Valid Days',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF888888), fontSize: 11))),
            Expanded(
                flex: 2,
                child: Text('Valid Hours',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF888888), fontSize: 11))),
            Expanded(
                flex: 2,
                child: Text('Stars',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF888888), fontSize: 11))),
          ]),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.border),

        // ── Host rows ──────────────────────────────────────────────
        Expanded(
          child: _hosts.isEmpty
              ? _HostEmptyState()
              : ListView.builder(
                  itemCount: _hosts.length,
                  itemBuilder: (_, i) => _HostDataRow(host: _hosts[i]),
                ),
        ),
      ]),
    );
  }

  void _showSortPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
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
          ...['Stars', 'Valid Hours', 'Valid Days'].map((s) => ListTile(
                title: Text(s,
                    style: TextStyle(
                        color: s == _sort
                            ? AppColors.primaryPurple
                            : Colors.black87,
                        fontWeight: s == _sort
                            ? FontWeight.bold
                            : FontWeight.normal)),
                trailing: s == _sort
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primaryPurple)
                    : null,
                onTap: () {
                  setState(() => _sort = s);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final AgencyData? agency;
  const _HeaderCard({this.agency});

  @override
  Widget build(BuildContext context) {
    final name = agency?.name ?? 'My Agency';
    final id   = agency?.id   ?? '—';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFF5B5BD6)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('ID: $id',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
        const SizedBox(height: 16),
        Row(children: [
          _HeaderStat(label: 'Total Hosts', value: '0'),
          _HeaderStat(label: 'New Hosts',   value: '0'),
          _HeaderStat(
              label: 'Active Rate',
              value: '0%',
              valueColor: const Color(0xFFFF6B35)),
        ]),
      ]),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _HeaderStat(
      {required this.label,
      required this.value,
      this.valueColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ── Host data model ───────────────────────────────────────────────────────────

class _HostRow {
  final String name, id;
  final int validDays, stars;
  final double validHours;
  const _HostRow({
    required this.name,
    required this.id,
    required this.validDays,
    required this.validHours,
    required this.stars,
  });
}

// ── Host empty state ──────────────────────────────────────────────────────────

class _HostEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEFF),
            borderRadius: BorderRadius.circular(36),
          ),
          child: const Icon(Icons.mic_none_rounded,
              color: AppColors.primaryPurple, size: 36),
        ),
        const SizedBox(height: 14),
        const Text('No hosts yet',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 15,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        const Text('Hosts you manage will appear here',
            style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
      ]),
    );
  }
}

// ── Host data row ─────────────────────────────────────────────────────────────

class _HostDataRow extends StatelessWidget {
  final _HostRow host;
  const _HostDataRow({required this.host});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(children: [
        // Avatar + name
        Expanded(
          flex: 3,
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(host.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(host.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('ID: ${host.id}',
                    style: const TextStyle(
                        color: Color(0xFFAAAAAA), fontSize: 10)),
              ]),
            ),
          ]),
        ),
        // Valid days
        Expanded(
          flex: 2,
          child: Text('${host.validDays}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13)),
        ),
        // Valid hours
        Expanded(
          flex: 2,
          child: Text(host.validHours.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13)),
        ),
        // Stars
        Expanded(
          flex: 2,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD946EF),
              ),
              child: const Center(
                child: Icon(Icons.star_rounded,
                    color: Colors.white, size: 12),
              ),
            ),
            const SizedBox(width: 4),
            Text('${host.stars}',
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}
