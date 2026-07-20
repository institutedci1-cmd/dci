import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/form_section_header/form_section_header_widget.dart';
import 'package:d_c_i_teacher_app/components/student_counter/student_counter_widget.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/daily_report_form_model.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: wrapWithModel(
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
            ),
            if (presentCount == 0 && absentCount == 0)
              InkWell(
                onTap: () {
                  // In a real app, we might fetch the actual student count for the class.
                  // For now, we'll set a reasonable default or let them increment.
                  onPresentChanged(25); 
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Default (25)',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
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
