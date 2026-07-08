import 'package:flutter/material.dart';
import '../../../shared/app_style.dart';
import '../../../flutter_flow/flutter_flow_drop_down.dart';
import '../../../flutter_flow/form_field_controller.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import '../../../components/shared/app_search_bar.dart';
import '../attendance_tracker_model.dart';

class AttendanceSelectionSection extends StatelessWidget {
  final AttendanceTrackerModel model;
  final List<String> classOptions;
  final VoidCallback onClassChanged;
  final VoidCallback onDateChanged;
  final VoidCallback onSubjectChanged;

  const AttendanceSelectionSection({
    super.key,
    required this.model,
    required this.classOptions,
    required this.onClassChanged,
    required this.onDateChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDateChanged,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: FlutterFlowTheme.of(context).primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(dateTimeFormat('yMMMd', model.selectedDate)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: model.classDropdownController ??= FormFieldController<String>(model.selectedClass),
                  options: classOptions,
                  onChanged: (val) {
                    model.selectedClass = val;
                    onClassChanged();
                  },
                  height: 48,
                  hintText: 'Class',
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: AppRadius.md,
                  borderWidth: 1,
                  borderColor: FlutterFlowTheme.of(context).alternate,
                  hidesUnderline: true,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium,
                  elevation: 2.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSearchBar(
            controller: model.subjectFieldModel.inputTextController,
            hintText: 'Enter Subject Name...',
            onChanged: (_) => onSubjectChanged(),
          ),
        ],
      ),
    );
  }
}
