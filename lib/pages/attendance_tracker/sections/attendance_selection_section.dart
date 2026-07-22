import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/attendance_tracker/attendance_tracker_model.dart';

class AttendanceSelectionSection extends StatelessWidget {
  final AttendanceTrackerModel model;
  final List<String> classOptions;
  final List<String> subjectOptions;
  final VoidCallback onClassChanged;
  final VoidCallback onDateChanged;
  final VoidCallback onSubjectChanged;

  const AttendanceSelectionSection({
    super.key,
    required this.model,
    required this.classOptions,
    required this.subjectOptions,
    required this.onClassChanged,
    required this.onDateChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are synchronized with current options
    // Only clear if classOptions is NOT empty (meaning data has loaded)
    if (classOptions.isNotEmpty && 
        model.selectedClass != null && 
        !classOptions.contains(model.selectedClass)) {
      model.selectedClass = null;
      model.classDropdownController?.value = null;
    }
    
    final bool isLoadingClasses = classOptions.isEmpty;
    final List<String> effectiveClassOptions = isLoadingClasses ? <String>['Loading Classes...'] : classOptions;
    
    final List<String> effectiveSubjectOptions = subjectOptions.isEmpty 
        ? <String>['English', 'Marathi', 'Math', 'Science'] 
        : subjectOptions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: onDateChanged,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: FlutterFlowTheme.of(context).primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateTimeFormat('yMMMd', model.selectedDate),
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropDownWidget(
                  label: 'Class',
                  labelPresent: false,
                  controller: model.classDropdownController!,
                  options: effectiveClassOptions,
                  onChanged: (val) {
                    if (val == 'Loading Classes...') return;
                    model.selectedClass = val;
                    onClassChanged();
                  },
                  disabled: isLoadingClasses,
                  height: 40,
                  hint: 'Class',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: DropDownWidget(
                  label: 'Subject',
                  labelPresent: false,
                  controller: model.subjectDropdownController!,
                  options: effectiveSubjectOptions,
                  onChanged: (val) {
                    model.selectedSubject = val;
                    onSubjectChanged();
                  },
                  height: 40,
                  hint: 'Subject',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
