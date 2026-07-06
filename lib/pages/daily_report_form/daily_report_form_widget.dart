import '/backend/repositories/daily_report_repository.dart';
import '/backend/services/app_constants.dart';
import '/components/button/button_widget.dart';
import '/components/form_section_header/form_section_header_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/student_counter/student_counter_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'daily_report_form_model.dart';
export 'daily_report_form_model.dart';

class DailyReportFormWidget extends StatefulWidget {
  const DailyReportFormWidget({super.key});

  static String routeName = 'DailyReportForm';
  static String routePath = '/dailyReportForm';

  @override
  State<DailyReportFormWidget> createState() => _DailyReportFormWidgetState();
}

class _DailyReportFormWidgetState extends State<DailyReportFormWidget> {
  late DailyReportFormModel _model;
  final DailyReportRepository _repository = DailyReportRepository();

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _presentCount = 0;
  int _absentCount = 0;

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
      final data = await _repository.getLastReport();
      if (data == null) return;

      final classValue = (data['class'] ?? '').toString();
      final subjectValue = (data['subject'] ?? '').toString();
      final teacherValue = (data['teacher'] ?? '').toString();
      final chapterValue = (data['chapter'] ?? '').toString();
      final topicsValue = (data['topics'] ?? '').toString();
      final homeworkValue = (data['homeworkAssigned'] ?? '').toString();
      final remarksValue = (data['remarks'] ?? '').toString();
      final presentValue =
          int.tryParse(data['presentCount']?.toString() ?? '') ?? _presentCount;
      final absentValue =
          int.tryParse(data['absentCount']?.toString() ?? '') ?? _absentCount;

