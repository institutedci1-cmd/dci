import 'package:flutter/material.dart';
import '../../backend/models/student.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';

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
    return Container(
      decoration: const BoxDecoration(),
      child: Material(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: AppRadius.standard,
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.standard,
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.standard,
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
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: 2,
                          children: [
                            _buildInfoChip(context, 'Roll', student.rollNo, Icons.tag_rounded),
                            _buildInfoChip(context, 'Class', student.className, Icons.class_rounded),
                          ],
                        ),
                        if (student.parentPhone != null && student.parentPhone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  student.parentPhone!,
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildAttendanceBadge(context),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final initials = student.name.trim().isEmpty ? '?' : student.name.trim()[0].toUpperCase();
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha((0.1 * 255).toInt()),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withAlpha((0.2 * 255).toInt())),
      ),
      child: Center(
        child: student.photoUrl != null && student.photoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(student.photoUrl!, fit: BoxFit.cover, width: 52, height: 52),
              )
            : Text(
                initials,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTypography.caption,
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceBadge(BuildContext context) {
    // Placeholder logic for attendance percentage
    const percentage = 94; 
    final color = percentage >= 75 ? AppColors.success : AppColors.error;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$percentage%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          'Attend',
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
