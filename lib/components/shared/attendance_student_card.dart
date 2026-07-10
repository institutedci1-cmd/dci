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
    final theme = Theme.of(context);
    final isPresent = status == 'Present';
    final statusColor = isPresent ? AppColors.success : AppColors.error;
    
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      elevation: 0,
      border: BorderSide(
        color: statusColor.withValues(alpha: 0.2),
        width: 1,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              color: statusColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Checkbox(
              value: isPresent,
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Roll No: $rollNo',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                status.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
