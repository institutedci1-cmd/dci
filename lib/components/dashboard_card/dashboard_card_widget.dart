import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/components/dashboard_card/dashboard_card_model.dart';
export 'package:d_c_i_teacher_app/components/dashboard_card/dashboard_card_model.dart';

class DashboardCardWidget extends StatefulWidget {
  const DashboardCardWidget({
    super.key,
    this.icon,
    required this.target,
    required this.title,
  });

  final Widget? icon;
  final String target;
  final String title;

  @override
  State<DashboardCardWidget> createState() => _DashboardCardWidgetState();
}

class _DashboardCardWidgetState extends State<DashboardCardWidget> {
  late DashboardCardModel _model;
  bool _isHovered = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _routeNameForTarget(String target) {
    return switch (target) {
      'DailyReport' => DailyReportFormWidget.routeName,
      'Attendance' => AttendanceTrackerWidget.routeName,
      'Homework' => HomeworkAssignmentWidget.routeName,
      'TeacherProfile' => TeacherProfileWidget.routeName,
      'Announcements' => AnnouncementsFeedWidget.routeName,
      'AboutDCI' => AboutDCIWidget.routeName,
      'Students' => StudentListWidget.routeName,
      'Exams' => ExamsDashboardWidget.routeName,
      'Results' => ExamsDashboardWidget.routeName,
      _ => HomeDashboardWidget.routeName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isHovered ? 1.02 : 1.0,
        child: InkWell(
          onTap: () {
            final routeName = _routeNameForTarget(widget.target);
            context.pushNamed(routeName);
          },
          borderRadius: AppRadius.card,
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: _isHovered ? AppColors.primary : theme.alternate,
                width: _isHovered ? 2.0 : 1.5,
              ),
              boxShadow: _isHovered ? AppShadows.medium : AppShadows.low,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: IconTheme(
                        data: const IconThemeData(
                          color: AppColors.primary,
                          size: 20,
                        ),
                        child: widget.icon ?? const Icon(Icons.apps_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
