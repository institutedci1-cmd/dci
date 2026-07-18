import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'student_counter_model.dart';
export 'student_counter_model.dart';

class StudentCounterWidget extends StatefulWidget {
  const StudentCounterWidget({
    super.key,
    this.label = 'Present',
    this.subtitle = 'Students in class',
    this.value = '42',
    this.onDecrement,
    this.onIncrement,
  });

  final String label;
  final String subtitle;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  State<StudentCounterWidget> createState() => _StudentCounterWidgetState();
}

class _StudentCounterWidgetState extends State<StudentCounterWidget> {
  late StudentCounterModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentCounterModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: AppRadius.standard,
        border: Border.all(
          color: theme.alternate,
          width: 1.0,
        ),
        boxShadow: AppShadows.low,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ].divide(const SizedBox(height: 2.0)),
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCounterButton(
                  icon: Icons.remove_circle_outline_rounded,
                  color: theme.secondaryText,
                  onPressed: widget.onDecrement,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    widget.value,
                    style: AppTypography.section.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                _buildCounterButton(
                  icon: Icons.add_circle_outline_rounded,
                  color: theme.primary,
                  onPressed: widget.onIncrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return FlutterFlowIconButton(
      borderRadius: 8.0,
      buttonSize: 36.0,
      fillColor: Colors.transparent,
      icon: Icon(
        icon,
        color: color,
        size: 24.0,
      ),
      onPressed: onPressed,
    );
  }
}
