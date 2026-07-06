import '/auth/firebase_auth/auth_util.dart';
import '/backend/repositories/daily_report_repository.dart';
import '/components/dashboard_card/dashboard_card_widget.dart';
import '/components/recent_activity_item/recent_activity_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_dashboard_model.dart';
export 'home_dashboard_model.dart';

class HomeDashboardWidget extends StatefulWidget {
  const HomeDashboardWidget({super.key});

  static String routeName = 'HomeDashboard';
  static String routePath = '/homeDashboard';

  @override
  State<HomeDashboardWidget> createState() => _HomeDashboardWidgetState();
}

class _HomeDashboardWidgetState extends State<HomeDashboardWidget> {
  late HomeDashboardModel _model;
  final DailyReportRepository _repository = DailyReportRepository();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeDashboardModel());

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
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .snapshots(),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('config')
                  .doc('dashboard_config')
                  .snapshots(),
              builder: (context, configSnapshot) {
                final dashboardConfig =
                    configSnapshot.data?.data() as Map<String, dynamic>?;

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FlutterFlowTheme.of(context).primary,
                            FlutterFlowTheme.of(context).tertiary
                          ],
                          stops: const [0.0, 1.0],
                          begin: const AlignmentDirectional(0.0, -1.0),
                          end: const AlignmentDirectional(0, 1.0),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32.0),
                          bottomRight: Radius.circular(32.0),
                        ),
                        shape: BoxShape.rectangle,
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 48.0, 20.0, 32.0),
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onBackground80,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.47,
                                            ),
                                      ),
                                      Text(
                                        userData?['display_name'] ??
                                            (currentUserDisplayName != ''
                                                ? currentUserDisplayName
                                                : 'Prof. Rajesh Deshmukh'),
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onBackground,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ].divide(const SizedBox(height: 4.0)),
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 9999.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .onPrimary15,
                                    icon: Icon(
                                      Icons.logout_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      await authManager.signOut();
                                      context.goNamed(LoginWidget.routeName);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .onBackground,
                                    size: 18.0,
                                  ),
                                  Text(
                                    dateTimeFormat(
                                        'MMMMEEEEd', getCurrentTimestamp),
                                    style: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelLarge
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .onBackground,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                          lineHeight: 1.33,
                                        ),
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ].divide(const SizedBox(height: 24.0)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Management Modules',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                              lineHeight: 1.35,
                                            ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: _model
                                                      .dashboardCardModel1,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor:
                                                        const Color(0x00000000),
                                                    icon: Icon(
                                                      Icons.assessment_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .info,
                                                    target: 'DailyReport',
                                                    title: 'Daily Report',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: _model
                                                      .dashboardCardModel2,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor:
                                                        const Color(0x00000000),
                                                    icon: Icon(
                                                      Icons.fact_check_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .success,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .success,
                                                    target: 'Attendance',
                                                    title: 'Attendance',
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 16.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: _model
                                                      .dashboardCardModel3,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor:
                                                        const Color(0x00000000),
                                                    icon: Icon(
                                                      Icons.edit_note_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .warning,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .warning,
                                                    target: 'Homework',
                                                    title: 'Homework',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: _model
                                                      .dashboardCardModel4,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryContainer,
                                                    icon: Icon(
                                                      Icons.person_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    target: 'TeacherProfile',
                                                    title: 'Profile',
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 16.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: _model
                                                      .dashboardCardModel5,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor:
                                                        const Color(0x00000000),
                                                    icon: Icon(
                                                      Icons.campaign_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .error,
                                                    target: 'Announcements',
                                                    title: 'Announcements',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: _model
                                                      .dashboardCardModel6,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor:
                                                        const Color(0x00000000),
                                                    icon: Icon(
                                                      Icons.people_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                    target: 'Students',
                                                    title: 'Students',
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 16.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: wrapWithModel(
                                                  model: createModel(context,
                                                      () => DashboardCardModel()),
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: DashboardCardWidget(
                                                    bgColor:
                                                        const Color(0x00000000),
                                                    icon: Icon(
                                                      Icons.info_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                      size: 28.0,
                                                    ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                    target: 'AboutDeshmukh',
                                                    title: 'About Institute',
                                                  ),
                                                ),
                                              ),
                                              const Spacer(flex: 1),
                                            ].divide(
                                                const SizedBox(width: 16.0)),
                                          ),
                                        ].divide(const SizedBox(height: 16.0)),
                                      ),
                                      const SizedBox(height: 24.0),
                                      _buildRecentActivitySection(context),
                                      const SizedBox(height: 24.0),
                                      _buildAIHelpSection(context, dashboardConfig),
                                    ].divide(const SizedBox(height: 24.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomNavBar(context),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
        const SizedBox(height: 12.0),
        StreamBuilder<QuerySnapshot>(
          stream: _repository.getRecentReports(limit: 3),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final reports = snapshot.data!.docs;
            if (reports.isEmpty) {
              return Text(
                'No recent activity found.',
                style: FlutterFlowTheme.of(context).bodySmall,
              );
            }
            return Column(
              children: reports.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['createdAt'] as Timestamp?)?.toDate();
                return RecentActivityItemWidget(
                  title: '${data['class']} - ${data['subject']}',
                  subtitle: 'Topic: ${data['chapter']}\n${dateTimeFormat('yMMMd', date)}',
                  onTap: () => context.pushNamed(ReportHistoryWidget.routeName),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAIHelpSection(BuildContext context, Map<String, dynamic>? dashboardConfig) {
    return InkWell(
      onTap: () async {
        if (dashboardConfig?['ai_help_url'] != null) {
          await launchURL(dashboardConfig!['ai_help_url']);
        }
      },
      child: Container(
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
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary10,
                    borderRadius: BorderRadius.circular(12.0),
                    shape: BoxShape.rectangle,
                  ),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dashboardConfig?['ai_title'] ?? 'Deshmukh AI Assistant',
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.33,
                            ),
                      ),
                      Text(
                        dashboardConfig?['ai_description'] ??
                            'Need help with lesson planning or student data?',
                        maxLines: 2,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              lineHeight: 1.38,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ].divide(const SizedBox(height: 4.0)),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 24.0,
                ),
              ].divide(const SizedBox(width: 16.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem(
                    context,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: true,
                    onTap: () => context.goNamed(HomeDashboardWidget.routeName),
                  ),
                  _buildNavBarItem(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Reports',
                    onTap: () => context.goNamed(ReportsDashboardWidget.routeName),
                  ),
                  _buildNavBarItem(
                    context,
                    icon: Icons.event_note_outlined,
                    label: 'Attend.',
                    onTap: () => context.goNamed(AttendanceDashboardWidget.routeName),
                  ),
                  _buildNavBarItem(
                    context,
                    icon: Icons.account_circle_outlined,
                    label: 'Profile',
                    onTap: () => context.goNamed(TeacherProfileWidget.routeName),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final color = isSelected
        ? FlutterFlowTheme.of(context).primary
        : FlutterFlowTheme.of(context).secondaryText;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
