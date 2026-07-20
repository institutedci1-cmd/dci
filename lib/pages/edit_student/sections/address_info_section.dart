import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/edit_student_model.dart';

class AddressInfoSection extends StatelessWidget {
  const AddressInfoSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final EditStudentModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: model.villageCityModel,
                updateCallback: onChanged,
                child: const TextFieldWidget(
                  label: 'Village/City',
                  hint: 'e.g. Mumbai',
                  variant: 'outlined',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: wrapWithModel(
                model: model.pinCodeModel,
                updateCallback: onChanged,
                child: const TextFieldWidget(
                  label: 'PIN Code',
                  hint: 'e.g. 400001',
                  variant: 'outlined',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: model.addressModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Full Address',
            hint: 'Street, House No, etc.',
            variant: 'outlined',
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
