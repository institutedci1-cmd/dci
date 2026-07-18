import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppSpacing {
  static const double zero = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

class AppSize {
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  
  static const double inputHeight = 52.0;
  static const double buttonHeight = 52.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 9999.0;
  
  static BorderRadius get standard => BorderRadius.circular(lg);
  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get input => BorderRadius.circular(md);
}

class AppShadows {
  static List<BoxShadow> get low => [
    BoxShadow(
      color: Colors.black.withAlpha(15),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTypography {
  // Title / Large Headings
  static TextStyle title = GoogleFonts.plusJakartaSans(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Section Header / Medium Headings
  static TextStyle section = GoogleFonts.plusJakartaSans(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body / Normal Text
  static TextStyle body = GoogleFonts.inter(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Label / Semi-bold Small
  static TextStyle label = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // Caption / Smallest Text
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button Text
  static TextStyle button = GoogleFonts.inter(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
