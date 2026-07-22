import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(
          top: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, 0, Icons.home_rounded, 'Home'),
              _buildItem(context, 1, Icons.description_outlined, 'Reports'),
              _buildItem(context, 2, Icons.event_note_outlined, 'Attend.'),
              _buildItem(context, 3, Icons.account_circle_outlined, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? FlutterFlowTheme.of(context).primary
        : FlutterFlowTheme.of(context).secondaryText;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? icon : _getOutlineIcon(icon),
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    color: color,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOutlineIcon(IconData icon) {
    if (icon == Icons.home_rounded) return Icons.home_outlined;
    if (icon == Icons.description_outlined) return Icons.description_outlined;
    if (icon == Icons.event_note_outlined) return Icons.event_note_outlined;
    if (icon == Icons.account_circle_outlined) return Icons.account_circle_outlined;
    return icon;
  }
}
