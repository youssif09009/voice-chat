import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ranking List Screen  (matches Heylla "Ranking list" UI)
// ─────────────────────────────────────────────────────────────────────────────

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _typeTabs;
  String _scope  = 'Worldwide'; // 'Within country' | 'Worldwide'
  String _period = 'Today';     // 'Today' | 'Week'

  // Fake data
  static const _top3Wealth = [
    _RankEntry(rank: 1, name: 'Ramos',       flag: '🇸🇦', members: 2,   diamonds: 3850000),
    _RankEntry(rank: 2, name: 'ANKA FAMILY', flag: '🇹🇷', members: 566, diamonds: 2110000),
    _RankEntry(rank: 3, name: 'USA',         flag: '🇺🇸', members: 17,  diamonds: 1280000),
  ];
  static const _restWealth = [
    _RankEntry(rank: 4, name: 'infaz ajans', flag: '🇹🇷', members: 53,  diamonds: 1190000),
    _RankEntry(rank: 5, name: 'ANKA FAMILY', flag: '🇹🇷', members: 599, diamonds: 1170000),
    _RankEntry(rank: 6, name: 'StarTeam',    flag: '🇪🇬', members: 88,  diamonds: 980000),
    _RankEntry(rank: 7, name: 'EliteHub',    flag: '🇦🇪', members: 34,  diamonds: 760000),
  ];

  @override
  void initState() {
    super.initState();
    _typeTabs = TabController(length: 2, vsync: this);
    _typeTabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _typeTabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Ranking list',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38),
              ),
              child: const Icon(Icons.question_mark_rounded,
                  color: Colors.white, size: 14),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(children: [
        // ── Type tabs: Agency Wealth | Agency Quantity ─────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            _TypeTab(
              label: 'Agency Wealth',
              active: _typeTabs.index == 0,
              onTap: () => _typeTabs.animateTo(0),
            ),
            const SizedBox(width: 32),
            _TypeTab(
              label: 'Agency Quantity',
              active: _typeTabs.index == 1,
              onTap: () => _typeTabs.animateTo(1),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Scope toggle ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              _ScopeBtn(
                label: 'Within country',
                active: _scope == 'Within country',
                onTap: () => setState(() => _scope = 'Within country'),
              ),
              _ScopeBtn(
                label: 'Worldwide',
                active: _scope == 'Worldwide',
                onTap: () => setState(() => _scope = 'Worldwide'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // ── Period toggle ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _PeriodBtn(
              label: 'Today',
              active: _period == 'Today',
              onTap: () => setState(() => _period = 'Today'),
            ),
            const SizedBox(width: 12),
            _PeriodBtn(
              label: 'Week',
              active: _period == 'Week',
              onTap: () => setState(() => _period = 'Week'),
            ),
            const Spacer(),
            // Prize button
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946EF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFD946EF).withValues(alpha: 0.5)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('🎁', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Text('prize',
                      style: TextStyle(
                          color: Color(0xFFD946EF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),

        // ── Scrollable content ─────────────────────────────────────
        Expanded(
          child: ListView(
            children: [
              // Podium
              _Podium(top3: _top3Wealth),
              const SizedBox(height: 8),

              // Rest of list
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ..._restWealth.map((e) => _RankRow(entry: e)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _RankEntry {
  final int rank, members;
  final String name, flag;
  final int diamonds;
  const _RankEntry(
      {required this.rank,
      required this.name,
      required this.flag,
      required this.members,
      required this.diamonds});
}

// ── Type tab ──────────────────────────────────────────────────────────────────

class _TypeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TypeTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Text(label,
            style: TextStyle(
                color: active ? Colors.white : Colors.white38,
                fontSize: 15,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 4),
        if (active)
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ]),
    );
  }
}

// ── Scope button ──────────────────────────────────────────────────────────────

class _ScopeBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ScopeBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
        ),
      ),
    );
  }
}

// ── Period button ─────────────────────────────────────────────────────────────

class _PeriodBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _PeriodBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryPurple
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<_RankEntry> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    // Order: 2nd left, 1st center, 3rd right
    final second = top3.firstWhere((e) => e.rank == 2);
    final first  = top3.firstWhere((e) => e.rank == 1);
    final third  = top3.firstWhere((e) => e.rank == 3);

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _PodiumSlot(entry: second, height: 140)),
          // 1st place
          Expanded(child: _PodiumSlot(entry: first, height: 180, isFirst: true)),
          // 3rd place
          Expanded(child: _PodiumSlot(entry: third, height: 120)),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final _RankEntry entry;
  final double height;
  final bool isFirst;
  const _PodiumSlot(
      {required this.entry,
      required this.height,
      this.isFirst = false});

  Color get _crownColor {
    if (entry.rank == 1) return const Color(0xFFFFD700);
    if (entry.rank == 2) return const Color(0xFFD946EF);
    return const Color(0xFF06B6D4);
  }

  Color get _podiumColor {
    if (entry.rank == 1) return const Color(0xFFFFD700).withValues(alpha: 0.3);
    if (entry.rank == 2) return const Color(0xFFD946EF).withValues(alpha: 0.2);
    return const Color(0xFF06B6D4).withValues(alpha: 0.2);
  }

  String get _rankLabel => 'No.${entry.rank}';

  @override
  Widget build(BuildContext context) {
    final avatarSize = isFirst ? 64.0 : 52.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crown
        Text(isFirst ? '👑' : (entry.rank == 2 ? '💜' : '💙'),
            style: TextStyle(fontSize: isFirst ? 22 : 16)),
        const SizedBox(height: 4),
        // Avatar
        Container(
          width: avatarSize, height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _crownColor, width: 2.5),
            color: AppColors.surface,
          ),
          child: Center(
            child: Text(entry.name[0].toUpperCase(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 24 : 18)),
          ),
        ),
        const SizedBox(height: 6),
        // Name
        Text(entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        // Flag + members
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(entry.flag, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          const Icon(Icons.people_rounded, color: Colors.white54, size: 10),
          Text(' ${entry.members}',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ]),
        const SizedBox(height: 2),
        // Diamonds
        Text(_formatDiamonds(entry.diamonds),
            style: TextStyle(
                color: _crownColor,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        // Podium base
        Container(
          height: height * 0.35,
          decoration: BoxDecoration(
            color: _podiumColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(_rankLabel,
                style: TextStyle(
                    color: _crownColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  String _formatDiamonds(int d) {
    if (d >= 1000000) return '${(d / 1000000).toStringAsFixed(2)}M 💎';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(0)}K 💎';
    return '$d 💎';
  }
}

// ── Rank row (4th place and below) ───────────────────────────────────────────

class _RankRow extends StatelessWidget {
  final _RankEntry entry;
  const _RankRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(children: [
        // Rank number
        SizedBox(
          width: 28,
          child: Text('${entry.rank < 10 ? '0' : ''}${entry.rank}',
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        // Avatar
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryPurple.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(entry.name[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        // Name + flag + members
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.name,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Row(children: [
              Text(entry.flag, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              const Icon(Icons.people_rounded,
                  color: Colors.black38, size: 12),
              Text(' ${entry.members}',
                  style: const TextStyle(
                      color: Colors.black38, fontSize: 11)),
            ]),
          ]),
        ),
        // Diamonds
        Text(_formatDiamonds(entry.diamonds),
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  String _formatDiamonds(int d) {
    if (d >= 1000000) return '${(d / 1000000).toStringAsFixed(2)}M 💎';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(0)}K 💎';
    return '$d 💎';
  }
}
