import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/components/button/button_widget.dart';
import '/components/shared/app_primary_button.dart';
import '/components/form_section_header/form_section_header_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sections/class_details_section.dart';
import 'sections/student_count_section.dart';
import 'sections/additional_info_section.dart';

export 'daily_report_form_model.dart';

class DailyReportFormWidget extends ConsumerStatefulWidget {
  const DailyReportFormWidget({super.key});

  static String routeName = 'DailyReportForm';
  static String routePath = '/dailyReportForm';

  @override
  ConsumerState<DailyReportFormWidget> createState() => _DailyReportFormWidgetState();
}

class _DailyReportFormWidgetState extends ConsumerState<DailyReportFormWidget> {
  late DailyReportFormModel _model;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _presentCount = 0;
  int _absentCount = 0;
  DailyReport? _lastReport;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadLastReport();
    });
  }

  void _clearForm() {
    safeSetState(() {
      _presentCount = 0;
      _absentCount = 0;
      _model.dropdownValue1 = null;
      _model.dropdownValueController1?.reset();
      _model.dropdownValue2 = null;
      _model.dropdownValueController2?.reset();
      _model.dropdownValue3 = null;
      _model.dropdownValueController3?.reset();
      _model.textFieldModel3.inputTextController?.clear();
      _model.textFieldModel4.inputTextController?.clear();
      _model.textFieldModel5.inputTextController?.clear();
      _model.textFieldModel6.inputTextController?.clear();
    });
  }

  Future<void> _loadLastReport() async {
    try {
      final repository = ref.read(dailyReportRepositoryProvider);
      final report = await repository.getLastReport();
      if (report == null) return;

      _lastReport = report;
      if (!mounted) return;
      _applyReport(report);
    } catch (e) {
      // Ignore load errors and allow the form to continue.
    }
  }

  void _applyReport(DailyReport report) {
    safeSetState(() {
      _presentCount = report.presentCount;
      _absentCount = report.absentCount;
      _model.dropdownValue1 = report.className;
      _model.dropdownValueController1?.value = report.className;
      _model.dropdownValue2 = report.subject;
      _model.dropdownValueController2?.value = report.subject;
      _model.dropdownValue3 = report.teacher;
      _model.dropdownValueController3?.value = report.teacher;
      _model.textFieldModel3.inputTextController?.text = report.chapter;
      _model.textFieldModel4.inputTextController?.text = report.topics;
      _model.textFieldModel5.inputTextController?.text = report.homeworkAssigned;
      _model.textFieldModel6.inputTextController?.text = report.remarks;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
            _buildHeader(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      ClassDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                      _buildTopicsSection(context),
                      StudentCountSection(
                        model: _model,
                        presentCount: _presentCount,
                        absentCount: _absentCount,
                        onPresentChanged: (val) => safeSetState(() => _presentCount = val),
                        onAbsentChanged: (val) => safeSetState(() => _absentCount = val),
                        onChanged: () => safeSetState(() {}),
                      ),
                      AdditionalInfoSection(model: _model, onChanged: () => safeSetState(() {})),
                      const SizedBox(height: 32.0),
                    ].divide(const SizedBox(height: 24.0)),
                  ),
                ),
              ),
            ),
            _buildFormFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return wrapWithModel(
      model: createModel(context, () => HeaderSectionModel()),
      updateCallback: () => safeSetState(() {}),
      child: HeaderSectionWidget(
        title: 'Daily Report',
        subtitle: dateTimeFormat('MMMMEEEEd', getCurrentTimestamp),
        onBackPressed: () async => context.goNamed(ReportsDashboardWidget.routeName),
        actionIcon: const Icon(Icons.history_rounded, color: Colors.white, size: 24.0),
        onActionPressed: () async => context.pushNamed(ReportHistoryWidget.routeName),
      ),
    );
  }

  Widget _buildTopicsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formSectionHeaderModel2,
          updateCallback: () => safeSetState(() {}),
          child: FormSectionHeaderWidget(
            icon: Icon(Icons.list_alt_rounded, color: FlutterFlowTheme.of(context).primary, size: 20.0),
            title: 'Topics Covered',
          ),
        ),
        wrapWithModel(
          model: _model.textFieldModel4,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Detailed Topics',
            labelPresent: true,
            leadingIcon: Icon(Icons.topic_rounded, size: 24.0),
            leadingIconPresent: true,
            hint: 'List the specific topics taught today...',
            variant: 'outlined',
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildFormFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(top: BorderSide(color: FlutterFlowTheme.of(context).alternate)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: AppPrimaryButton(
              text: 'Submit Report',
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || !_formKey.currentState!.validate()) return;

                try {
                  final report = DailyReport(
                    id: '',
                    className: _model.dropdownValue1 ?? '',
                    subject: _model.dropdownValue2 ?? '',
                    teacher: _model.dropdownValue3 ?? '',
                    chapter: _model.textFieldModel3.inputTextController?.text.trim() ?? '',
                    topics: _model.textFieldModel4.inputTextController?.text.trim() ?? '',
                    presentCount: _presentCount,
                    absentCount: _absentCount,
                    homeworkAssigned: _model.textFieldModel5.inputTextController?.text.trim() ?? '',
                    remarks: _model.textFieldModel6.inputTextController?.text.trim() ?? '',
                    createdBy: user.uid,
                    createdByEmail: user.email ?? '',
                  );

                  await ref.read(dailyReportRepositoryProvider).submitReport(report);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily report saved.')));
                  if (context.mounted) {
                    context.goNamed(HomeDashboardWidget.routeName);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (_lastReport != null) ...[
            _buildRestoreButton(),
            const SizedBox(width: AppSpacing.md),
          ],
          _buildClearButton(),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return InkWell(
      onTap: () {
        if (_lastReport != null) _applyReport(_lastReport!);
      },
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary10,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Icon(
          Icons.restore_page_rounded,
          color: FlutterFlowTheme.of(context).primary,
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return InkWell(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear Form'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
            ],
          ),
        ) ?? false;
        if (confirm) _clearForm();
      },
      child: Container(
        width: 56.0, height: 56.0,
        decoration: BoxDecoration(color: FlutterFlowTheme.of(context).error10, borderRadius: BorderRadius.circular(16.0)),
        child: Icon(Icons.delete_sweep_rounded, color: FlutterFlowTheme.of(context).error, size: 24.0),
      ),
    );
  }
}
