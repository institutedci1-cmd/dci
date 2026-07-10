import 'package:flutter/material.dart';
import '../../../shared/app_style.dart';
import '../../../shared/app_colors.dart';
import '../../../flutter_flow/flutter_flow_drop_down.dart';
import '../../../flutter_flow/form_field_controller.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import '../../../components/shared/app_search_bar.dart';
import '../../../components/shared/app_button.dart';
import '../attendance_tracker_model.dart';

class AttendanceSelectionSection extends StatelessWidget {
  final AttendanceTrackerModel model;
  final List<String> classOptions;
  final VoidCallback onDateChanged;
  final Function(String?) onClassChanged;
  final Function(String?) onSubjectChanged;
  final VoidCallback onFetchStudents;
  final bool isLoading;

  const AttendanceSelectionSection({
    super.key,
    required this.model,
    required this.classOptions,
    required this.onDateChanged,
    required this.onClassChanged,
    required this.onSubjectChanged,
    required this.onFetchStudents,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDateChanged,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          dateTimeFormat('yMMMd', model.selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: model.classDropdownController ??= FormFieldController<String>(model.selectedClass),
                  options: classOptions,
                  onChanged: onClassChanged,
                  height: 48,
                  hintText: 'Select Class',
                  fillColor: AppColors.surface,
                  borderRadius: AppRadius.md,
                  borderWidth: 1,
                  borderColor: AppColors.outline,
                  hidesUnderline: true,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14) ?? const TextStyle(fontSize: 14),
                  elevation: 0,
                  margin: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, 0, AppSpacing.md, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSearchBar(
            controller: model.subjectFieldModel.inputTextController,
            hintText: 'Enter subject name...',
            onChanged: onSubjectChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'Load Student List',
            onPressed: onFetchStudents,
            isLoading: isLoading,
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
