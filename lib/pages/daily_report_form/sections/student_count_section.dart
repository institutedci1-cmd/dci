import 'package:flutter/material.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/app_colors.dart';
import '../../../../components/shared/app_text_field.dart';
import '../daily_report_form_model.dart';

class StudentCountSection extends StatelessWidget {
  const StudentCountSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final DailyReportFormModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            label: 'Present',
            hintText: '0',
            controller: model.presentController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.person_search_rounded,
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            label: 'Absent',
            hintText: '0',
            controller: model.absentController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.person_off_rounded,
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }
}
