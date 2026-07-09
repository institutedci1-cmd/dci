import '../../flutter_flow/flutter_flow_util.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../index.dart';
import 'package:flutter/material.dart';
import '../shared/app_card.dart';

class DashboardCardWidget extends StatelessWidget {
  final String title;
  final Widget icon;
  final String target;

  const DashboardCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.target,
  });

  String _routeNameForTarget(String target) {
    return switch (target) {
      'DailyReport' => DailyReportFormWidget.routeName,
      'Attendance' => AttendanceDashboardWidget.routeName,
      'Homework' => HomeworkAssignmentWidget.routeName,
      'TeacherProfile' => TeacherProfileWidget.routeName,
      'Announcements' => AnnouncementsFeedWidget.routeName,
      'Students' => StudentListWidget.routeName,
      _ => ReportsDashboardWidget.routeName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () {
        try {
          final routeName = _routeNameForTarget(target);
          context.pushNamed(routeName);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigation error: $e')),
          );
        }
      },
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: IconTheme(
              data: const IconThemeData(color: AppColors.primary, size: 24),
              child: icon,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
