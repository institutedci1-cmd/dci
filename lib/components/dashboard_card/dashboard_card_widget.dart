import '../../flutter_flow/flutter_flow_util.dart';
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
      'MonthlyReport' => MonthlyReportWidget.routeName,
      'Settings' => SettingsWidget.routeName,
      'AboutDeshmukh' => AboutDeshmukhWidget.routeName,
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
      padding: const EdgeInsets.all(10.0), // Reduced from 14 to save space
      borderRadius: 16.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduced padding
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconTheme(
              data: const IconThemeData(color: AppColors.primary, size: 22), // Slightly smaller icon
              child: icon,
            ),
          ),
          const SizedBox(height: 6), // Tightened gap
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14, // Slightly smaller font
              ),
            ),
          ),
        ],
      ),
    );
  }
}
