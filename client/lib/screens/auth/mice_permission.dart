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
      title: 'Nexus Agency Services',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins',
      ),
      home: const OfferServicesPage(),
    );
  }
}

class ServiceModel {
  final String name;
  final String desc;
  final IconData icon;
  bool isSelected;

  ServiceModel({
    required this.name,
    required this.desc,
    required this.icon,
    this.isSelected = false,
  });
}

class OfferServicesPage extends StatefulWidget {
  const OfferServicesPage({super.key});

  @override
  State<OfferServicesPage> createState() => _OfferServicesPageState();
}

class _OfferServicesPageState extends State<OfferServicesPage> {
  final List<ServiceModel> _services = [
    ServiceModel(
      name: "Talent Management",
      desc: "Providing top broadcasters",
      icon: Icons.star_border_rounded,
      isSelected: true,
    ),
    ServiceModel(
      name: "Room Moderation",
      desc: "Ensuring safe environment",
      icon: Icons.gavel_rounded,
    ),
    ServiceModel(
      name: "Event Planning",
      desc: "Organizing live concerts",
      icon: Icons.event_note,
      isSelected: true,
    ),
    ServiceModel(
      name: "Audio Engineering",
      desc: "High quality sound setup",
      icon: Icons.graphic_eq_rounded,
    ),
    ServiceModel(
      name: "Content Strategy",
      desc: "Scripting & talk topics",
      icon: Icons.lightbulb_outline_rounded,
    ),
    ServiceModel(
      name: "Broadcaster Support",
      desc: "24/7 technical assistance",
      icon: Icons.support_agent_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF19172B), Color(0xFF08070F)],
              ),
            ),
          ),
          
          // Cyan Glow at the bottom
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Full Progress Bar (Step 4/4)
                  _buildProgressBar(),

                  const SizedBox(height: 40),

                  const Text(
                    "Agency Services 💼",
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "What specialized services does your agency offer to the Nexus voice community?",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Services Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return GestureDetector(
                          onTap: () => setState(() => service.isSelected = !service.isSelected),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: service.isSelected 
                                  ? const Color(0xFF00D2FF).withValues(alpha: 0.1) 
                                  : Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: service.isSelected 
                                    ? const Color(0xFF00D2FF) 
                                    : Colors.white.withValues(alpha: 0.08),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: service.isSelected 
                                        ? const Color(0xFF00D2FF).withValues(alpha: 0.2) 
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    service.icon, 
                                    color: service.isSelected ? const Color(0xFF00D2FF) : Colors.white54,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  service.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  service.desc,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Finish Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D2FF), Color(0xFF8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Complete Setup",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
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
                    color: const Color(0xFF8B5CF6), // All steps completed
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

