import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'homework_details_model.dart';

class HomeworkDetailsWidget extends StatefulWidget {
  const HomeworkDetailsWidget({
    super.key,
    required this.assignment,
  });

  final HomeworkAssignment assignment;

  @override
  State<HomeworkDetailsWidget> createState() => _HomeworkDetailsWidgetState();
}

class _HomeworkDetailsWidgetState extends State<HomeworkDetailsWidget> {
  late HomeworkDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkDetailsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final a = widget.assignment;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Homework Details',
            subtitle: '${a.className} • ${a.subject}',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 24),
                  Text('Description', style: AppTypography.section.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Text(
                      a.description.isNotEmpty ? a.description : 'No description provided.',
                      style: AppTypography.body,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (a.attachments.isNotEmpty) ...[
                    Text('Attachments', style: AppTypography.section.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...a.attachments.map((url) => _buildAttachmentTile(context, url)),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final a = widget.assignment;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.low,
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (a.status == 'published' ? AppColors.success : AppColors.warning).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.status.toUpperCase(),
                  style: TextStyle(
                    color: a.status == 'published' ? AppColors.success : AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Due: ${a.dueDate}',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            a.title,
            style: AppTypography.title.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'Assigned by: ${a.teacher}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 16),
          Divider(color: theme.alternate),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoItem(context, Icons.school_rounded, 'Class', a.className),
              const SizedBox(width: 24),
              _buildInfoItem(context, Icons.book_rounded, 'Subject', a.subject),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
            Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentTile(BuildContext context, String url) {
    final theme = FlutterFlowTheme.of(context);
    final fileName = url.split('%2F').last.split('?').first;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: ListTile(
        leading: Icon(Icons.insert_drive_file_outlined, color: theme.primary),
        title: Text(
          fileName,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.open_in_new_rounded, size: 18, color: theme.secondaryText),
        onTap: () => launchURL(url),
      ),
    );
  }
}
