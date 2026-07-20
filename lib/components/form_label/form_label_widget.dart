import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/components/form_label/form_label_model.dart';
export 'package:d_c_i_teacher_app/components/form_label/form_label_model.dart';

class FormLabelWidget extends StatefulWidget {
  const FormLabelWidget({
    super.key,
    String? label,
  }) : label = label ?? 'Select Class';

  final String label;

  @override
  State<FormLabelWidget> createState() => _FormLabelWidgetState();
}

class _FormLabelWidgetState extends State<FormLabelWidget> {
  late FormLabelModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormLabelModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
      child: Text(
        valueOrDefault<String>(
          widget.label,
          'Select Class',
        ),
        style: FlutterFlowTheme.of(context).labelLarge.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
              lineHeight: 1.33,
            ),
      ),
    );
  }
}
