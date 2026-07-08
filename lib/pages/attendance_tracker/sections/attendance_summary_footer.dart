import 'package:flutter/material.dart';
import '../../../shared/app_style.dart';
import '../../../shared/app_colors.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../components/shared/app_primary_button.dart';

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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            offset: const Offset(0, -4),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummary(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: AppPrimaryButton(
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Present', '$presentCount', AppColors.success),
          _buildSummaryItem('Absent', '$absentCount', AppColors.error),
          _buildSummaryItem('Rate', '${percentage.toStringAsFixed(1)}%', AppColors.secondary),
          _buildSummaryItem('Total', '${presentCount + absentCount}', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value, 
          style: AppTypography.body.copyWith(
            color: color, 
            fontWeight: FontWeight.bold, 
            fontSize: 20,
          ),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
