import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'dashboard_card_model.dart';
export 'dashboard_card_model.dart';

class DashboardCardWidget extends StatefulWidget {
  const DashboardCardWidget({
    super.key,
    Color? bgColor,
    this.icon,
    Color? iconColor,
    String? target,
    String? title,
  })  : bgColor = bgColor ?? const Color(0x00000000),
        iconColor = iconColor ?? const Color(0x00000000),
        target = target ?? 'DailyReport',
        title = title ?? 'Daily Report';

  final Color bgColor;
  final Widget? icon;
  final Color iconColor;
  final String target;
  final String title;

  @override
  State<DashboardCardWidget> createState() => _DashboardCardWidgetState();
}

class _DashboardCardWidgetState extends State<DashboardCardWidget> {
  late DashboardCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  String _routeNameForTarget(String target) {
    final routeName = switch (target) {
      'DailyReport' => ReportsDashboardWidget.routeName,
      'Attendance' => AttendanceDashboardWidget.routeName,
      'Homework' => HomeworkAssignmentWidget.routeName,
      'TeacherProfile' => TeacherProfileWidget.routeName,
      'Announcements' => AnnouncementsFeedWidget.routeName,
      'AboutDCI' => AboutDCIWidget.routeName,
      'Students' => StudentListWidget.routeName,
      _ => ReportsDashboardWidget.routeName,
    };
    return routeName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return InkWell(
      onTap: () async {
        try {
          final routeName = _routeNameForTarget(widget.target);
          context.pushNamed(routeName);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigation error: $e'),
            ),
          );
        }
      },
      borderRadius: AppRadius.card,
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: theme.alternate,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withAlpha(10),
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppSize.iconXl,
                height: AppSize.iconXl,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: const AlignmentDirectional(0, 0),
                child: IconTheme(
                  data: const IconThemeData(
                    color: AppColors.primary,
                    size: AppSize.iconMd,
                  ),
                  child: widget.icon!,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
