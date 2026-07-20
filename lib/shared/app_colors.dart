import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Royal Blue (Primary) & Vibrant Orange (Accent)
  static const Color primary = Color(0xFF1565C0); // Royal Blue 800
  static const Color primaryDark = Color(0xFF0D47A1); // Royal Blue 900
  static const Color primaryLight = Color(0xFF1E88E5); // Royal Blue 600
  
  static const Color secondary = Color(0xFFFB8C00); // Orange 600 (Accent)
  static const Color secondaryDark = Color(0xFFEF6C00); // Orange 800
  static const Color secondaryLight = Color(0xFFFFA726); // Orange 400

  static const Color tertiary = Color(0xFF1A237E); // Indigo 900 (Dark Support)

  // Status Colors (Accessible Shades)
  static const Color success = Color(0xFF2E7D32); // Green 800
  static const Color warning = Color(0xFFFB8C00); // Orange 600
  static const Color error = Color(0xFFC62828); // Red 800
  static const Color info = Color(0xFF0277BD); // Blue 800
  
  // Neutral Colors (The Enterprise ERP Look)
  static const Color background = Color(0xFFF5F7FA); // Soft Grey-Blue Background
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121); // Dark Grey / Black
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textMuted = Color(0xFF9E9E9E); // Grey 500
  static const Color outline = Color(0xFFE0E0E0); // Grey 300

  // Opacity variations for Backgrounds/Badges
  static Color successSubtle = const Color(0xFFE8F5E9); 
  static Color warningSubtle = const Color(0xFFFFF3E0); 
  static Color errorSubtle = const Color(0xFFFFEBEE); 
  static Color infoSubtle = const Color(0xFFE1F5FE); 
  static Color primarySubtle = const Color(0xFFE3F2FD); 
}
