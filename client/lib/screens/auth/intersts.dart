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
      title: 'Nexus Interests',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins',
      ),
      home: const ChooseInterestsPage(),
    );
  }
}

// موديل بسيط لتخزين بيانات الاهتمامات
class InterestModel {
  final String title;
  final String emoji;
  final String rooms;
  bool isSelected;

  InterestModel({
    required this.title,
    required this.emoji,
    required this.rooms,
    this.isSelected = false,
  });
}

class ChooseInterestsPage extends StatefulWidget {
  const ChooseInterestsPage({super.key});

  @override
  State<ChooseInterestsPage> createState() => _ChooseInterestsPageState();
}

class _ChooseInterestsPageState extends State<ChooseInterestsPage> {
  // قائمة الاهتمامات (نفس اللي في الـ HTML)
  final List<InterestModel> _interests = [
    InterestModel(title: "Podcasts", emoji: "🎙️", rooms: "1.2k Rooms", isSelected: true),
    InterestModel(title: "Live Music", emoji: "🎸", rooms: "850 Rooms"),
    InterestModel(title: "Gaming", emoji: "🎮", rooms: "2.4k Rooms", isSelected: true),
    InterestModel(title: "Meditation", emoji: "🧘", rooms: "420 Rooms"),
    InterestModel(title: "Art & Design", emoji: "🎨", rooms: "610 Rooms"),
    InterestModel(title: "Sports", emoji: "⚽", rooms: "1.1k Rooms"),
    InterestModel(title: "Technology", emoji: "💻", rooms: "1.8k Rooms"),
    InterestModel(title: "Movies", emoji: "🎬", rooms: "930 Rooms", isSelected: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخلفية المتدرجة الأساسية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF19172B), Color(0xFF08070F)],
              ),
            ),
          ),

          // 2. التوهج الجمالي (Glow)
          Positioned(
            top: 50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. المحتوى
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر (العنوان)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What do you love?",
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 32,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Select at least 3 interests to personalize your Nexus experience.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // شبكة الاهتمامات (Grid)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1, // أبعاد الكارت
                    ),
                    itemCount: _interests.length,
                    itemBuilder: (context, index) {
                      final item = _interests[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            item.isSelected = !item.isSelected;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: item.isSelected
                                ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: item.isSelected
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.white.withValues(alpha: 0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.rooms,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // زر الاستمرار (Continue Button)
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
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
                            "Continue",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Skip for now",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
