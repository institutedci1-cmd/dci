import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/models/homework.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../shared/app_card.dart';

class HomeworkCardWidget extends StatelessWidget {
  final Homework homework;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const HomeworkCardWidget({
    super.key,
    required this.homework,
    required this.onView,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd MMM yyyy').format(homework.assignedDate);

    return AppCard(
      elevation: 2,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${homework.className} • ${homework.subject}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            homework.chapter,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Homework: ${homework.homework}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body,
          ),
          if (homework.remarks.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Remarks: ${homework.remarks}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: 'View',
                onTap: onView,
              ),
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
              _buildActionButton(
                icon: Icons.copy_all_rounded,
                label: 'Copy',
                onTap: onDuplicate,
              ),
              _buildMoreMenu(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: homework.completed 
            ? AppColors.success.withValues(alpha: 0.1) 
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        homework.completed ? 'COMPLETED' : 'PENDING',
        style: TextStyle(
          color: homework.completed ? AppColors.success : AppColors.warning,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'delete') onDelete();
        if (value == 'share') onShare();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_rounded, size: 18, color: AppColors.success),
              SizedBox(width: 8),
              Text('Share PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }
}