      if (!mounted) return;
      safeSetState(() {
        _presentCount = presentValue;
        _absentCount = absentValue;
        _model.dropdownValue1 = classValue;
        _model.dropdownValueController1?.value = classValue;
        _model.dropdownValue2 = subjectValue;
        _model.dropdownValueController2?.value = subjectValue;
        _model.dropdownValue3 = teacherValue;
        _model.dropdownValueController3?.value = teacherValue;
        _model.textFieldModel3.inputTextController?.text = chapterValue;
        _model.textFieldModel4.inputTextController?.text = topicsValue;
        _model.textFieldModel5.inputTextController?.text = homeworkValue;
        _model.textFieldModel6.inputTextController?.text = remarksValue;
      });
    } catch (e) {
      // Ignore load errors and allow the form to continue.
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            wrapWithModel(
              model: createModel(context, () => HeaderSectionModel()),
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Daily Report',
                subtitle: dateTimeFormat('MMMMEEEEd', getCurrentTimestamp),
                onBackPressed: () async =>
                    context.goNamed(ReportsDashboardWidget.routeName),
                actionIcon: Icon(
                  Icons.history_rounded,
                  color: FlutterFlowTheme.of(context).onPrimary,
                  size: 24.0,
                ),
                onActionPressed: () async =>
                    context.pushNamed(ReportHistoryWidget.routeName),
              ),
            ),
            Expanded(
              child: Container(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildClassDetailsSection(context),
                                _buildTopicsSection(context),
                                _buildStudentCountSection(context),
                                _buildAdditionalInfoSection(context),
                                Container(
                                  height: 32.0,
                                ),
                              ].divide(const SizedBox(height: 24.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildClassDetailsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formSectionHeaderModel1,
          updateCallback: () => safeSetState(() {}),
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.school_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Class Details',
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: _buildDropDownField(
                context,
                label: 'Class',
                hint: 'Select Class',
                options: AppConstants.classOptions,
                initialValue: _model.dropdownValue1 ?? AppConstants.classOptions.last,
                onChanged: (val) => safeSetState(() => _model.dropdownValue1 = val),
                controller: _model.dropdownValueController1,
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildDropDownField(
                context,
                label: 'Subject',
                hint: 'Select Subject',
                icon: Icons.menu_book_rounded,
                options: AppConstants.subjectOptions,
                initialValue: _model.dropdownValue2 ?? AppConstants.subjectOptions.first,
                onChanged: (val) => safeSetState(() => _model.dropdownValue2 = val),
                controller: _model.dropdownValueController2,
              ),
            ),
          ].divide(const SizedBox(width: 16.0)),
        ),
        _buildDropDownField(
          context,
          label: 'Teacher',
          hint: 'Select Teacher',
          icon: Icons.person_rounded,
          options: AppConstants.teacherOptions,
          initialValue: _model.dropdownValue3 ?? AppConstants.teacherOptions.first,
          onChanged: (val) => safeSetState(() => _model.dropdownValue3 = val),
          controller: _model.dropdownValueController3,
          fullWidth: true,
        ),
        wrapWithModel(
          model: _model.textFieldModel3,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            label: 'Chapter',
            labelPresent: true,
            helper: '',
            helperPresent: false,
            leadingIcon: Icon(
              Icons.bookmark_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            leadingIconPresent: true,
            trailingIconPresent: false,
            hint: 'Enter chapter name',
            value: '',
            variant: 'outlined',
            error: false,
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildDropDownField(
    BuildContext context, {
    required String label,
    required String hint,
    required List<String> options,
    required String initialValue,
    required Function(String?) onChanged,
    FormFieldController<String>? controller,
    IconData icon = Icons.arrow_drop_down_rounded,
    bool fullWidth = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: FlutterFlowTheme.of(context).labelMedium),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: FlutterFlowDropDown<String>(
            controller: controller ??= FormFieldController<String>(initialValue),
            options: options,
            onChanged: onChanged,
            width: fullWidth ? double.infinity : 200.0,
            height: 40.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            hintText: hint,
            icon: Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 1.0,
            borderRadius: 12.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            hidesUnderline: true,
            isOverButton: false,
            isSearchable: false,
            isMultiSelect: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formSectionHeaderModel2,
          updateCallback: () => safeSetState(() {}),
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.list_alt_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Topics Covered',
          ),
        ),
        wrapWithModel(
          model: _model.textFieldModel4,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            label: 'Detailed Topics',
            labelPresent: true,
            helper: '',
            helperPresent: false,
            leadingIcon: Icon(
              Icons.topic_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            leadingIconPresent: true,
            trailingIconPresent: false,
            hint: 'List the specific topics taught today...',
            value: '',
            variant: 'outlined',
            error: false,
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildStudentCountSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formSectionHeaderModel3,
          updateCallback: () => safeSetState(() {}),
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.people_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Student Count',
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: _model.studentCounterModel1,
                updateCallback: () => safeSetState(() {}),
                child: StudentCounterWidget(
                  label: 'Present',
                  subtitle: 'Students in class',
                  value: _presentCount.toString().padLeft(2, '0'),
                  onDecrement: () {
                    if (_presentCount > 0) safeSetState(() => _presentCount -= 1);
                  },
                  onIncrement: () => safeSetState(() => _presentCount += 1),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: _model.studentCounterModel2,
                updateCallback: () => safeSetState(() {}),
                child: StudentCounterWidget(
                  label: 'Absent',
                  subtitle: 'Students missing',
                  value: _absentCount.toString().padLeft(2, '0'),
                  onDecrement: () {
                    if (_absentCount > 0) safeSetState(() => _absentCount -= 1);
                  },
                  onIncrement: () => safeSetState(() => _absentCount += 1),
                ),
              ),
            ),
          ].divide(const SizedBox(width: 16.0)),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formSectionHeaderModel4,
          updateCallback: () => safeSetState(() {}),
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.assignment_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Additional Info',
          ),
        ),
        wrapWithModel(
          model: _model.textFieldModel5,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            label: 'Homework Assigned',
            labelPresent: true,
            helper: '',
            helperPresent: false,
            leadingIcon: Icon(
              Icons.edit_note_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            leadingIconPresent: true,
            trailingIconPresent: false,
            hint: 'Describe the homework...',
            value: '',
            variant: 'outlined',
            error: false,
          ),
        ),
        wrapWithModel(
          model: _model.textFieldModel6,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            label: 'Remarks',
            labelPresent: true,
            helper: '',
            helperPresent: false,
            leadingIcon: Icon(
              Icons.notes_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            leadingIconPresent: true,
            trailingIconPresent: false,
            hint: 'Any other observations...',
            value: '',
            variant: 'outlined',
            error: false,
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildFormFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 1.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
              shape: BoxShape.rectangle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: wrapWithModel(
                      model: _model.buttonModel,
                      updateCallback: () => safeSetState(() {}),
                      child: ButtonWidget(
                        icon: Icon(
                          Icons.check_circle_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        iconPresent: true,
                        iconEndPresent: false,
                        content: 'Submit Report',
                        variant: 'primary',
                        size: 'large',
                        fullWidth: false,
                        loading: false,
                        disabled: false,
                        onPressed: () async {
                          // Validate user is authenticated
                          if (FirebaseAuth.instance.currentUser == null) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please sign in to submit a report.'),
                              ),
                            );
                            return;
                          }

                          if (!_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all required fields.'),
                              ),
                            );
                            return;
                          }

                          try {
                            await _repository.submitReport(
                              className: _model.dropdownValue1 ?? '',
                              subject: _model.dropdownValue2 ?? '',
                              teacher: _model.dropdownValue3 ?? '',
                              chapter: _model.textFieldModel3.inputTextController?.text.trim() ?? '',
                              topics: _model.textFieldModel4.inputTextController?.text.trim() ?? '',
                              presentCount: _presentCount,
                              absentCount: _absentCount,
                              homeworkAssigned: _model.textFieldModel5.inputTextController?.text.trim() ?? '',
                              remarks: _model.textFieldModel6.inputTextController?.text.trim() ?? '',
                            );

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Daily report saved to Firebase.'),
                              ),
                            );
                            context.goNamed(HomeDashboardWidget.routeName);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving report: $e'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear Form'),
                              content: const Text('Are you sure you want to clear all fields?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (confirm) {
                        _clearForm();
                      }
                    },
                    child: Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).error10,
                        borderRadius: BorderRadius.circular(16.0),
                        shape: BoxShape.rectangle,
                      ),
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.delete_sweep_rounded,
                        color: FlutterFlowTheme.of(context).onError,
                        size: 24.0,
                      ),
                    ),
                  ),
                ].divide(const SizedBox(width: 16.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
