import '/backend/repositories/homework_repository.dart';
import '/backend/services/app_constants.dart';
import '/components/button/button_widget.dart';
import '/components/form_label/form_label_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homework_assignment_model.dart';
export 'homework_assignment_model.dart';

class HomeworkAssignmentWidget extends StatefulWidget {
  const HomeworkAssignmentWidget({super.key});

  static String routeName = 'HomeworkAssignment';
  static String routePath = '/homeworkAssignment';

  @override
  State<HomeworkAssignmentWidget> createState() =>
      _HomeworkAssignmentWidgetState();
}

class _HomeworkAssignmentWidgetState extends State<HomeworkAssignmentWidget> {
  late HomeworkAssignmentModel _model;
  final HomeworkRepository _repository = HomeworkRepository();

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
              model: _model.headerSectionModel,
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Assign Homework',
                onBackPressed: () async {
                  context.safePop();
                },
                actionIcon: Icon(
                  Icons.history_rounded,
                  color: FlutterFlowTheme.of(context).onPrimary,
                  size: 24.0,
                ),
                onActionPressed: () async {
                  context.pushNamed(HomeworkHistoryWidget.routeName);
                },
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
                                _buildClassSubjectTeacherSection(context),
                                _buildAssignmentDetailsSection(context),
                                _buildDueDateSection(context),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).info,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.info_rounded,
                                          size: 20.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'This assignment will be visible to all students in the selected class immediately after submission.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall,
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 16.0)),
                                    ),
                                  ),
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
            _buildHomeworkFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSubjectTeacherSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            wrapWithModel(
              model: _model.formLabelModel1,
              updateCallback: () => safeSetState(() {}),
              child: const FormLabelWidget(label: 'Select Class'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDropDown(
                context,
                controller: _model.dropdownValueController1,
                initialValue: _model.dropdownValue1 ?? AppConstants.classOptions.last,
                options: AppConstants.classOptions,
                hintText: 'Choose a class',
                onChanged: (val) => safeSetState(() => _model.dropdownValue1 = val),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            wrapWithModel(
              model: _model.formLabelModel2,
              updateCallback: () => safeSetState(() {}),
              child: const FormLabelWidget(label: 'Subject'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDropDown(
                context,
                controller: _model.dropdownValueController2,
                initialValue: _model.dropdownValue2 ?? AppConstants.subjectOptions.first,
                options: AppConstants.subjectOptions,
                hintText: 'Choose a subject',
                icon: Icons.menu_book_rounded,
                onChanged: (val) => safeSetState(() => _model.dropdownValue2 = val),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            wrapWithModel(
              model: createModel(context, () => FormLabelModel()),
              updateCallback: () => safeSetState(() {}),
              child: const FormLabelWidget(label: 'Assigned By (Teacher)'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDropDown(
                context,
                controller: _model.dropdownValueController3,
                initialValue: _model.dropdownValue3 ?? AppConstants.teacherOptions.first,
                options: AppConstants.teacherOptions,
                hintText: 'Choose a teacher',
                icon: Icons.person_rounded,
                onChanged: (val) => safeSetState(() => _model.dropdownValue3 = val),
              ),
            ),
          ],
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildDropDown(BuildContext context,
      {required FormFieldController<String>? controller,
      required String initialValue,
      required List<String> options,
      required String hintText,
      IconData icon = Icons.arrow_drop_down_rounded,
      required Function(String?) onChanged}) {
    return FlutterFlowDropDown<String>(
      controller: controller ??= FormFieldController<String>(initialValue),
      options: options,
      onChanged: onChanged,
      width: 200.0,
      height: 40.0,
      textStyle: FlutterFlowTheme.of(context).bodyMedium,
      hintText: hintText,
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
    );
  }

  Widget _buildAssignmentDetailsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formLabelModel3,
          updateCallback: () => safeSetState(() {}),
          child: const FormLabelWidget(label: 'Assignment Details'),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                wrapWithModel(
                  model: _model.textFieldModel1,
                  updateCallback: () => safeSetState(() {}),
                  child: const TextFieldWidget(
                    label: 'Homework Title',
                    labelPresent: true,
                    helper: '',
                    helperPresent: false,
                    leadingIconPresent: false,
                    trailingIconPresent: false,
                    hint: 'e.g. Quadratic Equations Practice',
                    value: '',
                    variant: 'ghost',
                    error: false,
                  ),
                ),
                Divider(
                  height: 16.0,
                  thickness: 1.0,
                  indent: 0.0,
                  endIndent: 0.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                wrapWithModel(
                  model: _model.textFieldModel2,
                  updateCallback: () => safeSetState(() {}),
                  child: const TextFieldWidget(
                    label: 'Description',
                    labelPresent: true,
                    helper: '',
                    helperPresent: false,
                    leadingIconPresent: false,
                    trailingIconPresent: false,
                    hint: 'Describe the tasks or questions...',
                    value: '',
                    variant: 'ghost',
                    error: false,
                  ),
                ),
              ].divide(const SizedBox(height: 16.0)),
            ),
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildDueDateSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.formLabelModel4,
          updateCallback: () => safeSetState(() {}),
          child: const FormLabelWidget(label: 'Due Date'),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 20.0,
                    ),
                    Text(
                      _model.dueDate != null
                          ? dateTimeFormat('yMMMd', _model.dueDate)
                          : 'Select Due Date',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ].divide(const SizedBox(width: 16.0)),
                ),
                wrapWithModel(
                  model: _model.buttonModel1,
                  updateCallback: () => safeSetState(() {}),
                  child: ButtonWidget(
                    icon: Icon(
                      Icons.edit_calendar_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                    iconPresent: true,
                    iconEndPresent: false,
                    content: 'Change',
                    variant: 'ghost',
                    size: 'small',
                    fullWidth: false,
                    loading: false,
                    disabled: false,
                    onPressed: () async {
                      final datePickedDate = await showDatePicker(
                        context: context,
                        initialDate: _model.dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050),
                      );

                      if (datePickedDate != null) {
                        safeSetState(() {
                          _model.dueDate = DateTime(
                            datePickedDate.year,
                            datePickedDate.month,
                            datePickedDate.day,
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildHomeworkFooter(BuildContext context) {
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
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: wrapWithModel(
                    model: _model.buttonModel2,
                    updateCallback: () => safeSetState(() {}),
                    child: ButtonWidget(
                      iconPresent: false,
                      iconEndPresent: false,
                      content: 'Save Draft',
                      variant: 'outline',
                      size: 'medium',
                      fullWidth: true,
                      loading: false,
                      disabled: false,
                      onPressed: () async {
                        // Validate user is authenticated
                        if (FirebaseAuth.instance.currentUser == null) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please sign in to save homework.'),
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
                          await _repository.saveHomework(
                            className: _model.dropdownValue1 ?? '',
                            subject: _model.dropdownValue2 ?? '',
                            teacher: _model.dropdownValue3 ?? '',
                            title: _model.textFieldModel1.inputTextController!.text,
                            description: _model.textFieldModel2.inputTextController!.text,
                            dueDate: _model.dueDate != null
                                ? dateTimeFormat('yMMMd', _model.dueDate)
                                : 'No Due Date',
                            status: 'draft',
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draft saved to Firebase.'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving draft: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: wrapWithModel(
                    model: _model.buttonModel3,
                    updateCallback: () => safeSetState(() {}),
                    child: ButtonWidget(
                      icon: Icon(
                        Icons.send_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                      iconPresent: true,
                      iconEndPresent: false,
                      content: 'Publish',
                      variant: 'primary',
                      size: 'medium',
                      fullWidth: true,
                      loading: false,
                      disabled: false,
                      onPressed: () async {
                        // Validate user is authenticated
                        if (FirebaseAuth.instance.currentUser == null) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please sign in to publish homework.'),
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
                          await _repository.saveHomework(
                            className: _model.dropdownValue1 ?? '',
                            subject: _model.dropdownValue2 ?? '',
                            teacher: _model.dropdownValue3 ?? '',
                            title: _model.textFieldModel1.inputTextController!.text,
                            description: _model.textFieldModel2.inputTextController!.text,
                            dueDate: _model.dueDate != null
                                ? dateTimeFormat('yMMMd', _model.dueDate)
                                : 'No Due Date',
                            status: 'published',
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Homework published.'),
                            ),
                          );
                          context.goNamed(HomeDashboardWidget.routeName);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error publishing homework: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ].divide(const SizedBox(width: 16.0)),
            ),
          ),
        ],
      ),
    );
  }
}
