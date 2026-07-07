import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextInputType keyboardType;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextFieldModel _model;
  bool _obscureText = false;

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
    _model.inputTextControllerValidator = (context, val) => widget.validator?.call(val);
    _obscureText = widget.obscureText;

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.labelPresent)
          Text(
            widget.label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(),
                  color: widget.error
                      ? FlutterFlowTheme.of(context).error
                      : FlutterFlowTheme.of(context).primaryText,
                ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.variant == 'filled'
                ? FlutterFlowTheme.of(context).secondaryBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: widget.error
                  ? FlutterFlowTheme.of(context).error
                  : (widget.variant == 'ghost' ? Colors.transparent : FlutterFlowTheme.of(context).alternate),
              width: widget.variant == 'ghost' ? 0 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                if (widget.leadingIconPresent && widget.leadingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: widget.leadingIcon!,
                  ),
                Expanded(
                  child: TextFormField(
                    controller: _model.inputTextController,
                    focusNode: _model.inputFocusNode,
                    obscureText: _obscureText,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChange,
                    onFieldSubmitted: widget.onSubmit,
                    validator: _model.inputTextControllerValidator.asValidator(context),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).accent3,
                          ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                  ),
                ),
                if (widget.obscureText)
                  InkWell(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 22,
                    ),
                  )
                else if (widget.trailingIconPresent && widget.trailingIcon != null)
                  widget.trailingIcon!,
              ],
            ),
          ),
        ),
        if (widget.helperPresent)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.helper,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: widget.error
                        ? FlutterFlowTheme.of(context).error
                        : FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
      ],
    );
  }
}
