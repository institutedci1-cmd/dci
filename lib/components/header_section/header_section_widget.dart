import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/providers/repository_providers.dart';
import '/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


export 'header_section_model.dart';

class HeaderSectionWidget extends ConsumerWidget {
  const HeaderSectionWidget({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.onBackPressed,
    this.onActionPressed,
    this.actionIcon,
    this.showActionIcon = true,
  });

  final String? title;
  final String? subtitle;
  final String? description;
  final Future Function()? onBackPressed;
  final Future Function()? onActionPressed;
  final Widget? actionIcon;
  final bool showActionIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the repository provider to get the stream
    final configRepo = ref.watch(configRepositoryProvider);

    return StreamBuilder<Map<String, dynamic>?>(
      stream: configRepo.getInstituteInfoStream(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final instituteName = info?['name'] ?? 'DCI Teachers';

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
            boxShadow: AppShadows.low,
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
                    Expanded(
                      child: Row(
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
                              if (onBackPressed != null) {
                                await onBackPressed!();
                              } else {
                                context.safePop();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title ?? 'Assign Homework',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                        color: FlutterFlowTheme.of(context).onPrimary,
                                      ),
                                ),
                                Text(
                                  subtitle ?? instituteName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).onPrimary80,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showActionIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FlutterFlowIconButton(
                          borderRadius: 12.0,
                          buttonSize: 36.0,
                          fillColor: FlutterFlowTheme.of(context).onPrimary15,
                          icon: actionIcon ??
                              Icon(
                                Icons.help_outline_rounded,
                                color: FlutterFlowTheme.of(context).onPrimary,
                                size: 20.0,
                              ),
                          onPressed: () async {
                            if (onActionPressed != null) {
                              await onActionPressed!();
                            }
                          },
                        ),
                      ),
                  ],
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 4.0),
                    child: Text(
                      description!,
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
