import 'package:flutter/material.dart';
import '../../../shared/app_style.dart';
import '../../../shared/app_colors.dart';
import '../../../flutter_flow/flutter_flow_drop_down.dart';
import '../../../flutter_flow/form_field_controller.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import '../../../components/shared/app_search_bar.dart';
import '../../../components/shared/app_card.dart';
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDateChanged,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    height: 52,
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
                          style: theme.textTheme.bodyMedium,
                        ),
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
                  height: 52,
                  hintText: 'Select Class',
                  fillColor: AppColors.surface,
                  borderRadius: AppRadius.md,
                  borderWidth: 1,
                  borderColor: AppColors.outline,
                  hidesUnderline: true,
                  textStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
                  elevation: 0,
                  margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSearchBar(
            controller: model.subjectFieldModel.inputTextController,
            hintText: 'Enter subject name...',
            onChanged: (_) => onSubjectChanged(),
          ),
        ],
      ),
    );
  }
}
