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
      title: 'Nexus Role Selection',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins',
      ),
      home: const YourRolePage(),
    );
  }
}

class YourRolePage extends StatefulWidget {
  const YourRolePage({super.key});

  @override
  State<YourRolePage> createState() => _YourRolePageState();
}

class _YourRolePageState extends State<YourRolePage> {
  String selectedRole = "User"; // Default selection matches preview

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

          // 2. Vibrant Bottom Glow
          Positioned(
            bottom: -150,
            left: -50,
            right: -50,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    const Color(0xFF00D2FF).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Top Nav with Progress Bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: index < 2 ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Header
                  const Text(
                    "Your Role? 🌟",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Select your team size to customize your Nexus experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Role Selection Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          title: "Agency",
                          emoji: "🏢",
                          isSelected: selectedRole == "Agency",
                          onTap: () => setState(() => selectedRole = "Agency"),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRoleCard(
                          title: "User",
                          emoji: "👤",
                          isSelected: selectedRole == "User",
                          onTap: () => setState(() => selectedRole = "User"),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Next Button
                  Container(
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
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Next",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 35),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), blurRadius: 20)]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF26243A),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 35)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

