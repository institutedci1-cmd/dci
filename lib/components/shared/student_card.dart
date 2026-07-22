import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';

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
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.standard,
        border: Border.all(
          color: theme.alternate,
          width: 1,
        ),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: AppRadius.standard,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _buildInfoChip(context, 'Roll', student.rollNo, Icons.tag_rounded),
                          _buildInfoChip(context, 'Class', student.className, Icons.class_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildAttendanceBadge(context),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final initials = student.name.trim().isEmpty ? '?' : student.name.trim()[0].toUpperCase();
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.primary.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: student.photoUrl != null && student.photoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: CachedNetworkImage(
                  imageUrl: student.photoUrl!,
                  fit: BoxFit.cover,
                  width: 52,
                  height: 52,
                  placeholder: (context, url) => Container(color: theme.accent4),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            : Text(
                initials,
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.secondaryText),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceBadge(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.success.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '94%',
            style: TextStyle(
              color: theme.success,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            'Attend',
            style: AppTypography.caption.copyWith(fontSize: 10, color: theme.success),
          ),
        ],
      ),
    );
  }
}
