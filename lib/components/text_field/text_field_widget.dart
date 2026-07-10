import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'text_field_model.dart';
export 'text_field_model.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    this.label = 'Label',
    this.labelPresent = true,
    this.helper = '',
    this.helperPresent = false,
    this.leadingIcon,
    this.leadingIconPresent = false,
    this.trailingIcon,
    this.trailingIconPresent = false,
    this.hint = '',
    this.value = '',
    this.onChange,
    this.onSubmit,
    this.validator,
    this.variant = 'outlined',
    this.error = false,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final bool labelPresent;
  final String helper;
  final bool helperPresent;
  final Widget? leadingIcon;
  final bool leadingIconPresent;
  final Widget? trailingIcon;
  final bool trailingIconPresent;
  final String hint;
  final String value;
  final void Function(String?)? onChange;
  final void Function(String?)? onSubmit;
  final String? Function(String?)? validator;
  final String variant;
  final bool error;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextFieldModel _model;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextFieldModel());
    _model.inputTextController ??= TextEditingController(text: widget.value);
    _model.inputFocusNode ??= FocusNode();
    _model.inputFocusNode!.addListener(_handleFocusChange);
    _model.inputTextControllerValidator = (context, val) => widget.validator?.call(val);
    _obscureText = widget.obscureText;

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _model.inputFocusNode!.hasFocus);
    }
  }

  @override
  void dispose() {
    _model.inputFocusNode?.removeListener(_handleFocusChange);
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: widget.error
                    ? AppColors.error
                    : (_isFocused ? AppColors.primary : AppColors.textSecondary),
                fontWeight: _isFocused ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: widget.variant == 'filled'
                ? AppColors.background
                : (widget.readOnly ? AppColors.background.withAlpha(128) : Colors.transparent),
            borderRadius: AppRadius.input,
            border: widget.variant == 'ghost' ? null : Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                if (widget.leadingIconPresent && widget.leadingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconTheme(
                      data: IconThemeData(
                        size: 20, 
                        color: _isFocused ? AppColors.primary : AppColors.textSecondary
                      ),
                      child: widget.leadingIcon!,
                    ),
                  ),
                Expanded(
                  child: TextFormField(
                    controller: _model.inputTextController,
                    focusNode: _model.inputFocusNode,
                    obscureText: _obscureText,
                    keyboardType: widget.keyboardType,
                    readOnly: widget.readOnly,
                    maxLines: widget.maxLines,
                    onChanged: widget.onChange,
                    onFieldSubmitted: widget.onSubmit,
                    validator: _model.inputTextControllerValidator.asValidator(context),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: FlutterFlowTheme.of(context).accent3,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: AppTypography.body,
                  ),
                ),
                if (widget.obscureText)
                  InkWell(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  )
                else if (widget.trailingIconPresent && widget.trailingIcon != null)
                  IconTheme(
                    data: const IconThemeData(size: 20, color: AppColors.textSecondary),
                    child: widget.trailingIcon!,
                  ),
              ],
            ),
          ),
        ),
        if (widget.helperPresent && widget.helper.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              widget.helper,
              style: AppTypography.caption.copyWith(
                color: widget.error ? AppColors.error : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
