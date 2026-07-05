import '/components/button/button_widget.dart';
import '/components/form_section_header/form_section_header_widget.dart';
import '/components/student_counter/student_counter_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DailyReportFormModel());

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
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                ),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: FlutterFlowTheme.of(context).onPrimary,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.goNamed(HomeDashboardWidget.routeName);
                            },
                          ),
                          Text(
                            'Daily Report',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).onPrimary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                  lineHeight: 1.27,
                                ),
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: FlutterFlowTheme.of(context).onPrimary,
                              size: 24.0,
                            ),
                            onPressed: () {
                              // print('IconButton pressed ...');
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).onPrimary20,
                              borderRadius: BorderRadius.circular(9999.0),
                              shape: BoxShape.rectangle,
                            ),
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: FlutterFlowTheme.of(context).onSurface,
                              size: 24.0,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monday, Oct 23, 2023',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                      lineHeight: 1.5,
                                    ),
                              ),
                              Text(
                                'Deshmukh Coaching Institute',
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary80,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                      lineHeight: 1.38,
                                    ),
                              ),
                            ],
                          ),
                        ].divide(const SizedBox(width: 16.0)),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),
                ),
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
                                Column(
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
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 20.0,
                                      ),
                                      title: 'Class Details',
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: wrapWithModel(
                                          model: _model.textFieldModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextFieldWidget(
                                            label: 'Class',
                                            labelPresent: true,
                                            helper: '',
                                            helperPresent: false,
                                            leadingIcon: Icon(
                                              Icons.class_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0,
                                            ),
                                            leadingIconPresent: true,
                                            trailingIconPresent: false,
                                            hint: 'e.g. 10th A',
                                            value: '',
                                            onChange: '',
                                            onSubmit: '',
                                            variant: 'outlined',
                                            error: false,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: wrapWithModel(
                                          model: _model.textFieldModel2,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextFieldWidget(
                                            label: 'Subject',
                                            labelPresent: true,
                                            helper: '',
                                            helperPresent: false,
                                            leadingIcon: Icon(
                                              Icons.menu_book_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0,
                                            ),
                                            leadingIconPresent: true,
                                            trailingIconPresent: false,
                                            hint: 'e.g. Mathematics',
                                            value: '',
                                            onChange: '',
                                            onSubmit: '',
                                            variant: 'outlined',
                                            error: false,
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 16.0)),
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      leadingIconPresent: true,
                                      trailingIconPresent: false,
                                      hint: 'Enter chapter name',
                                      value: '',
                                      onChange: '',
                                      onSubmit: '',
                                      variant: 'outlined',
                                      error: false,
                                    ),
                                  ),
                                ].divide(const SizedBox(height: 16.0)),
                              ),
                              Column(
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
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      leadingIconPresent: true,
                                      trailingIconPresent: false,
                                      hint:
                                          'List the specific topics taught today...',
                                      value: '',
                                      onChange: '',
                                      onSubmit: '',
                                      variant: 'outlined',
                                      error: false,
                                    ),
                                  ),
                                ].divide(const SizedBox(height: 16.0)),
                              ),
                              Column(
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
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 20.0,
                                      ),
                                      title: 'Student Count',
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: wrapWithModel(
                                          model: _model.studentCounterModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: const StudentCounterWidget(
                                            label: 'Present',
                                            subtitle: 'Students in class',
                                            value: '42',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: wrapWithModel(
                                          model: _model.studentCounterModel2,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: const StudentCounterWidget(
                                            label: 'Absent',
                                            subtitle: 'Students missing',
                                            value: '03',
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 16.0)),
                                  ),
                                ].divide(const SizedBox(height: 16.0)),
                              ),
                              Column(
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
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      leadingIconPresent: true,
                                      trailingIconPresent: false,
                                      hint: 'Describe the homework...',
                                      value: '',
                                      onChange: '',
                                      onSubmit: '',
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      leadingIconPresent: true,
                                      trailingIconPresent: false,
                                      hint: 'Any other observations...',
                                      value: '',
                                      onChange: '',
                                      onSubmit: '',
                                      variant: 'outlined',
                                      error: false,
                                    ),
                                  ),
                                ].divide(const SizedBox(height: 16.0)),
                              ),
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
          Container(
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
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please sign in to submit a report.'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (!_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please complete all required fields.'),
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('daily_reports')
                                        .add({
                                      'class': '10th Grade',
                                      'subject': 'Mathematics',
                                      'chapter': 'Chapter 5 - Polynomials',
                                      'topics': 'Factorization, Identities',
                                      'presentCount': '42',
                                      'absentCount': '03',
                                      'homeworkAssigned': 'Exercise 5.1 and 5.2',
                                      'remarks': 'Good class participation',
                                      'createdBy': FirebaseAuth.instance
                                              .currentUser?.uid ??
                                          '',
                                      'createdByEmail': FirebaseAuth.instance
                                              .currentUser?.email ??
                                          '',
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Daily report saved to Firebase.'),
                                      ),
                                    );
                                    context.goNamed(
                                        HomeDashboardWidget.routeName);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
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
                          Container(
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
                        ].divide(const SizedBox(width: 16.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
