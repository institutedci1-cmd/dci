import '/backend/models/homework_assignment.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homework_assignment_model.dart';
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
