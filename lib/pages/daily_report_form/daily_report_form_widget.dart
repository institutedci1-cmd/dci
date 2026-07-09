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
  const DailyReportFormWidget({super.key});

  static String routeName = 'DailyReportForm';
  static String routePath = '/dailyReportForm';

  @override
  ConsumerState<DailyReportFormWidget> createState() => _DailyReportFormWidgetState();
}

class _DailyReportFormWidgetState extends ConsumerState<DailyReportFormWidget> {
  late DailyReportFormModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  int _presentCount = 0;
  int _absentCount = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());
    _model.textFieldModel3.inputTextController ??= TextEditingController();
    _model.textFieldModel4.inputTextController ??= TextEditingController();
    _model.textFieldModel5.inputTextController ??= TextEditingController();
    _model.textFieldModel6.inputTextController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (currentUserUid.isEmpty) return;
    if (!Form.of(context).validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final report = DailyReport(
        id: '',
        className: _model.dropdownValue1 ?? '',
        subject: _model.dropdownValue2 ?? '',
        teacher: _model.dropdownValue3 ?? '',
        chapter: _model.textFieldModel3.inputTextController?.text ?? '',
        topics: _model.textFieldModel4.inputTextController?.text ?? '',
        presentCount: _presentCount,
        absentCount: _absentCount,
        homeworkAssigned: _model.textFieldModel5.inputTextController?.text ?? '',
        remarks: _model.textFieldModel6.inputTextController?.text ?? '',
        createdBy: currentUserUid,
        createdByEmail: currentUserEmail,
        createdAt: DateTime.now(),
      );

      await ref.read(dailyReportRepositoryProvider).submitReport(report);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully!')));
        context.goNamed(HomeDashboardWidget.routeName);
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
          title: Text('Daily Report', style: AppTypography.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.safePop(),
          ),
        ),
        body: Form(
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
                    presentCount: _presentCount,
                    absentCount: _absentCount,
                    onPresentChanged: (val) => setState(() => _presentCount = val),
                    onAbsentChanged: (val) => setState(() => _absentCount = val),
                    onChanged: () => safeSetState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(title: 'Topic Details', icon: Icons.menu_book_rounded),
                  AdditionalInfoSection(model: _model, onChanged: () => safeSetState(() {})),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    text: 'Submit Daily Report',
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
