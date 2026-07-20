import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/components/button/button_model.dart';
export 'package:d_c_i_teacher_app/components/button/button_model.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    this.icon,
    bool? iconPresent,
    this.iconEnd,
    bool? iconEndPresent,
    String? content,
    String? variant,
    String? size,
    bool? fullWidth,
    bool? loading,
    bool? disabled,
    this.onPressed,
  })  : iconPresent = iconPresent ?? false,
        iconEndPresent = iconEndPresent ?? false,
        content = content ?? 'Button',
        variant = variant ?? 'primary',
        size = size ?? 'medium',
        fullWidth = fullWidth ?? false,
        loading = loading ?? false,
        disabled = disabled ?? false;

  final Widget? icon;
  final bool iconPresent;
  final Widget? iconEnd;
  final bool iconEndPresent;
  final String content;
  final String variant;
  final String size;
  final bool fullWidth;
  final bool loading;
  final bool disabled;
  final VoidCallback? onPressed;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  late ButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.disabled || widget.loading;
    
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case 'secondary':
        bgColor = FlutterFlowTheme.of(context).secondary;
        textColor = Colors.white;
        break;
      case 'outline':
        bgColor = Colors.transparent;
        textColor = FlutterFlowTheme.of(context).primary;
        borderSide = BorderSide(color: FlutterFlowTheme.of(context).primary, width: 1.5);
        break;
      case 'ghost':
        bgColor = Colors.transparent;
        textColor = FlutterFlowTheme.of(context).primaryText;
        break;
      case 'destructive':
        bgColor = FlutterFlowTheme.of(context).error;
        textColor = Colors.white;
        break;
      case 'primary':
      default:
        bgColor = FlutterFlowTheme.of(context).primary;
        textColor = Colors.white;
        break;
    }

    double height;
    double fontSize;
    double iconSize;
    EdgeInsets padding;

    switch (widget.size) {
      case 'small':
        height = 32;
        fontSize = 12;
        iconSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case 'large':
        height = 48;
        fontSize = 15;
        iconSize = 22;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
      case 'medium':
      default:
        height = 40;
        fontSize = 14;
        iconSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 16);
        break;
    }

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: InkWell(
        onTap: isDisabled ? null : widget.onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.fromBorderSide(borderSide),
          ),
          padding: padding,
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.iconPresent && widget.icon != null)
                        IconTheme(
                          data: IconThemeData(color: textColor, size: iconSize),
                          child: widget.icon!,
                        ),
                      Text(
                        widget.content,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              color: textColor,
                              fontSize: fontSize,
                            ),
                      ),
                      if (widget.iconEndPresent && widget.iconEnd != null)
                        IconTheme(
                          data: IconThemeData(color: textColor, size: iconSize),
                          child: widget.iconEnd!,
                        ),
                    ].divide(const SizedBox(width: 8.0)),
                  ),
          ),
        ),
      ),
    );
  }
}
