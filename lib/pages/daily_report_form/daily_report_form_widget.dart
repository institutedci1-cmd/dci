import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/features/daily_report/application/daily_report_notifier.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report_template.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';
import 'package:d_c_i_teacher_app/pages/reports_dashboard/reports_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/report_history/report_history_widget.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/daily_report_form_model.dart';
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
  Timer? _autoSaveTimer;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());
    _loadDraft();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'chapter': _model.textFieldModel3.inputTextController?.text,
      'topics': _model.textFieldModel4.inputTextController?.text,
      'homework': _model.textFieldModel5.inputTextController?.text,
      'remarks': _model.textFieldModel6.inputTextController?.text,
      'class': _model.dropdownValue1,
      'subject': _model.dropdownValue2,
    };
    await prefs.setString('daily_report_draft', jsonEncode(draft));
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString('daily_report_draft');
    if (draftStr != null) {
      final draft = jsonDecode(draftStr) as Map<String, dynamic>;
      _model.textFieldModel3.inputTextController?.text = draft['chapter'] ?? '';
      _model.textFieldModel4.inputTextController?.text = draft['topics'] ?? '';
      _model.textFieldModel5.inputTextController?.text = draft['homework'] ?? '';
      _model.textFieldModel6.inputTextController?.text = draft['remarks'] ?? '';
      
      // Note: Dropdown values will be synced by _syncModelWithState if they exist in state options
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('daily_report_draft');
  }

  Future<void> _handleSubmit(DailyReportFormState state, DailyReportNotifier notifier) async {
    setState(() => _showValidationErrors = true);
    
    if (!_formKey.currentState!.validate()) return;

    if (state.selectedClass == null || state.selectedSubject == null || state.selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Class, Subject and Teacher.')));
      return;
    }

    final success = await notifier.submitReport(
      chapter: _model.textFieldModel3.inputTextController?.text.trim() ?? '',
      topics: _model.textFieldModel4.inputTextController?.text.trim() ?? '',
      homework: _model.textFieldModel5.inputTextController?.text.trim() ?? '',
      remarks: _model.textFieldModel6.inputTextController?.text.trim() ?? '',
    );

    if (success && mounted) {
      await _clearDraft();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily report saved.')));
      context.goNamed(HomeDashboardWidget.routeName);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit report.')));
    }
  }

  void _syncModelWithState(DailyReportFormState state) {
    _model.classOptions = state.classOptions;
    _model.subjectOptions = state.subjectOptions;
    _model.teacherOptions = state.teacherOptions;

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
                        showErrors: _showValidationErrors,
                        onChanged: () {
                          notifier.setClass(_model.dropdownValue1);
                          notifier.setSubject(_model.dropdownValue2);
                          notifier.setTeacher(_model.dropdownValue3);
                          _startAutoSaveTimer();
                        },
                      ),
                      _buildTopicsSection(context),
                      StudentCountSection(
                        model: _model,
                        presentCount: state.presentCount,
                        absentCount: state.absentCount,
                        onPresentChanged: (count) {
                          notifier.setPresentCount(count);
                          _startAutoSaveTimer();
                        },
                        onAbsentChanged: (count) {
                          notifier.setAbsentCount(count);
                          _startAutoSaveTimer();
                        },
                        onChanged: _startAutoSaveTimer,
                      ),
                      AdditionalInfoSection(model: _model, onChanged: _startAutoSaveTimer),
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
          onChange: (_) => _startAutoSaveTimer(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  text: 'Submit Report',
                  isLoading: state.isSaving,
                  onPressed: () => _handleSubmit(state, notifier),
                ),
              ),
              const SizedBox(width: 12),
              _buildTemplateAction(context, state, notifier),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.lastReport != null) ...[
                _buildSmallAction(
                  icon: Icons.restore_page_rounded,
                  label: 'Restore',
                  color: FlutterFlowTheme.of(context).primary,
                  onTap: () {
                    notifier.applyLastReport();
                    _applyReportToModel(state.lastReport!);
                  },
                ),
                const SizedBox(width: 24),
              ],
              _buildSmallAction(
                icon: Icons.delete_sweep_rounded,
                label: 'Clear',
                color: FlutterFlowTheme.of(context).error,
                onTap: () => _handleClear(notifier),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateAction(BuildContext context, DailyReportFormState state, DailyReportNotifier notifier) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: theme.primary.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showTemplatesDialog(context, notifier),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(Icons.bookmarks_rounded, color: theme.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildSmallAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _applyReportToModel(dynamic report) {
    _model.textFieldModel3.inputTextController?.text = report.chapter;
    _model.textFieldModel4.inputTextController?.text = report.topics;
    if (report is DailyReport) {
      _model.textFieldModel5.inputTextController?.text = report.homeworkAssigned;
    } else if (report is DailyReportTemplate) {
      _model.textFieldModel5.inputTextController?.text = report.homework;
    }
    _model.textFieldModel6.inputTextController?.text = report.remarks;
    _startAutoSaveTimer();
  }

  Future<void> _handleClear(DailyReportNotifier notifier) async {
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
      _clearDraft();
      ref.invalidate(dailyReportNotifierProvider);
      _model.textFieldModel3.inputTextController?.clear();
      _model.textFieldModel4.inputTextController?.clear();
      _model.textFieldModel5.inputTextController?.clear();
      _model.textFieldModel6.inputTextController?.clear();
    }
  }

  void _showTemplatesDialog(BuildContext context, DailyReportNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TemplatesSheet(
        onApply: (template) {
          notifier.setClass(template.className);
          notifier.setSubject(template.subject);
          _applyReportToModel(template);
          Navigator.pop(context);
        },
        onSave: () async {
          final nameController = TextEditingController();
          final saveConfirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Save Template'),
              content: TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Template Name (e.g. Morning Math)'),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
              ],
            ),
          );

          if (saveConfirm == true && nameController.text.isNotEmpty) {
            final template = DailyReportTemplate(
              id: '',
              templateName: nameController.text,
              className: _model.dropdownValue1 ?? '',
              subject: _model.dropdownValue2 ?? '',
              chapter: _model.textFieldModel3.inputTextController?.text ?? '',
              topics: _model.textFieldModel4.inputTextController?.text ?? '',
              homework: _model.textFieldModel5.inputTextController?.text ?? '',
              remarks: _model.textFieldModel6.inputTextController?.text ?? '',
              createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
            );
            await ref.read(dailyReportRepositoryProvider).saveTemplate(template);
          }
        },
      ),
    );
  }
}

class _TemplatesSheet extends ConsumerWidget {
  final Function(DailyReportTemplate) onApply;
  final VoidCallback onSave;

  const _TemplatesSheet({required this.onApply, required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(dailyReportTemplatesStreamProvider);
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Report Templates', style: AppTypography.title.copyWith(fontSize: 20)),
              TextButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Save Current'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No templates saved yet.', textAlign: TextAlign.center),
                );
              }
              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  separatorBuilder: (_, __) => Divider(color: theme.alternate),
                  itemBuilder: (context, index) {
                    final t = templates[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.templateName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${t.className} • ${t.subject}', style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        onPressed: () => ref.read(dailyReportRepositoryProvider).deleteTemplate(t.id),
                      ),
                      onTap: () => onApply(t),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(text: 'Close', variant: 'outline', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
