import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info_section_model.dart';
export 'info_section_model.dart';

class InfoSectionWidget extends StatefulWidget {
  const InfoSectionWidget({
    super.key,
    String? description,
    this.icon,
    String? title,
  })  : description = description ??
            'To provide a nurturing and disciplined environment that empowers students to achieve academic excellence.',
        title = title ?? 'Our Mission';

  final String description;
  final Widget? icon;
  final String title;

  @override
  State<InfoSectionWidget> createState() => _InfoSectionWidgetState();
}

class _InfoSectionWidgetState extends State<InfoSectionWidget> {
  late InfoSectionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InfoSectionModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.icon != null)
                  IconTheme(
                    data: IconThemeData(color: FlutterFlowTheme.of(context).primary, size: 20),
                    child: widget.icon!,
                  ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        fontSize: 15,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 13,
                    lineHeight: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
