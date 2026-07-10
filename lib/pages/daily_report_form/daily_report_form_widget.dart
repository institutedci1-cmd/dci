import '/auth/firebase_auth/auth_util.dart';
import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/components/shared/app_button.dart';
import '/components/shared/app_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sections/class_details_section.dart';
import 'sections/student_count_section.dart';
import 'sections/additional_info_section.dart';

export 'daily_report_form_model.dart';

class DailyReportFormWidget extends ConsumerStatefulWidget {
  const DailyReportFormWidget({super.key, this.initialReport});

  final DailyReport? initialReport;

  static String routeName = 'DailyReportForm';
  static String routePath = '/dailyReportForm';

  @override
  ConsumerState<DailyReportFormWidget> createState() => _DailyReportFormWidgetState();
}

class _DailyReportFormWidgetState extends ConsumerState<DailyReportFormWidget> {
  late DailyReportFormModel _model;
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());
    
    _model.textFieldModel3.inputTextController ??= TextEditingController();
    _model.textFieldModel4.inputTextController ??= TextEditingController();
    _model.textFieldModel5.inputTextController ??= TextEditingController();
    _model.textFieldModel6.inputTextController ??= TextEditingController();

    if (widget.initialReport != null) {
      _model.dropdownValue1 = widget.initialReport!.className;
      _model.dropdownValue2 = widget.initialReport!.subject;
      _model.dropdownValue3 = widget.initialReport!.teacher;
      _model.textFieldModel3.inputTextController?.text = widget.initialReport!.chapter;
      _model.textFieldModel4.inputTextController?.text = widget.initialReport!.topics;
      _model.presentController.text = widget.initialReport!.presentCount.toString();
      _model.absentController.text = widget.initialReport!.absentCount.toString();
      _model.textFieldModel5.inputTextController?.text = widget.initialReport!.homeworkAssigned;
      _model.textFieldModel6.inputTextController?.text = widget.initialReport!.remarks;
      
      // Update controllers in the model as well
      _model.dropdownValueController1?.value = widget.initialReport!.className;
      _model.dropdownValueController2?.value = widget.initialReport!.subject;
      _model.dropdownValueController3?.value = widget.initialReport!.teacher;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (currentUserUid.isEmpty) {
      return;
    }
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final report = DailyReport(
        id: widget.initialReport?.id ?? '',
        className: _model.dropdownValue1 ?? '',
        subject: _model.dropdownValue2 ?? '',
        teacher: _model.dropdownValue3 ?? '',
        chapter: _model.textFieldModel3.inputTextController?.text ?? '',
        topics: _model.textFieldModel4.inputTextController?.text ?? '',
        presentCount: int.tryParse(_model.presentController.text) ?? 0,
        absentCount: int.tryParse(_model.absentController.text) ?? 0,
        homeworkAssigned: _model.textFieldModel5.inputTextController?.text ?? '',
        remarks: _model.textFieldModel6.inputTextController?.text ?? '',
        createdBy: currentUserUid,
        createdByEmail: currentUserEmail,
        createdAt: widget.initialReport?.createdAt ?? DateTime.now(),
      );

      final repository = ref.read(dailyReportRepositoryProvider);
      if (widget.initialReport == null) {
        await repository.submitReport(report);
      } else {
        await repository.updateReport(report);
      }
      
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(widget.initialReport == null ? 'Report submitted successfully!' : 'Report updated successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.goNamed(HomeDashboardWidget.routeName);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          title: Text(
            widget.initialReport == null ? 'Daily Report' : 'Edit Report',
            style: AppTypography.title,
          ),          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.safePop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Builder(builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppSectionHeader(title: 'Class Selection', icon: Icons.class_rounded),
                  ClassDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(title: 'Attendance Count', icon: Icons.people_rounded),
                  StudentCountSection(
                    model: _model,
                    onChanged: () => safeSetState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(title: 'Topic Details', icon: Icons.menu_book_rounded),
                  AdditionalInfoSection(model: _model, onChanged: () => safeSetState(() {})),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    text: widget.initialReport == null ? 'Submit Daily Report' : 'Save Changes',
                    isLoading: _isSubmitting,
                    onPressed: () => _submitReport(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
