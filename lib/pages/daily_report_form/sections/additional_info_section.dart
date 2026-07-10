import 'package:flutter/material.dart';
import '../../../../shared/app_style.dart';
import '../../../../components/shared/app_card.dart';
import '../../../../components/shared/app_text_field.dart';
import '../daily_report_form_model.dart';

class AdditionalInfoSection extends StatelessWidget {
  const AdditionalInfoSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final DailyReportFormModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            label: 'Homework Assigned',
            hintText: 'Describe assignments given to students',
            controller: model.textFieldModel5.inputTextController,
            prefixIcon: Icons.edit_note_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Remarks',
            hintText: 'Other observations or notes',
            controller: model.textFieldModel6.inputTextController,
            prefixIcon: Icons.notes_rounded,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
