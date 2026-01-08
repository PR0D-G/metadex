import 'package:flutter/material.dart';

class GameTheme {
  // Colors
  static const Color darkBackground = Color(0xFF141028); // Deep Purple/Blue
  static const Color cardBackground = Color(0xFF252140);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFAA8822);
  static const Color parchment = Color(0xFFF5E6C4);
  static const Color parchmentText = Color(0xFF3E362A);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight, gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient metallicGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF4A4A4A), Color(0xFF2C2C2C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const BoxDecoration appBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2B2B45), Color(0xFF141028)],
    ),
  );

  // Decorations
  static BoxDecoration goldBorderDecoration = BoxDecoration(
      color: cardBackground,
      border: Border.all(width: 3, color: gold),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(2, 2)),
        BoxShadow(color: gold.withOpacity(0.3), blurRadius: 6, spreadRadius: 1),
      ],
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2A2645), Color(0xFF1F1B38)],
      ));

  static BoxDecoration parchmentDecoration = BoxDecoration(
      color: parchment,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Color(0xFF8B7355), width: 1),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: Offset(1, 1))
      ]);

  static TextStyle headingStyle = const TextStyle(
    fontFamily: 'Georgia', // Serif fallback
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: parchment,
    shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))],
  );
}
