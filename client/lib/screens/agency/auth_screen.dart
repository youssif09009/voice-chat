import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/agency_api.dart';
import 'admin_dashboard_screen.dart';
import 'agent_dashboard_screen.dart';
import 'host_dashboard_screen.dart';

class AgencyAuthScreen extends StatefulWidget {
  const AgencyAuthScreen({super.key});

  @override
  State<AgencyAuthScreen> createState() => _AgencyAuthScreenState();
}

class _AgencyAuthScreenState extends State<AgencyAuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = false;
  String? _error;

  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _regUsernameCtrl   = TextEditingController();
  final _regEmailCtrl      = TextEditingController();
  final _regPasswordCtrl   = TextEditingController();
  final _regInviteCtrl     = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regInviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.login(
      _loginEmailCtrl.text.trim(),
      _loginPasswordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!r.ok) { setState(() => _error = r.error); return; }
    _navigate();
  }

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    final r = await AgencyApi.instance.register(
      _regUsernameCtrl.text.trim(),
      _regEmailCtrl.text.trim(),
      _regPasswordCtrl.text,
      inviteCode: _regInviteCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!r.ok) { setState(() => _error = r.error); return; }
    final lr = await AgencyApi.instance.login(
      _regEmailCtrl.text.trim(), _regPasswordCtrl.text);
    if (!mounted) return;
    if (!lr.ok) { setState(() => _error = lr.error); return; }
    _navigate();
  }

  void _navigate() {
    final role = AgencyApi.instance.role;
    Widget dest;
    if (role == 'admin')       dest = const AdminDashboardScreen();
    else if (role == 'agent')  dest = const AgentDashboardScreen();
    else if (role == 'host')   dest = const HostDashboardScreen();
    else                       dest = _UserLandingScreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dest));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 48),
            // Logo
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, Color(0xFFD946EF)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4),
                    blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Agency Portal',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            Text('Manage agents, hosts & earnings',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
            const SizedBox(height: 36),

            // Tab bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primaryPurple, Color(0xFFD946EF)]),
                    borderRadius: BorderRadius.circular(22)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [Tab(text: 'Sign In'), Tab(text: 'Register')],
              ),
            ),
            const SizedBox(height: 28),

            // Error banner
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: const TextStyle(color: AppColors.red, fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // Forms
            SizedBox(
              height: 340,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _LoginForm(
                      emailCtrl: _loginEmailCtrl,
                      passwordCtrl: _loginPasswordCtrl,
                      loading: _loading,
                      onSubmit: _login),
                  _RegisterForm(
                      usernameCtrl: _regUsernameCtrl,
                      emailCtrl: _regEmailCtrl,
                      passwordCtrl: _regPasswordCtrl,
                      inviteCtrl: _regInviteCtrl,
                      loading: _loading,
                      onSubmit: _register),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Quick-fill hint
            GestureDetector(
              onTap: () {
                _loginEmailCtrl.text    = 'admin@app.com';
                _loginPasswordCtrl.text = 'admin123';
                _tabs.animateTo(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 16),
                  const SizedBox(width: 6),
                  Text('Quick fill: admin@app.com / admin123',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}

// ── Login form ────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl, passwordCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  const _LoginForm({required this.emailCtrl, required this.passwordCtrl,
      required this.loading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _AuthField(ctrl: emailCtrl, hint: 'Email', icon: Icons.email_outlined),
      const SizedBox(height: 14),
      _AuthField(ctrl: passwordCtrl, hint: 'Password', icon: Icons.lock_outline, obscure: true),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity,
          child: _SubmitBtn(label: 'Sign In', icon: Icons.login_rounded, loading: loading, onTap: onSubmit)),
    ]);
  }
}

// ── Register form ─────────────────────────────────────────────────────────────

class _RegisterForm extends StatelessWidget {
  final TextEditingController usernameCtrl, emailCtrl, passwordCtrl, inviteCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  const _RegisterForm({required this.usernameCtrl, required this.emailCtrl,
      required this.passwordCtrl, required this.inviteCtrl,
      required this.loading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _AuthField(ctrl: usernameCtrl, hint: 'Username', icon: Icons.person_outline),
      const SizedBox(height: 10),
      _AuthField(ctrl: emailCtrl, hint: 'Email', icon: Icons.email_outlined),
      const SizedBox(height: 10),
      _AuthField(ctrl: passwordCtrl, hint: 'Password', icon: Icons.lock_outline, obscure: true),
      const SizedBox(height: 10),
      _AuthField(ctrl: inviteCtrl, hint: 'Invite Code (optional)', icon: Icons.card_giftcard_rounded),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity,
          child: _SubmitBtn(label: 'Create Account', icon: Icons.person_add_rounded, loading: loading, onTap: onSubmit)),
    ]);
  }
}

// ── Shared field ──────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool obscure;
  const _AuthField({required this.ctrl, required this.hint, required this.icon, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 18),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryPurple)),
      ),
    );
  }
}

// ── Submit button ─────────────────────────────────────────────────────────────

class _SubmitBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;
  const _SubmitBtn({required this.label, required this.icon, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primaryPurple, Color(0xFFD946EF)]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.35),
              blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
        ),
      ),
    );
  }
}

// ── Regular user landing ──────────────────────────────────────────────────────

class _UserLandingScreen extends StatefulWidget {
  @override
  State<_UserLandingScreen> createState() => _UserLandingScreenState();
}

class _UserLandingScreenState extends State<_UserLandingScreen> {
  bool _loading = false;
  String? _msg;

  Future<void> _apply(bool asAgent) async {
    setState(() { _loading = true; _msg = null; });
    final r = asAgent
        ? await AgencyApi.instance.applyAsAgent()
        : await AgencyApi.instance.applyAsHost();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _msg = r.ok ? (r.data?['message'] as String? ?? 'Application submitted!') : r.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Welcome, ${AgencyApi.instance.username ?? 'User'}',
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
            onPressed: () {
              AgencyApi.instance.clearSession();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => AgencyAuthScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your account is active.',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Apply to become an agent or host to unlock your dashboard.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
          const SizedBox(height: 32),
          if (_msg != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3))),
              child: Text(_msg!, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            const SizedBox(height: 20),
          ],
          _ApplyCard(emoji: '🤝', title: 'Become an Agent',
              description: 'Invite users and earn commissions on their activity.',
              color: AppColors.primaryPurple, loading: _loading, onTap: () => _apply(true)),
          const SizedBox(height: 16),
          _ApplyCard(emoji: '🎙', title: 'Become a Host',
              description: 'Create voice rooms and earn from gifts received.',
              color: const Color(0xFFD946EF), loading: _loading, onTap: () => _apply(false)),
        ]),
      ),
    );
  }
}

class _ApplyCard extends StatelessWidget {
  final String emoji, title, description;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  const _ApplyCard({required this.emoji, required this.title, required this.description,
      required this.color, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
        ]),
      ),
    );
  }
}
