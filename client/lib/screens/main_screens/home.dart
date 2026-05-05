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
      title: 'Nexus Profile',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins',
      ),
      home: const NexusProfilePage(),
    );
  }
}

class NexusProfilePage extends StatelessWidget {
  const NexusProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // 1. قسم الأصول (العملات، الطاقة، الأوسمة) - نفس تقسيم الصورة
            _buildAssetCard(),

            // 2. بانر الـ VIP - مكان البانر الأصفر في الصورة
            _buildVipBanner(),

            // 3. شبكة الإدارة (6 أيقونات بستايل نكسوس)
            _buildServiceGrid(),

            // 4. القائمة السفلية (المهام، المستوى، الخ)
            _buildBottomMenu(),

            const SizedBox(height: 100), // مساحة للـ Nav Bar
          ],
        ),
      ),
      bottomNavigationBar: _buildNexusNavBar(),
    );
  }

  // --- بناء العناصر (Widgets) ---

  Widget _buildAssetCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NEXUS ASSETS",
            style: TextStyle(
              color: Color(0xFF8B5CF6), 
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.2
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("1,250", "Coins", "🟣"),
              _buildStatItem("450", "Energy", "✨"),
              _buildStatItem("12", "Badges", "🎖️"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, String icon) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildVipBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1635), Color(0xFF2D235D)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text("👑", style: TextStyle(fontSize: 20)),
          const SizedBox(width: 15),
          const Expanded(
            child: Text("Unlock Premium Features", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.5), size: 14),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15, bottom: 20),
            child: Text("Management Center", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            children: [
              _buildGridItem(Icons.mic_none_rounded, "Host Panel"),
              _buildGridItem(Icons.analytics_outlined, "Statistics"),
              _buildGridItem(Icons.language_rounded, "Discovery"),
              _buildGridItem(Icons.card_giftcard_rounded, "Rewards"),
              _buildGridItem(Icons.admin_panel_settings_outlined, "Safety"),
              _buildGridItem(Icons.tune_rounded, "Settings"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildBottomMenu() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildMenuRow(Icons.assignment_outlined, "Missions"),
          _buildMenuRow(Icons.handshake_outlined, "Partner Program"),
          _buildMenuRow(Icons.workspace_premium_outlined, "My Level"),
        ],
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white38, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildNexusNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF12111F),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.explore_outlined, "Lobby"),
          // التعديل الجديد هنا: من Play إلى Voice Rooms مع أيقونة الميكروفون
          _navItem(Icons.mic_rounded, "Voice Rooms"), 
          _navItem(Icons.notifications_none_rounded, "Inbox"),
          _navItem(Icons.person_rounded, "Profile", isActive: true),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF8B5CF6) : Colors.white24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? const Color(0xFF8B5CF6) : Colors.white24, fontSize: 10)),
      ],
    );
  }
}
