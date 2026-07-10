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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.history_rounded,
                    size: 16, 
                    color: FlutterFlowTheme.of(context).primary
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.inter(),
                              fontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                  size: 18, 
                  color: FlutterFlowTheme.of(context).secondaryText
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
