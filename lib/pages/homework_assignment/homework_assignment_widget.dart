import '/backend/models/homework_assignment.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sections/homework_class_details_section.dart';
import 'sections/assignment_details_section.dart';
import 'sections/due_date_section.dart';

export 'homework_assignment_model.dart';

class HomeworkAssignmentWidget extends ConsumerStatefulWidget {
  const HomeworkAssignmentWidget({super.key});

  static String routeName = 'HomeworkAssignment';
  static String routePath = '/homeworkAssignment';

  @override
  ConsumerState<HomeworkAssignmentWidget> createState() =>
      _HomeworkAssignmentWidgetState();
}

class _HomeworkAssignmentWidgetState extends ConsumerState<HomeworkAssignmentWidget> {
  late HomeworkAssignmentModel _model;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkAssignmentModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _model.isDataUploading = true);
      try {
        final file = File(result.files.single.path!);
        final storageService = ref.read(storageServiceProvider);
        final url = await storageService.uploadHomeworkAttachment(file);
        
        if (url != null && mounted) {
          setState(() {
            _model.attachmentUrls.add(url);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _model.isDataUploading = false);
      }
    }
  }

  Future<void> _saveHomework(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_formKey.currentState!.validate()) return;

    try {
      final assignment = HomeworkAssignment(
        id: '',
        className: _model.dropdownValue1 ?? '',
        subject: _model.dropdownValue2 ?? '',
        teacher: _model.dropdownValue3 ?? '',
        title: _model.textFieldModel1.inputTextController!.text,
        description: _model.textFieldModel2.inputTextController!.text,
        dueDate: _model.dueDate != null ? dateTimeFormat('yMMMd', _model.dueDate) : 'No Due Date',
        status: status,
        attachments: _model.attachmentUrls,
        createdBy: user.uid,
        createdByEmail: user.email ?? '',
      );

      await ref.read(homeworkRepositoryProvider).saveHomework(assignment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'published' ? 'Homework published.' : 'Draft saved.')));
      if (status == 'published') context.goNamed(HomeDashboardWidget.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            wrapWithModel(
              model: _model.headerSectionModel,
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Assign Homework',
                onBackPressed: () async => context.safePop(),
                actionIcon: const Icon(Icons.history_rounded, color: Colors.white, size: 24.0),
                onActionPressed: () async => context.pushNamed(HomeworkHistoryWidget.routeName),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      HomeworkClassDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                      AssignmentDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                      _buildAttachmentsSection(context),
                      DueDateSection(model: _model, onChanged: () => safeSetState(() {})),
                      _buildInfoNote(context),
                    ].divide(const SizedBox(height: 24.0)),
                  ),
                ),
              ),
            ),
            _buildHomeworkFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), border: Border.all(color: FlutterFlowTheme.of(context).info)),
      padding: const EdgeInsets.all(24.0),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, size: 20.0),
          SizedBox(width: 16),
          Expanded(child: Text('This assignment will be visible to all students in the selected class immediately after submission.')),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_model.isDataUploading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              InkWell(
                onTap: _pickFile,
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: FlutterFlowTheme.of(context).primary, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Add File',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (_model.attachmentUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _model.attachmentUrls.map((url) => _buildFileBadge(url)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFileBadge(String url) {
    final fileName = url.split('%2F').last.split('?').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent4,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName.length > 15 ? '${fileName.substring(0, 12)}...' : fileName,
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() {
                _model.attachmentUrls.remove(url);
              });
              ref.read(storageServiceProvider).deleteAttachment(url);
            },
            child: Icon(Icons.close_rounded,
                color: FlutterFlowTheme.of(context).error, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, border: Border(top: BorderSide(color: FlutterFlowTheme.of(context).alternate))),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(child: _buildFooterButton('Save Draft', 'outline', () => _saveHomework('draft'), _model.buttonModel2)),
          const SizedBox(width: 16),
          Expanded(child: _buildFooterButton('Publish', 'primary', () => _saveHomework('published'), _model.buttonModel3)),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String text, String variant, VoidCallback onPressed, FlutterFlowModel model) {
    return wrapWithModel(
      model: model,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(content: text, variant: variant, size: 'medium', onPressed: onPressed),
    );
  }
}
