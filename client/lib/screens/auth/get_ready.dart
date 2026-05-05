import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Ready',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08070F),
        fontFamily: 'Poppins',
      ),
      home: const ReadyToExplorePage(),
    );
  }
}

class ReadyToExplorePage extends StatefulWidget {
  const ReadyToExplorePage({super.key});

  @override
  State<ReadyToExplorePage> createState() => _ReadyToExplorePageState();
}

class _ReadyToExplorePageState extends State<ReadyToExplorePage>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    
    // Bounce Animation for Icon
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Rotation Animation for Background Glow
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Flashing Animation for Dots
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotateController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0B21), Color(0xFF08070F)],
              ),
            ),
          ),

          // 2. Rotating Galaxy Glow
          Center(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Success Icon with Bounce
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -10 * _bounceController.value),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00D2FF), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
                                blurRadius: 30,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text("✨", style: TextStyle(fontSize: 50)),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "You're all set!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Your Nexus identity is ready. High-quality voice rooms and amazing communities are waiting for you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Enter Button
                  Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D2FF), Color(0xFF8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
                          blurRadius: 35,
                          offset: const Offset(0, 15),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Enter Nexus Home",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _dotController,
                        builder: (context, child) {
                          double opacity = (index == 0) 
                              ? _dotController.value 
                              : (index == 1) 
                                  ? (_dotController.value > 0.5 ? _dotController.value : 0.2)
                                  : (1 - _dotController.value);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.2),
                                const Color(0xFF00D2FF),
                                opacity,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

