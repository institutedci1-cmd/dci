import '/auth/firebase_auth/auth_util.dart';
import '/backend/repositories/attendance_repository.dart';
import '/backend/services/validation_service.dart';
import '/components/attendance_option/attendance_option_widget.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'attendance_tracker_model.dart';
export 'attendance_tracker_model.dart';

class AttendanceTrackerWidget extends StatefulWidget {
  const AttendanceTrackerWidget({super.key});

  static String routeName = 'AttendanceTracker';
  static String routePath = '/attendanceTracker';

  @override
  State<AttendanceTrackerWidget> createState() =>
      _AttendanceTrackerWidgetState();
}

class _AttendanceTrackerWidgetState extends State<AttendanceTrackerWidget> {
  late AttendanceTrackerModel _model;
  final AttendanceRepository _repository = AttendanceRepository();
  String _attendanceStatus = 'Present';

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttendanceTrackerModel());

    _model.textFieldModel.inputTextControllerValidator =
        (BuildContext context, String? value) {
      return ValidationService.validateAttendanceReason(value, _attendanceStatus);
    };

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
              model: createModel(context, () => HeaderSectionModel()),
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Attendance',
                subtitle: dateTimeFormat('MMMMEEEEd', getCurrentTimestamp),
                onBackPressed: () async =>
                    context.goNamed(AttendanceDashboardWidget.routeName),
                actionIcon: Icon(
                  Icons.history_rounded,
                  color: FlutterFlowTheme.of(context).onPrimary,
                  size: 24.0,
                ),
                onActionPressed: () async =>
                    context.pushNamed(AttendanceHistoryWidget.routeName),
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('attendance_records')
                    .where('createdBy', isEqualTo: currentUserUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final records = snapshot.data?.docs ?? [];
                  final now = DateTime.now();
                  final firstDayOfMonth = DateTime(now.year, now.month, 1);
                  final monthlyRecords = records.where((doc) {
                    final createdAt =
                        (doc.data() as Map<String, dynamic>)['createdAt']
                            as Timestamp?;
                    return createdAt != null &&
                        createdAt.toDate().isAfter(firstDayOfMonth);
                  }).toList();

                  final presentCount = monthlyRecords
                      .where((doc) =>
                          (doc.data() as Map<String, dynamic>)['status'] ==
                          'Present')
                      .length;
                  final workingDays = 26;
                  presentCount / workingDays;
                  final presentPercentage = monthlyRecords.isEmpty
                      ? 0
                      : ((presentCount / monthlyRecords.length) * 100).toInt();

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('config')
                        .doc('institute_info')
                        .get(),
                    builder: (context, infoSnapshot) {
                      final info =
                          infoSnapshot.data?.data() as Map<String, dynamic>?;
                      final instituteName =
                          info?['name'] ?? 'Deshmukh Coaching Institute';

                      return Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 24.0, 24.0, 0.0),
                                child: _buildUserHeader(context, instituteName),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildDateTimeSection(context),
                                      _buildAttendanceOptions(context),
                                      _buildRemarksSection(context),
                                      _buildProgressSection(context, presentCount, workingDays, presentPercentage),
                                      _buildSaveButton(context),
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, String instituteName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary10,
            borderRadius: BorderRadius.circular(16.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      currentUserDisplayName
                          .split(' ')
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .join(),
                      'JD',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: FlutterFlowTheme.of(context).onPrimary,
                          fontSize: 18.24,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.38,
                        ),
                    overflow: TextOverflow.clip,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${currentUserDisplayName != '' ? currentUserDisplayName : 'John Doe'}',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                              ),
                              color: FlutterFlowTheme.of(context).primaryText,
                              lineHeight: 1.35,
                            ),
                      ),
                      Text(
                        'Faculty • $instituteName',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              lineHeight: 1.38,
                            ),
                      ),
                    ].divide(const SizedBox(height: 4.0)),
                  ),
                ),
              ].divide(const SizedBox(width: 16.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: _buildInfoCard(
            context,
            label: 'Date',
            icon: Icons.calendar_today_rounded,
            value: dateTimeFormat('yMMMd', getCurrentTimestamp),
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildInfoCard(
            context,
            label: 'Shift',
            icon: Icons.schedule_rounded,
            value: 'Morning',
          ),
        ),
      ].divide(const SizedBox(width: 16.0)),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String label, required IconData icon, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    lineHeight: 1.27,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 16.0,
                ),
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.47,
                      ),
                ),
              ].divide(const SizedBox(width: 8.0)),
            ),
          ].divide(const SizedBox(height: 4.0)),
        ),
      ),
    );
  }

  Widget _buildAttendanceOptions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Current Status',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                color: FlutterFlowTheme.of(context).primaryText,
                lineHeight: 1.35,
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
                model: _model.attendanceOptionModel1,
                updateCallback: () => safeSetState(() {}),
                child: AttendanceOptionWidget(
                  icon: Icon(
                    Icons.check_circle_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                  label: 'Present',
                  selected: _attendanceStatus == 'Present',
                  onTap: () => safeSetState(() {
                    _attendanceStatus = 'Present';
                  }),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: _model.attendanceOptionModel2,
                updateCallback: () => safeSetState(() {}),
                child: AttendanceOptionWidget(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                  label: 'Absent',
                  selected: _attendanceStatus == 'Absent',
                  onTap: () => safeSetState(() {
                    _attendanceStatus = 'Absent';
                  }),
                ),
              ),
            ),
          ].divide(const SizedBox(width: 16.0)),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: _model.attendanceOptionModel3,
                updateCallback: () => safeSetState(() {}),
                child: AttendanceOptionWidget(
                  icon: Icon(
                    Icons.event_busy_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                  label: 'Leave',
                  selected: _attendanceStatus == 'Leave',
                  onTap: () => safeSetState(() {
                    _attendanceStatus = 'Leave';
                  }),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: wrapWithModel(
                model: _model.attendanceOptionModel4,
                updateCallback: () => safeSetState(() {}),
                child: AttendanceOptionWidget(
                  icon: Icon(
                    Icons.hourglass_empty_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                  label: 'Half Day',
                  selected: _attendanceStatus == 'Half Day',
                  onTap: () => safeSetState(() {
                    _attendanceStatus = 'Half Day';
                  }),
                ),
              ),
            ),
          ].divide(const SizedBox(width: 16.0)),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildRemarksSection(BuildContext context) {
    return Container(
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
        padding: const EdgeInsets.all(24.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Additional Remarks',
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontWeight: FontWeight.bold,
                      lineHeight: 1.33,
                    ),
              ),
              wrapWithModel(
                model: _model.textFieldModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: '',
                  labelPresent: false,
                  helper: '',
                  helperPresent: false,
                  leadingIconPresent: false,
                  trailingIconPresent: false,
                  hint: 'Enter any specific reason for leave or half-day...',
                  value: '',
                  variant: 'outlined',
                  error: false,
                ),
              ),
            ].divide(const SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, int presentCount,
      int workingDays, int presentPercentage) {
    final progressPercent = (presentCount / workingDays).clamp(0.0, 1.0);
    return Container(
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
        padding: const EdgeInsets.all(24.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Monthly Progress',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          lineHeight: 1.47,
                        ),
                  ),
                  Text(
                    '$presentCount/$workingDays Days',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.47,
                        ),
                  ),
                ],
              ),
              LinearPercentIndicator(
                percent: progressPercent,
                lineHeight: 8.0,
                animation: true,
                animateFromLastPercent: true,
                progressColor: FlutterFlowTheme.of(context).primary,
                backgroundColor: FlutterFlowTheme.of(context).alternate,
                barRadius: const Radius.circular(4.0),
                padding: EdgeInsets.zero,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProgressBadge(context,
                      color: FlutterFlowTheme.of(context).success,
                      label: '$presentPercentage% Present'),
                  _buildProgressBadge(context,
                      color: FlutterFlowTheme.of(context).error,
                      label: '${100 - presentPercentage}% Absent/Leave'),
                ].divide(const SizedBox(width: 24.0)),
              ),
            ].divide(const SizedBox(height: 8.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBadge(BuildContext context,
      {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9999.0),
            shape: BoxShape.rectangle,
          ),
        ),
        Text(
          label,
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
                lineHeight: 1.27,
              ),
        ),
      ].divide(const SizedBox(width: 4.0)),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return wrapWithModel(
      model: _model.buttonModel,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        icon: Icon(
          Icons.save_rounded,
          color: FlutterFlowTheme.of(context).primaryText,
          size: 24.0,
        ),
        iconPresent: true,
        iconEndPresent: false,
        content: 'Save Attendance Record',
        variant: 'primary',
        size: 'large',
        fullWidth: true,
        loading: false,
        disabled: false,
        onPressed: () async {
          // Validate user is authenticated
          if (FirebaseAuth.instance.currentUser == null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please sign in to record attendance.'),
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

          // Validate attendance status is selected
          if (_attendanceStatus.isEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select an attendance status.'),
              ),
            );
            return;
          }

          try {
            await _repository.recordAttendance(
              status: _attendanceStatus,
              remarks: _model.textFieldModel.inputTextController?.text.trim() ?? '',
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance record saved to Firebase.'),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            if (!mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving attendance: $e'),
              ),
            );
          }
        },
      ),
    );
  }
}
