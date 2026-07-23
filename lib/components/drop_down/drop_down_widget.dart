import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_drop_down.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_model.dart';
export 'package:d_c_i_teacher_app/components/drop_down/drop_down_model.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({
    super.key,
    required this.options,
    this.optionLabels,
    this.controller,
    this.onChanged,
    this.initialValue,
    this.label = 'Label',
    this.labelPresent = true,
    this.hint = 'Select Option',
    this.icon,
    this.fullWidth = true,
    this.width,
    this.height = 52.0,
    this.error = false,
    this.disabled = false,
    this.isSearchable = false,
  }) : super();

  final List<String> options;
  final List<String>? optionLabels;
  final FormFieldController<String>? controller;
  final String? initialValue;
  final void Function(String?)? onChanged;
  final String label;
  final bool labelPresent;
  final String hint;
  final Widget? icon;
  final bool fullWidth;
  final double? width;
  final double height;
  final bool error;
  final bool disabled;
  final bool isSearchable;

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  late DropDownModel _model;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  FormFieldController<String>? _localController;

  FormFieldController<String> get _effectiveController =>
      widget.controller ??
      (_localController ??= FormFieldController<String>(widget.initialValue));

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DropDownModel());
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DropDownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && _localController != null) {
      _localController!.value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final borderColor = widget.error 
        ? AppColors.error 
        : (_isFocused ? AppColors.primary : AppColors.outline);
    
    final borderWidth = _isFocused || widget.error ? 2.0 : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.labelPresent)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              widget.label,
              style: AppTypography.label.copyWith(
                color: widget.error ? AppColors.error : (_isFocused ? AppColors.primary : AppColors.textSecondary),
                fontWeight: _isFocused ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        FlutterFlowDropDown<String>(
          controller: _effectiveController,
          options: widget.options,
          optionLabels: widget.optionLabels,
          onChanged: widget.onChanged,
          width: widget.width ?? (widget.fullWidth ? double.infinity : 200.0),
          height: widget.height,
          textStyle: AppTypography.body.copyWith(
            fontSize: 15.0,
            color: theme.primaryText,
          ),
          hintText: widget.hint,
          icon: widget.icon ?? Icon(
            Icons.arrow_drop_down_rounded,
            color: _isFocused ? AppColors.primary : AppColors.textSecondary,
            size: 24.0,
          ),
          fillColor: theme.secondaryBackground,
          elevation: 2.0,
          borderColor: borderColor,
          borderWidth: borderWidth,
          borderRadius: 12.0,
          margin: const EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
          hidesUnderline: true,
          disabled: widget.disabled,
          isSearchable: widget.isSearchable,
        ),
      ],
    );
  }
}
