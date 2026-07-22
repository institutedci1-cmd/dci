import 'package:cached_network_image/cached_network_image.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/components/auth_header/auth_header_model.dart';
export 'package:d_c_i_teacher_app/components/auth_header/auth_header_model.dart';

class AuthHeaderWidget extends ConsumerStatefulWidget {
  const AuthHeaderWidget({super.key});

  @override
  ConsumerState<AuthHeaderWidget> createState() => _AuthHeaderWidgetState();
}

class _AuthHeaderWidgetState extends ConsumerState<AuthHeaderWidget> {
  late AuthHeaderModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ref.read(configRepositoryProvider).getInstituteInfo(),
      builder: (context, snapshot) {
        final info = snapshot.data;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 180.0,
              height: 180.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(36.0),
                shape: BoxShape.rectangle,
              ),
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: info?['logo_url'] != null
                  ? CachedNetworkImage(
                      imageUrl: info!['logo_url'],
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.school_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 110.0,
                      ),
                    )
                  : Icon(
                      Icons.school_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 110.0,
                    ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  info?['app_name'] ?? 'Deshmukh Institute',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                        lineHeight: 1.25,
                      ),
                ),
                Text(
                  info?['name'] ?? 'Deshmukh Coaching Institute',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.47,
                      ),
                ),
              ].divide(const SizedBox(height: 4.0)),
            ),
          ].divide(const SizedBox(height: 24.0)),
        );
      },
    );
  }
}
