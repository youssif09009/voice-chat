import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/agency/app_shell.dart';
import 'screens/agency/auth_screen.dart';
import 'screens/agency/host_dashboard_screen.dart';
import 'services/agency_api.dart';

void main() => runApp(const NexusVoiceApp());

class NexusVoiceApp extends StatelessWidget {
  const NexusVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Voice',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryPurple,
          surface: AppColors.surface,
        ),
        fontFamily: 'Roboto',
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.transparent,
          selectionHandleColor: Colors.transparent,
        ),
      ),
      // Auto-login as admin so the dashboard is the very first screen.
      // The splash widget logs in silently; on failure it falls back to
      // the normal auth screen so the app never gets stuck.
      home: const _AutoLoginSplash(),
    );
  }
}

// ---------------------------------------------------------------------------
// Splash — auto-login as admin, then push the right dashboard
// ---------------------------------------------------------------------------

class _AutoLoginSplash extends StatefulWidget {
  const _AutoLoginSplash();

  @override
  State<_AutoLoginSplash> createState() => _AutoLoginSplashState();
}

class _AutoLoginSplashState extends State<_AutoLoginSplash> {
  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    final r = await AgencyApi.instance.login('admin@app.com', 'admin123');

    if (!mounted) return;

    Widget dest;
    if (r.ok) {
      final role = AgencyApi.instance.role;
      if (role == 'admin') {
        dest = const AppShell(initialIndex: 0);
      } else if (role == 'agent') {
        dest = const AppShell(initialIndex: 0);
      } else if (role == 'host') {
        dest = const HostDashboardScreen();
      } else {
        dest = AgencyAuthScreen();
      }
    } else {
      dest = AgencyAuthScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, Color(0xFFD946EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Agency Portal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading dashboard…',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.primaryPurple,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
