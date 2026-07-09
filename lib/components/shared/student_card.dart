import 'package:flutter/material.dart';
import '../../backend/models/student.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import 'app_card.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(context),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: 2,
                  children: [
                    _buildInfoItem(context, Icons.tag_rounded, 'Roll ${student.rollNo}'),
                    _buildInfoItem(context, Icons.class_rounded, student.className),
                  ],
                ),
                if (student.parentPhone != null && student.parentPhone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoItem(context, Icons.phone_rounded, student.parentPhone!),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final initials = student.name.trim().isEmpty ? '?' : student.name.trim()[0].toUpperCase();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary10,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: student.photoUrl != null && student.photoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(student.photoUrl!, fit: BoxFit.cover, width: 48, height: 48),
              )
            : Text(
                initials,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
