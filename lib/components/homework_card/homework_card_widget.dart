import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/components/homework_card/homework_card_model.dart';
export 'package:d_c_i_teacher_app/components/homework_card/homework_card_model.dart';

class HomeworkCardWidget extends StatefulWidget {
  const HomeworkCardWidget({
    super.key,
    required this.assignment,
    this.onTap,
    this.onShare,
  });

  final HomeworkAssignment assignment;
  final Future Function()? onTap;
  final VoidCallback? onShare;

  @override
  State<HomeworkCardWidget> createState() => _HomeworkCardWidgetState();
}

class _HomeworkCardWidgetState extends State<HomeworkCardWidget> {
  late HomeworkCardModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.assignment.status;
    final theme = FlutterFlowTheme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          onTap: () async {
            if (widget.onTap != null) {
              await widget.onTap!();
            }
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            '${widget.assignment.className} - ${widget.assignment.subject}',
            style: theme.bodyLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.assignment.title, style: FlutterFlowTheme.of(context).bodyMedium),
              if (widget.assignment.teacher.isNotEmpty)
                Text('Assigned by: ${widget.assignment.teacher}',
                    style: FlutterFlowTheme.of(context).bodySmall),
              Text(
                'Due: ${widget.assignment.dueDate}',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              if (widget.assignment.attachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.attachment_rounded,
                          size: 14,
                          color: FlutterFlowTheme.of(context).secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.assignment.attachments.length} attachment(s)',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
            ].divide(const SizedBox(height: 2.0)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onShare != null)
                IconButton(
                  icon: Icon(Icons.share_rounded, color: theme.success, size: 20),
                  onPressed: widget.onShare,
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'published'
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondaryText,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
