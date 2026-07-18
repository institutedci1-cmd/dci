import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppQuickActionButton extends StatelessWidget {
  const AppQuickActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final activeColor = color ?? theme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: activeColor.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activeColor.withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activeColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                color: activeColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
