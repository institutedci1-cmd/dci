import 'package:flutter/material.dart';
import '../../../shared/app_style.dart';
import '../../../shared/app_colors.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../components/shared/app_button.dart';

class AttendanceSummaryFooter extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final double percentage;
  final bool isLoading;
  final bool isAlreadySubmitted;
  final VoidCallback onSubmit;

  const AttendanceSummaryFooter({
    super.key,
    required this.presentCount,
    required this.absentCount,
    required this.percentage,
    required this.isLoading,
    required this.isAlreadySubmitted,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummary(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: AppButton(
                text: isAlreadySubmitted ? 'Update Attendance' : 'Submit Attendance',
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem(context, 'Present', '$presentCount', AppColors.success),
          _buildSummaryItem(context, 'Absent', '$absentCount', AppColors.error),
          _buildSummaryItem(context, 'Rate', '${percentage.toStringAsFixed(1)}%', AppColors.accent),
          _buildSummaryItem(context, 'Total', '${presentCount + absentCount}', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value, 
          style: theme.textTheme.titleLarge?.copyWith(
            color: color, 
            fontWeight: FontWeight.bold, 
          ),
        ),
        Text(
          label, 
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
