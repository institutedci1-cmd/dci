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
  final FormFieldController<String>? controller;
  final Function(String?) onChanged;
  final IconData? icon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.onChanged,
    this.value,
    this.controller,
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FlutterFlowDropDown<String>(
          controller: controller ?? FormFieldController<String>(value),
          options: options,
          onChanged: onChanged,
          height: 48,
          hintText: hintText,
          fillColor: AppColors.surface,
          borderRadius: AppRadius.md,
          borderWidth: 1,
          borderColor: AppColors.outline,
          hidesUnderline: true,
          textStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 14) ?? const TextStyle(fontSize: 14),
          icon: Icon(
            icon ?? Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          elevation: 0,
          margin: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, 0, AppSpacing.md, 0),
        ),
      ],
    );
  }
}
