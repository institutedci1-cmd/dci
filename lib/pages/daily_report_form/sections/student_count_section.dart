import 'package:flutter/material.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/app_colors.dart';
import '../../../../components/shared/app_card.dart';
import '../daily_report_form_model.dart';

class StudentCountSection extends StatelessWidget {
  const StudentCountSection({
    super.key,
    required this.model,
    required this.presentCount,
    required this.absentCount,
    required this.onPresentChanged,
    required this.onAbsentChanged,
    required this.onChanged,
  });

  final DailyReportFormModel model;
  final int presentCount;
  final int absentCount;
  final Function(int) onPresentChanged;
  final Function(int) onAbsentChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCounterCard(
          context,
          label: 'Students Present',
          subtitle: 'Number of students attending',
          value: presentCount,
          icon: Icons.person_search_rounded,
          color: AppColors.success,
          onChanged: onPresentChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCounterCard(
          context,
          label: 'Students Absent',
          subtitle: 'Number of students missing',
          value: absentCount,
          icon: Icons.person_off_rounded,
          color: AppColors.error,
          onChanged: onAbsentChanged,
        ),
      ],
    );
  }

  Widget _buildCounterCard(
    BuildContext context, {
    required String label,
    required String subtitle,
    required int value,
    required IconData icon,
    required Color color,
    required Function(int) onChanged,
  }) {
    final theme = Theme.of(context);
    
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelLarge),
                Text(subtitle, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Row(
            children: [
              _buildRoundButton(
                icon: Icons.remove_rounded,
                onTap: value > 0 ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 32,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildRoundButton(
                icon: Icons.add_rounded,
                onTap: () => onChanged(value + 1),
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({required IconData icon, VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline),
          color: onTap == null ? AppColors.background : Colors.transparent,
        ),
        child: Icon(icon, size: 20, color: onTap == null ? AppColors.textTertiary : (color ?? AppColors.textPrimary)),
      ),
    );
  }
}
