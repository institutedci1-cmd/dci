import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/form_section_header/form_section_header_widget.dart';
import '/components/student_counter/student_counter_widget.dart';
import '../daily_report_form_model.dart';

class StudentCountSection extends StatelessWidget {
  const StudentCountSection({
    super.key,
    required this.model,
    required this.presentCount,
    required this.absentCount,
    required this.onPresentChanged,
    required this.onAbsentChanged,
    required this.onChanged,
  });

  final DailyReportFormModel model;
  final int presentCount;
  final int absentCount;
  final Function(int) onPresentChanged;
  final Function(int) onAbsentChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: model.formSectionHeaderModel3,
          updateCallback: onChanged,
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.people_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Student Count',
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: model.studentCounterModel1,
                updateCallback: onChanged,
                child: StudentCounterWidget(
                  label: 'Present',
                  subtitle: 'Students in class',
                  value: presentCount.toString().padLeft(2, '0'),
                  onDecrement: () {
                    if (presentCount > 0) onPresentChanged(presentCount - 1);
                  },
                  onIncrement: () => onPresentChanged(presentCount + 1),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: model.studentCounterModel2,
                updateCallback: onChanged,
                child: StudentCounterWidget(
                  label: 'Absent',
                  subtitle: 'Students missing',
                  value: absentCount.toString().padLeft(2, '0'),
                  onDecrement: () {
                    if (absentCount > 0) onAbsentChanged(absentCount - 1);
                  },
                  onIncrement: () => onAbsentChanged(absentCount + 1),
                ),
              ),
            ),
          ].divide(const SizedBox(width: 16.0)),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }
}
