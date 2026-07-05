import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      'DailyReport' => DailyReportFormWidget.routeName,
      'Attendance' => AttendanceTrackerWidget.routeName,
      'Homework' => HomeworkAssignmentWidget.routeName,
      'TeacherProfile' => TeacherProfileWidget.routeName,
      'Announcements' => AnnouncementsFeedWidget.routeName,
      'AboutDeshmukh' => AboutDeshmukhWidget.routeName,
      _ => DailyReportFormWidget.routeName,
    };
    return routeName;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
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
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      widget.bgColor,
                      const Color(0x00000000),
                    ),
                    borderRadius: BorderRadius.circular(9999.0),
                    shape: BoxShape.rectangle,
                  ),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: widget.icon!,
                ),
                Text(
                  valueOrDefault<String>(
                    widget.title,
                    'Daily Report',
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
              ].divide(const SizedBox(height: 16.0)),
            ),
          ),
        ),
      ),
    );
  }
}
