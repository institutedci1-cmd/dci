import 'package:flutter/material.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import 'app_card.dart';

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
    
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      border: BorderSide(
        color: statusColor.withAlpha((0.3 * 255).toInt()),
        width: 1.5,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 72,
            color: statusColor,
          ),
          const SizedBox(width: AppSpacing.md),
          Checkbox(
            value: isPresent,
            activeColor: AppColors.success,
            onChanged: (_) => onTap(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Roll No: $rollNo',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPresent ? AppColors.successLight : AppColors.errorLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
