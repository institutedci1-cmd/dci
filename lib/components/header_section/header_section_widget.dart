import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'header_section_model.dart';
export 'header_section_model.dart';

class HeaderSectionWidget extends StatefulWidget {
  const HeaderSectionWidget({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.onBackPressed,
    this.onActionPressed,
    this.actionIcon,
    bool? showActionIcon,
  })  : showActionIcon = showActionIcon ?? true;

  final String? title;
  final String? subtitle;
  final String? description;
  final Future Function()? onBackPressed;
  final Future Function()? onActionPressed;
  final Widget? actionIcon;
  final bool showActionIcon;

  @override
  State<HeaderSectionWidget> createState() => _HeaderSectionWidgetState();
}

class _HeaderSectionWidgetState extends State<HeaderSectionWidget> {
  late HeaderSectionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeaderSectionModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('config')
          .doc('institute_info')
          .get(),
      builder: (context, snapshot) {
        final info = snapshot.data?.data() as Map<String, dynamic>?;
        final instituteName = info?['name'] ?? 'Deshmukh Coaching Institute';

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlutterFlowTheme.of(context).primary,
                FlutterFlowTheme.of(context).tertiary
              ],
              begin: const AlignmentDirectional(0, -1),
              end: const AlignmentDirectional(0, 1),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 44.0, 16.0, 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlutterFlowIconButton(
                          borderRadius: 12.0,
                          buttonSize: 36.0,
                          fillColor: FlutterFlowTheme.of(context).onPrimary15,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: FlutterFlowTheme.of(context).onPrimary,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            if (widget.onBackPressed != null) {
                              await widget.onBackPressed!();
                            } else {
                              context.safePop();
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title ?? 'Assign Homework',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                    color: FlutterFlowTheme.of(context).onPrimary,
                                  ),
                            ),
                            Text(
                              widget.subtitle ?? instituteName,
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).onPrimary80,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (widget.showActionIcon)
                      FlutterFlowIconButton(
                        borderRadius: 12.0,
                        buttonSize: 36.0,
                        fillColor: FlutterFlowTheme.of(context).onPrimary15,
                        icon: widget.actionIcon ??
                            Icon(
                              Icons.help_outline_rounded,
                              color: FlutterFlowTheme.of(context).onPrimary,
                              size: 20.0,
                            ),
                        onPressed: () async {
                          if (widget.onActionPressed != null) {
                            await widget.onActionPressed!();
                          }
                        },
                      ),
                  ],
                ),
                if (widget.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 4.0),
                    child: Text(
                      widget.description!,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).onPrimary70,
                            fontSize: 12,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
