import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/main_screens/voice_rooms_explorer.dart';

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
        // Disable the browser's text-selection highlight on Flutter web
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.transparent,
          selectionHandleColor: Colors.transparent,
        ),
      ),
      home: const VoiceRoomsExplorerScreen(),
    );
  }
}
