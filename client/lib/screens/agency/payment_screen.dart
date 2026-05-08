import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models (UI-only, no backend)
// ─────────────────────────────────────────────────────────────────────────────

class _JewelPack {
  final String id;
  final int jewels;
  final double priceEGP;
  final String bonus;
  final bool isBestValue;
  final Color color;
  final String emoji;

  const _JewelPack({
    required this.id,
    required this.jewels,
    required this.priceEGP,
    required this.bonus,
    this.isBestValue = false,
    required this.color,
    required this.emoji,
  });
}

class _Order {
  final String id;
  final int jewels;
  final double priceEGP;
  final String method;
  final String status;
  final DateTime date;

  const _Order({
    required this.id,
    required this.jewels,
    required this.priceEGP,
    required this.method,
    required this.status,
    required this.date,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Static data
// ─────────────────────────────────────────────────────────────────────────────

const _packs = [
  _JewelPack(
    id: 'p1',
    jewels: 100,
    priceEGP: 30,
    bonus: '',
    color: Color(0xFF06B6D4),
    emoji: '💎',
  ),
  _JewelPack(
    id: 'p2',
    jewels: 500,
    priceEGP: 120,
    bonus: '+50 bonus',
    color: Color(0xFF8B5CF6),
    emoji: '💎',
  ),
  _JewelPack(
    id: 'p3',
    jewels: 1200,
    priceEGP: 250,
    bonus: '+200 bonus',
    isBestValue: true,
    color: Color(0xFFD946EF),
    emoji: '💎',
  ),
  _JewelPack(
    id: 'p4',
    jewels: 3000,
    priceEGP: 550,
    bonus: '+600 bonus',
    color: Color(0xFFFFD700),
    emoji: '👑',
  ),
];

final _fakeOrders = [
  _Order(
    id: 'ORD-00124',
    jewels: 1200,
    priceEGP: 250,
    method: 'Vodafone Cash',
    status: 'completed',
    date: DateTime(2026, 5, 4, 14, 32),
  ),
  _Order(
    id: 'ORD-00123',
    jewels: 500,
    priceEGP: 120,
    method: 'InstaPay',
    status: 'completed',
    date: DateTime(2026, 5, 2, 9, 15),
  ),
  _Order(
    id: 'ORD-00122',
    jewels: 100,
    priceEGP: 30,
    method: 'Fawry',
    status: 'completed',
    date: DateTime(2026, 4, 28, 18, 5),
  ),
  _Order(
    id: 'ORD-00121',
    jewels: 3000,
    priceEGP: 550,
    method: 'Vodafone Cash',
    status: 'pending',
    date: DateTime(2026, 4, 25, 11, 44),
  ),
  _Order(
    id: 'ORD-00120',
    jewels: 500,
    priceEGP: 120,
    method: 'Orange Cash',
    status: 'failed',
    date: DateTime(2026, 4, 20, 16, 0),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buy Jewels',
          style: TextStyle(
              color: Color(0xFF1A1A2E), fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showOrderList(context),
            icon: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primaryPurple, size: 18),
            label: const Text('Orders',
                style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Balance banner ─────────────────────────────────────────────
          _BalanceBanner(),
          const SizedBox(height: 24),

          // ── Section title ──────────────────────────────────────────────
          const Text(
            'Choose a Pack',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap any pack to proceed to payment',
            style: TextStyle(
                color: Color(0xFF888899), fontSize: 12),
          ),
          const SizedBox(height: 16),

          // ── Pack grid ─────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: _packs
                .map((p) => _PackCard(
                      pack: p,
                      onTap: () => _showPaymentSheet(context, p),
                    ))
                .toList(),
          ),

          const SizedBox(height: 28),

          // ── How it works ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ℹ️  How it works',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 10),
                ...[
                  '1. Choose a jewel pack',
                  '2. Select your payment method',
                  '3. Complete the payment',
                  '4. Jewels are added instantly',
                ].map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(s,
                          style: const TextStyle(
                              color: Color(0xFF888899),
                              fontSize: 12)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _OrderListScreen()),
    );
  }

  void _showPaymentSheet(BuildContext context, _JewelPack pack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(pack: pack),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balance banner
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F0FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💎', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Balance',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12)),
              const Text('2,450 Jewels',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4)),
            ),
            child: const Text('Top Up',
                style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pack card
// ─────────────────────────────────────────────────────────────────────────────

class _PackCard extends StatelessWidget {
  final _JewelPack pack;
  final VoidCallback onTap;

  const _PackCard({required this.pack, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: pack.isBestValue
                ? pack.color
                : pack.color.withValues(alpha: 0.3),
            width: pack.isBestValue ? 2 : 1,
          ),
          boxShadow: pack.isBestValue
              ? [
                  BoxShadow(
                    color: pack.color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Best value badge
            if (pack.isBestValue)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pack.color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text('BEST VALUE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Emoji
                  Text(pack.emoji,
                      style: const TextStyle(fontSize: 32)),

                  // Jewel count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatNum(pack.jewels),
                        style: TextStyle(
                          color: pack.color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Jewels',
                          style: TextStyle(
                              color: Color(0xFF888899), fontSize: 12)),
                      if (pack.bonus.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(pack.bonus,
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),

                  // Price button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          pack.color.withValues(alpha: 0.8),
                          pack.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'EGP ${pack.priceEGP.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentSheet extends StatefulWidget {
  final _JewelPack pack;
  const _PaymentSheet({required this.pack});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String? _selectedMethod;
  bool _processing = false;
  bool _success = false;

  static const _methods = [
    _PayMethod(id: 'vodafone', name: 'Vodafone Cash', icon: '📱', color: Color(0xFFE60000)),
    _PayMethod(id: 'instapay', name: 'InstaPay',      icon: '⚡', color: Color(0xFF00A651)),
    _PayMethod(id: 'fawry',    name: 'Fawry',         icon: '🏪', color: Color(0xFFF7941D)),
    _PayMethod(id: 'orange',   name: 'Orange Cash',   icon: '🟠', color: Color(0xFFFF6600)),
    _PayMethod(id: 'etisalat', name: 'Etisalat Cash', icon: '💚', color: Color(0xFF00A651)),
    _PayMethod(id: 'card',     name: 'Credit / Debit Card', icon: '💳', color: Color(0xFF8B5CF6)),
  ];

  Future<void> _pay() async {
    if (_selectedMethod == null) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _processing = false; _success = true; });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Text('✅  '),
          Text('${widget.pack.jewels} jewels added to your balance!'),
        ]),
        backgroundColor: Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // Pack summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pack.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: pack.color.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Text(pack.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pack.jewels} Jewels',
                      style: TextStyle(color: pack.color,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if (pack.bonus.isNotEmpty)
                    Text(pack.bonus,
                        style: const TextStyle(
                            color: Colors.greenAccent, fontSize: 12)),
                ],
              )),
              Text('EGP ${pack.priceEGP.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),

          // Method title
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Payment Method',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
          ),
          const SizedBox(height: 10),

          // Methods list
          ..._methods.map((m) => _MethodTile(
            method: m,
            selected: _selectedMethod == m.id,
            onTap: () => setState(() => _selectedMethod = m.id),
          )),

          const SizedBox(height: 20),

          // Pay button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _selectedMethod == null || _processing ? null : _pay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  gradient: _selectedMethod != null
                      ? LinearGradient(colors: [pack.color, pack.color.withValues(alpha: 0.7)])
                      : null,
                  color: _selectedMethod == null
                      ? Colors.white.withValues(alpha: 0.07)
                      : null,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _selectedMethod != null
                      ? [BoxShadow(
                          color: pack.color.withValues(alpha: 0.35),
                          blurRadius: 14, offset: const Offset(0, 5))]
                      : null,
                ),
                child: Center(
                  child: _processing
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : _success
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 24)
                          : Text(
                              _selectedMethod == null
                                  ? 'Select a method first'
                                  : 'Pay EGP ${pack.priceEGP.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: _selectedMethod != null
                                    ? Colors.white
                                    : const Color(0xFFAAAAAA),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayMethod {
  final String id, name, icon;
  final Color color;
  const _PayMethod({required this.id, required this.name,
      required this.icon, required this.color});
}

class _MethodTile extends StatelessWidget {
  final _PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({required this.method, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? method.color.withValues(alpha: 0.1)
              : const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? method.color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.07),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Text(method.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(method.name,
                style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded, color: method.color, size: 20)
          else
            Icon(Icons.radio_button_unchecked_rounded,
                color: Colors.white.withValues(alpha: 0.2), size: 20),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order list screen
// ─────────────────────────────────────────────────────────────────────────────

class _OrderListScreen extends StatelessWidget {
  const _OrderListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order History',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      ),
      body: _fakeOrders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📦', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('No orders yet',
                      style: TextStyle(
                          color: Color(0xFF888899),
                          fontSize: 15)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _fakeOrders.length,
              itemBuilder: (_, i) => _OrderCard(order: _fakeOrders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'completed': return Colors.greenAccent;
      case 'pending':   return AppColors.gold;
      case 'failed':    return AppColors.red;
      default:          return const Color(0xFF888899);
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case 'completed': return Icons.check_circle_rounded;
      case 'pending':   return Icons.hourglass_top_rounded;
      case 'failed':    return Icons.cancel_rounded;
      default:          return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.id,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(order.method,
                  style: const TextStyle(
                      color: Color(0xFF888899),
                      fontSize: 12)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('💎 ${order.jewels}',
                style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            Text('EGP ${order.priceEGP.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Color(0xFF888899),
                    fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(order.status.toUpperCase(),
                style: TextStyle(
                    color: _statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ),
          const Spacer(),
          Text(
            '${order.date.day}/${order.date.month}/${order.date.year}  '
            '${order.date.hour.toString().padLeft(2, '0')}:'
            '${order.date.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: Color(0xFF888899), fontSize: 11),
          ),
        ]),
      ]),
    );
  }
}

