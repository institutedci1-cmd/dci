import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/error_handler.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_style.dart';
import '/components/shared/app_primary_button.dart';
import '/components/form_section_header/form_section_header_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sections/class_details_section.dart';
import 'sections/student_count_section.dart';
import 'sections/additional_info_section.dart';
import '../reports_dashboard/reports_dashboard_widget.dart';
import '../report_history/report_history_widget.dart';
import '../home_dashboard/home_dashboard_widget.dart';

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
  bool _isDataLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
  }

  Future<void> _initializeFormData() async {
    if (!mounted) return;
    setState(() => _isDataLoading = true);
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final studentRepo = ref.read(studentRepositoryProvider);
      
      final teachers = await userRepo.getTeachers();
      final allStudents = await studentRepo.getAllStudents();

      // Extract teacher names and expertise
      final teacherNames = teachers.map((t) => t['display_name'] as String).toSet().toList();
      final subjects = teachers
          .map((t) => t['subject_expertise'] as String?)
          .where((s) => s != null && s.isNotEmpty)
          .expand((s) => s!.split(',').map((e) => e.trim()))
          .toSet()
          .toList();

      // Extract unique classes
      final classNames = allStudents
          .map((s) => s.className)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      if (mounted) {
        setState(() {
          _model.teacherOptions = teacherNames..sort();
          _model.subjectOptions = {
            'English',
            'Marathi',
            'Math',
            'Science',
            ...subjects,
          }.toList().where((s) => s.isNotEmpty).toList()..sort();
          _model.classOptions = classNames..sort();
        });
        await _loadLastReport();
        if (mounted) {
          setState(() {
            _isDataLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDataLoading = false);
        ErrorHandler.show(context, e);
      }
    }
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
      debugPrint('Error loading last report: $e');
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

  Future<void> _handleSubmit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    if (_model.dropdownValue1 == null || 
        _model.dropdownValue2 == null || 
        _model.dropdownValue3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Class, Subject and Teacher.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final report = DailyReport(
        id: '',
        className: _model.dropdownValue1!,
        subject: _model.dropdownValue2!,
        teacher: _model.dropdownValue3!,
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
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily report saved.')));
      context.goNamed(HomeDashboardWidget.routeName);
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  padding: AppSpacing.pagePadding,
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
                      const SizedBox(height: AppSpacing.xl),
                    ].divide(const SizedBox(height: AppSpacing.lg)),
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
            icon: Icon(Icons.list_alt_rounded, color: AppColors.primary, size: 20.0),
            title: 'Topics Covered',
          ),
        ),
        wrapWithModel(
          model: _model.textFieldModel4,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            controller: _model.textFieldModel4.inputTextController,
            focusNode: _model.textFieldModel4.inputFocusNode,
            label: 'Detailed Topics',
            labelPresent: true,
            leadingIcon: const Icon(Icons.topic_rounded, size: 24.0),
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
        boxShadow: AppShadows.low,
      ),
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          Expanded(
            child: AppPrimaryButton(
              text: 'Submit Report',
              isLoading: _isSaving,
              onPressed: _handleSubmit,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Icon(
          Icons.restore_page_rounded,
          color: AppColors.primary,
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
            content: const Text('Are you sure you want to clear all inputs?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
            ],
          ),
        ) ?? false;
        if (confirm) _clearForm();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56.0, height: 56.0,
        decoration: BoxDecoration(color: AppColors.error.withAlpha(25), borderRadius: BorderRadius.circular(16.0)),
        child: Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 24.0),
      ),
    );
  }
}
