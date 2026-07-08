import 'package:flutter/material.dart';
import '/components/button/button_widget.dart';
import '/components/form_label/form_label_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../homework_assignment_model.dart';

class DueDateSection extends StatelessWidget {
  const DueDateSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final HomeworkAssignmentModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: model.formLabelModel4,
          updateCallback: onChanged,
          child: const FormLabelWidget(label: 'Due Date'),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                  const SizedBox(width: 16),
                  Text(
                    model.dueDate != null ? dateTimeFormat('yMMMd', model.dueDate) : 'Select Due Date',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ),
              wrapWithModel(
                model: model.buttonModel1,
                updateCallback: onChanged,
                child: ButtonWidget(
                  content: 'Change',
                  variant: 'ghost',
                  size: 'small',
                  onPressed: () async {
                    final datePickedDate = await showDatePicker(
                      context: context,
                      initialDate: model.dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                    );
                    if (datePickedDate != null) {
                      model.dueDate = datePickedDate;
                      onChanged();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }
}
