import 'package:d_c_i_teacher_app/features/daily_report/application/daily_report_notifier.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/form_section_header/form_section_header_widget.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/sections/class_details_section.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/sections/student_count_section.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/sections/additional_info_section.dart';

export 'package:d_c_i_teacher_app/pages/daily_report_form/daily_report_form_model.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(DailyReportFormState state, DailyReportNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await notifier.submitReport(
      chapter: _model.textFieldModel3.inputTextController?.text.trim() ?? '',
      topics: _model.textFieldModel4.inputTextController?.text.trim() ?? '',
      homework: _model.textFieldModel5.inputTextController?.text.trim() ?? '',
      remarks: _model.textFieldModel6.inputTextController?.text.trim() ?? '',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily report saved.')));
      context.goNamed(HomeDashboardWidget.routeName);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit report. Please check required fields.')));
    }
  }

  void _syncModelWithState(DailyReportFormState state) {
    if (_model.dropdownValue1 != state.selectedClass) {
       _model.dropdownValue1 = state.selectedClass;
       _model.dropdownValueController1?.value = state.selectedClass;
    }
    if (_model.dropdownValue2 != state.selectedSubject) {
       _model.dropdownValue2 = state.selectedSubject;
       _model.dropdownValueController2?.value = state.selectedSubject;
    }
    if (_model.dropdownValue3 != state.selectedTeacher) {
       _model.dropdownValue3 = state.selectedTeacher;
       _model.dropdownValueController3?.value = state.selectedTeacher;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportStateAsync = ref.watch(dailyReportNotifierProvider);
    final notifier = ref.read(dailyReportNotifierProvider.notifier);

    return reportStateAsync.when(
      data: (state) => _buildScaffold(context, state, notifier),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildScaffold(BuildContext context, DailyReportFormState state, DailyReportNotifier notifier) {
    _syncModelWithState(state);

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      ClassDetailsSection(
                        model: _model, 
                        onChanged: () {
                          notifier.setClass(_model.dropdownValue1);
                          notifier.setSubject(_model.dropdownValue2);
                          notifier.setTeacher(_model.dropdownValue3);
                        },
                      ),
                      _buildTopicsSection(context),
                      StudentCountSection(
                        model: _model,
                        presentCount: state.presentCount,
                        absentCount: state.absentCount,
                        onPresentChanged: notifier.setPresentCount,
                        onAbsentChanged: notifier.setAbsentCount,
                        onChanged: () {},
                      ),
                      AdditionalInfoSection(model: _model, onChanged: () {}),
                      const SizedBox(height: 8),
                    ].divide(const SizedBox(height: 12)),
                  ),
                ),
              ),
            ),
            _buildFormFooter(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HeaderSectionWidget(
      title: 'Daily Report',
      subtitle: dateTimeFormat('yMMMd', getCurrentTimestamp),
      onBackPressed: () async => context.goNamed(ReportsDashboardWidget.routeName),
      actionIcon: const Icon(Icons.history_rounded, color: Colors.white, size: 24.0),
      onActionPressed: () async => context.pushNamed(ReportHistoryWidget.routeName),
    );
  }

  Widget _buildTopicsSection(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_rounded, color: theme.primary, size: 18.0),
            const SizedBox(width: 8),
            Text('Topics Covered', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, color: theme.primaryText)),
          ],
        ),
        const SizedBox(height: 8),
        TextFieldWidget(
          controller: _model.textFieldModel4.inputTextController,
          focusNode: _model.textFieldModel4.inputFocusNode,
          label: 'Detailed Topics',
          labelPresent: false,
          leadingIcon: Icon(Icons.topic_rounded, size: 20.0, color: theme.secondaryText),
          leadingIconPresent: true,
          hint: 'List topics taught today...',
          variant: 'outlined',
        ),
      ],
    );
  }

  Widget _buildFormFooter(BuildContext context, DailyReportFormState state, DailyReportNotifier notifier) {
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
              isLoading: state.isSaving,
              onPressed: () => _handleSubmit(state, notifier),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (state.lastReport != null) ...[
            _buildRestoreButton(notifier, state),
            const SizedBox(width: AppSpacing.md),
          ],
          _buildClearButton(notifier),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(DailyReportNotifier notifier, DailyReportFormState state) {
    return InkWell(
      onTap: () {
        notifier.applyLastReport();
        final report = state.lastReport!;
        _model.textFieldModel3.inputTextController?.text = report.chapter;
        _model.textFieldModel4.inputTextController?.text = report.topics;
        _model.textFieldModel5.inputTextController?.text = report.homeworkAssigned;
        _model.textFieldModel6.inputTextController?.text = report.remarks;
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Icon(
          Icons.restore_page_rounded,
          color: AppColors.primary,
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildClearButton(DailyReportNotifier notifier) {
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
        if (confirm) {
          ref.invalidate(dailyReportNotifierProvider);
          _model.textFieldModel3.inputTextController?.clear();
          _model.textFieldModel4.inputTextController?.clear();
          _model.textFieldModel5.inputTextController?.clear();
          _model.textFieldModel6.inputTextController?.clear();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56.0, height: 56.0,
        decoration: BoxDecoration(color: AppColors.error.withAlpha(25), borderRadius: BorderRadius.circular(16.0)),
        child: const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 24.0),
      ),
    );
  }
}
