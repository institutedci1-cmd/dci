import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../backend/models/student.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';

class CompactStudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const CompactStudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(8),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate.withAlpha(80),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Roll: ${student.rollNo}',
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).accent3,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          student.className,
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildAttendanceBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final initials = student.name.trim().isEmpty ? '?' : student.name.trim()[0].toUpperCase();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: student.photoUrl != null && student.photoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: student.photoUrl!,
                  fit: BoxFit.cover,
                  width: 36,
                  height: 36,
                  placeholder: (context, url) => Container(color: FlutterFlowTheme.of(context).accent4),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            : Text(
                initials,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildAttendanceBadge(BuildContext context) {
    // Placeholder logic for attendance percentage
    const percentage = 94;
    final color = percentage >= 75 ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
