import 'package:flutter/material.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../flutter_flow/flutter_flow_drop_down.dart';
import '../../flutter_flow/form_field_controller.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final String hintText;
  final List<String> options;
  final String? value;
  final Function(String?) onChanged;
  final IconData? icon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.onChanged,
    this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        FlutterFlowDropDown<String>(
          controller: FormFieldController<String>(value),
          options: options,
          onChanged: onChanged,
          height: 52,
          hintText: hintText,
          fillColor: AppColors.surface,
          borderRadius: AppRadius.md,
          borderWidth: 1,
          borderColor: AppColors.outline,
          hidesUnderline: true,
          textStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
          icon: Icon(
            icon ?? Icons.keyboard_arrow_down_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          elevation: 0,
          margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        ),
      ],
    );
  }
}
