import '/backend/models/homework_assignment.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../shared/app_card.dart';
import 'package:flutter/material.dart';
import 'homework_card_model.dart';
export 'homework_card_model.dart';

class HomeworkCardWidget extends StatelessWidget {
  const HomeworkCardWidget({
    super.key,
    required this.assignment,
    this.onTap,
  });

  final HomeworkAssignment assignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPublished = assignment.status == 'published';
    
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPublished ? AppColors.success : AppColors.warning).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  assignment.status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPublished ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                'Due: ${assignment.dueDate}',
                style: theme.textTheme.labelSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${assignment.className} • ${assignment.subject}',
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            assignment.title,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          if (assignment.attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.attachment_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${assignment.attachments.length} attachment(s)',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
