import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';

class AttendanceStudentCard extends StatelessWidget {
  final String name;
  final String rollNo;
  final String status;
  final VoidCallback onTap;

  const AttendanceStudentCard({
    super.key,
    required this.name,
    required this.rollNo,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'Present';
    final statusColor = isPresent ? AppColors.success : AppColors.error;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withAlpha(isPresent ? 40 : 80),
              width: isPresent ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // We use a custom checkbox-like icon to avoid event bubbling issues
              Icon(
                isPresent ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isPresent ? AppColors.success : FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isPresent ? null : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Roll No: $rollNo',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(isPresent ? 20 : 40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
