import 'package:flutter/material.dart';

void main() {
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Login',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins', // Make sure to add Poppins to your pubspec.yaml
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF19172B), Color(0xFF08070F)],
              ),
            ),
          ),

          // 2. Vibrant Blue Glow at the bottom
          Positioned(
            bottom: -150,
            left: -100,
            right: -100,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: 0.2),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF26243A).withValues(alpha: 0.8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: const Icon(Icons.mic_none_rounded, size: 45, color: Colors.white),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontFamily: 'Playfair Display', // Add to pubspec.yaml
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Email/Username Input
                  _buildLabel("Email or Username"),
                  _buildTextField(hint: "Enter your email", icon: Icons.email_outlined),

                  const SizedBox(height: 20),

                  // Password Input
                  _buildLabel("Password"),
                  _buildTextField(hint: "••••••••", icon: Icons.lock_outline, isPassword: true),

                  const SizedBox(height: 20),

                  // Main Login Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Or Login with", style: TextStyle(color: Colors.white24, fontSize: 13)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Social Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 2.8,
                    children: [
                      _socialCard(icon: Icons.g_mobiledata_rounded, color: Colors.redAccent),
                      _socialCard(icon: Icons.apple_rounded, color: Colors.white),
                      _socialCard(icon: Icons.facebook_rounded, color: const Color(0xFF1877F2)),
                      _socialCard(icon: Icons.mail_outline_rounded, color: const Color(0xFF00D2FF)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      const Text(
                        "Sign Up",
                        style: TextStyle(color: Color(0xFF00D2FF), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 8),
        child: Text(
          text,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }

  Widget _socialCard({required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

