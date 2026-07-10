import 'package:flutter/material.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/app_colors.dart';
import '../../../../components/shared/app_card.dart';
import '../../../../flutter_flow/flutter_flow_util.dart';
import '../homework_assignment_model.dart';

class DueDateSection extends StatelessWidget {
  const DueDateSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final HomeworkAssignmentModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () async {
        final datePickedDate = await showDatePicker(
          context: context,
          initialDate: model.dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2050),
        );
        if (datePickedDate != null) {
          model.dueDate = datePickedDate;
          onChanged();
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due Date', style: theme.textTheme.labelLarge),
                Text(
                  model.dueDate != null ? dateTimeFormat('yMMMd', model.dueDate) : 'Select a deadline',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: model.dueDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                    fontWeight: model.dueDate != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_calendar_rounded, color: AppColors.accent, size: 20),
        ],
      ),
    );
  }
}
