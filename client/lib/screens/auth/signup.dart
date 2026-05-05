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
      title: 'Nexus Sign Up',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins', // تأكد من إضافة الخطوط في pubspec.yaml
      ),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخلفية المتدرجة (نفس الروح)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF19172B), Color(0xFF08070F)],
              ),
            ),
          ),

          // 2. توهج علوي (Cyan Glow) عشان يوازن التوهج السفلي
          Positioned(
            top: -100,
            right: -50,
            child: _buildGlowCircle(const Color(0xFF00D2FF).withValues(alpha: 0.15)),
          ),

          // 3. توهج سفلي (Purple/Pink Glow)
          Positioned(
            bottom: -150,
            left: -100,
            child: _buildGlowCircle(const Color(0xFFD946EF).withValues(alpha: 0.1)),
          ),

          // 4. المحتوى الأساسي
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // أيقونة المايك (اللوجو المصغر)
                  _buildMiniLogo(),

                  const SizedBox(height: 20),
                  // العنوان
                  const Text(
                    "Join the Nexus",
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create your account and start connecting",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // خانات البيانات
                  _buildInputField(label: "Full Name", hint: "John Doe", icon: Icons.person_outline),
                  const SizedBox(height: 18),
                  _buildInputField(label: "Email Address", hint: "example@mail.com", icon: Icons.alternate_email_rounded),
                  const SizedBox(height: 18),
                  _buildInputField(label: "Password", hint: "••••••••", icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 18),
                  _buildInputField(label: "Confirm Password", hint: "••••••••", icon: Icons.shield_outlined, isPassword: true),

                  const SizedBox(height: 30),

                  // زر التسجيل (Gradient)
                  _buildSignUpButton(),

                  const SizedBox(height: 25),

                  // خيارات التواصل الاجتماعي
                  const Text("Or sign up with", style: TextStyle(color: Colors.white24, fontSize: 13)),
                  const SizedBox(height: 20),
                  _buildSocialRow(),

                  const SizedBox(height: 40),

                  // رابط الدخول (Footer)
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets مساعدة للبناء النظيف ---

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 350,
      height: 350,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 100, spreadRadius: 50),
        ],
      ),
    );
  }

  Widget _buildMiniLogo() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF26243A).withValues(alpha: 0.8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Icon(Icons.mic_none_rounded, size: 35, color: Colors.white),
    );
  }

  Widget _buildInputField({required String label, required String hint, required IconData icon, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        ),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
            prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Sign Up",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(Icons.g_mobiledata_rounded, Colors.redAccent),
        const SizedBox(width: 20),
        _socialIcon(Icons.apple_rounded, Colors.white), // علامة آبل البيضاء
        const SizedBox(width: 20),
        _socialIcon(Icons.facebook_rounded, const Color(0xFF1877F2)),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
        ),
        const Text(
          "Login",
          style: TextStyle(color: Color(0xFF00D2FF), fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
