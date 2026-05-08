import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import 'agency_host_management_screen.dart';
import 'create_agency_screen.dart';
import 'agency_income_screen.dart';
import 'ranking_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Agency Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class AgencyMainScreen extends StatefulWidget {
  const AgencyMainScreen({super.key});
  @override
  State<AgencyMainScreen> createState() => _AgencyMainScreenState();
}

class _AgencyMainScreenState extends State<AgencyMainScreen> {
  AgencyData? get _agency => AgencyStore.instance.agency;

  Future<void> _openCreate({bool edit = false}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAgencyScreen(
          existing: edit ? _agency : null,
        ),
      ),
    );
    if (result == true) setState(() {});
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
        title: const Text('Agency',
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          if (_agency == null)
            TextButton(
              onPressed: () => _openCreate(),
              child: const Text('Create',
                  style: TextStyle(
                      color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
              onPressed: () => _openCreate(edit: true),
            ),
        ],
      ),
      body: _agency == null
          ? _NoAgencyState(onCreate: () => _openCreate())
          : _AgencyBody(
              agency: _agency!,
              onEdit: () => _openCreate(edit: true),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — no agency yet
// ─────────────────────────────────────────────────────────────────────────────

class _NoAgencyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _NoAgencyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_rounded,
                  color: AppColors.primaryPurple, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('No Agency Yet',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Create your agency to start managing hosts, tracking income, and growing your team.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create Agency',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
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
// Agency body — shown when agency exists
// ─────────────────────────────────────────────────────────────────────────────

class _AgencyBody extends StatelessWidget {
  final AgencyData agency;
  final VoidCallback onEdit;
  const _AgencyBody({required this.agency, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ── Profile card ───────────────────────────────────────────
        _AgencyCard(agency: agency, onEdit: onEdit),

        const SizedBox(height: 8),
        Container(height: 8, color: const Color(0xFFF7F7F7)),

        // ── Menu rows ──────────────────────────────────────────────
        _MenuRow(
          icon: Icons.show_chart_rounded,
          label: 'Host Management',
          color: AppColors.blue,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AgencyHostManagementScreen(agency: agency))),
        ),
        _Divider(),
        _MenuRow(
          icon: Icons.emoji_events_rounded,
          label: 'Ranking List',
          color: const Color(0xFFFF6B35),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RankingScreen())),
        ),
        _Divider(),
        _MenuRow(
          icon: Icons.account_balance_wallet_rounded,
          label: 'My Income',
          color: AppColors.gold,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AgencyIncomeScreen())),
        ),
        _Divider(),

        // ── Commission balance ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(children: [
            const Text('Commission balance',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const Spacer(),
            const Text('\$0  (0 Stars)',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
        _Divider(),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Agency profile card ───────────────────────────────────────────────────────

class _AgencyCard extends StatelessWidget {
  final AgencyData agency;
  final VoidCallback onEdit;
  const _AgencyCard({required this.agency, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF5B5BD6),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Photo
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: agency.photoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                          File(agency.photoPath!), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            color: Colors.white.withValues(alpha: 0.7), size: 24),
                        const SizedBox(height: 2),
                        Text('Photo',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 10)),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(agency.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('ID: ${agency.id}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.people_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text('${agency.members}/600',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
            ]),
          ),
          // Invite button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Invite',
                  style: TextStyle(
                      color: Color(0xFF5B5BD6), fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        // Announcement
        RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
            children: [
              const TextSpan(
                  text: 'Announcement: ',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: agency.announcement),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Menu row ──────────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuRow({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint, size: 14),
      ]),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.surface);
}
