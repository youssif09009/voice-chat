import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({super.key, required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70),
        label: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
