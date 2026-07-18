import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentActivityItemWidget extends StatelessWidget {
  const RecentActivityItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.history_rounded, 
                      size: 18, 
                      color: FlutterFlowTheme.of(context).primary
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 2,
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(),
                                fontSize: 11,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, 
                    size: 20, 
                    color: FlutterFlowTheme.of(context).secondaryText
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
