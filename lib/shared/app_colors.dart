import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Enterprise Blue)
  static const Color primary = Color(0xFF0F172A); // Slate 900 - Deep, professional
  static const Color primaryLight = Color(0xFF334155); // Slate 700
  static const Color accent = Color(0xFF3B82F6); // Blue 500 - Vibrant action color
  
  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color tertiary = Color(0xFFF1F5F9); // Slate 100

  // Status Colors (Subtle & Clear)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF0EA5E9); // Sky 500
  
  // Neutral Colors (Modern Minimal)
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color outline = Color(0xFFE2E8F0); // Slate 200

  // Opacity variations for overlays/badges
  static Color get primary10 => primary.withAlpha((0.1 * 255).toInt());
  static Color get accent10 => accent.withAlpha((0.1 * 255).toInt());
  static Color get success10 => success.withAlpha((0.1 * 255).toInt());
  static Color get warning10 => warning.withAlpha((0.1 * 255).toInt());
  static Color get error10 => error.withAlpha((0.1 * 255).toInt());
  
  // Legacy aliases for compatibility during refactor
  static Color get successLight => success10;
  static Color get warningLight => warning10;
  static Color get errorLight => error10;
  static Color get infoLight => info.withAlpha((0.1 * 255).toInt());
}
