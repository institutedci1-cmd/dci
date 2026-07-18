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
  final VoidCallback? onShare;

  const AttendanceSummaryFooter({
    super.key,
    required this.presentCount,
    required this.absentCount,
    required this.percentage,
    required this.isLoading,
    required this.isAlreadySubmitted,
    required this.onSubmit,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withAlpha(20),
            offset: const Offset(0, -2),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummary(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  if (onShare != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AppPrimaryButton(
                        text: '',
                        icon: Icons.share_rounded,
                        variant: 'outline',
                        width: 60,
                        onPressed: onShare,
                      ),
                    ),
                  Expanded(
                    child: AppPrimaryButton(
                      text: isAlreadySubmitted ? 'Update' : 'Submit Attendance',
                      isLoading: isLoading,
                      onPressed: onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildSummaryItem('Present', '$presentCount', AppColors.success)),
          Expanded(child: _buildSummaryItem('Absent', '$absentCount', AppColors.error)),
          Expanded(child: _buildSummaryItem('Rate', '${percentage.toStringAsFixed(0)}%', AppColors.secondary)),
          Expanded(child: _buildSummaryItem('Total', '${presentCount + absentCount}', AppColors.primary)),
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
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
