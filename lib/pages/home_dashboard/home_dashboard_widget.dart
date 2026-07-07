import '/auth/firebase_auth/auth_util.dart';
import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/components/dashboard_card/dashboard_card_widget.dart';
import '/components/recent_activity_item/recent_activity_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
export 'home_dashboard_model.dart';

class HomeDashboardWidget extends ConsumerStatefulWidget {
  const HomeDashboardWidget({super.key});

  static String routeName = 'HomeDashboard';
  static String routePath = '/homeDashboard';

  @override
  ConsumerState<HomeDashboardWidget> createState() => _HomeDashboardWidgetState();
}

class _HomeDashboardWidgetState extends ConsumerState<HomeDashboardWidget> {
  late HomeDashboardModel _model;

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
        body: currentUserUid.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserUid)
                    .get(),
                builder: (context, userSnapshot) {
            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('config')
                  .doc('dashboard_config')
                  .get(),
              builder: (context, configSnapshot) {
                final dashboardConfig =
                    configSnapshot.data?.data() as Map<String, dynamic>?;

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopHeader(context, userData),
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
                                      _buildSectionTitle(context, 'Management Modules'),
                                      _buildModulesGrid(context),
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

  Widget _buildTopHeader(BuildContext context, Map<String, dynamic>? userData) {
    return Container(
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
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 48.0, 20.0, 32.0),
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).onBackground80,
                            lineHeight: 1.47,
                          ),
                    ),
                    Text(
                      userData?['display_name'] ??
                          (currentUserDisplayName != ''
                              ? currentUserDisplayName
                              : 'Prof. Rajesh Deshmukh'),
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).onBackground,
                            lineHeight: 1.3,
                          ),
                    ),
                  ].divide(const SizedBox(height: 4.0)),
                ),
                FlutterFlowIconButton(
                  borderRadius: 9999.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).onPrimary15,
                  icon: Icon(
                    Icons.search_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                  onPressed: () => context.pushNamed(StudentListWidget.routeName),
                ),
                Stack(
                  alignment: const AlignmentDirectional(1.0, -1.0),
                  children: [
                    FlutterFlowIconButton(
                      borderRadius: 9999.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).onPrimary15,
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: FlutterFlowTheme.of(context).onPrimary,
                        size: 24.0,
                      ),
                      onPressed: () =>
                          context.pushNamed(NotificationsWidget.routeName),
                    ),
                    FutureBuilder<int>(
                      future: ref
                          .read(notificationRepositoryProvider)
                          .getUnreadCountStream()
                          .first,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            count > 9 ? '9+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                FlutterFlowIconButton(
                  borderRadius: 9999.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).onPrimary15,
                  icon: Icon(
                    Icons.logout_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (!context.mounted) return;
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
                  color: FlutterFlowTheme.of(context).onBackground,
                  size: 18.0,
                ),
                Text(
                  dateTimeFormat('MMMMEEEEd', getCurrentTimestamp),
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).onBackground,
                        lineHeight: 1.33,
                      ),
                ),
              ].divide(const SizedBox(width: 8.0)),
            ),
            const SizedBox(height: 16),
            _buildGlobalSearch(context),
          ].divide(const SizedBox(height: 24.0)),
        ),
      ),
    );
  }

  Widget _buildGlobalSearch(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(StudentListWidget.routeName),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).onPrimary15,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: FlutterFlowTheme.of(context).onPrimary80),
            const SizedBox(width: 12),
            Text(
              'Search students, reports...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).onPrimary80,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            color: FlutterFlowTheme.of(context).primaryText,
            lineHeight: 1.35,
          ),
    );
  }

  Widget _buildModulesGrid(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.dashboardCardModel1,
                updateCallback: () => safeSetState(() {}),
                child: const DashboardCardWidget(
                  target: 'DailyReport',
                  title: 'Daily Report',
                  icon: Icon(Icons.assessment_rounded),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: wrapWithModel(
                model: _model.dashboardCardModel2,
                updateCallback: () => safeSetState(() {}),
                child: const DashboardCardWidget(
                  target: 'Attendance',
                  title: 'Attendance',
                  icon: Icon(Icons.fact_check_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.dashboardCardModel3,
                updateCallback: () => safeSetState(() {}),
                child: const DashboardCardWidget(
                  target: 'Homework',
                  title: 'Homework',
                  icon: Icon(Icons.edit_note_rounded),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: wrapWithModel(
                model: _model.dashboardCardModel4,
                updateCallback: () => safeSetState(() {}),
                child: const DashboardCardWidget(
                  target: 'TeacherProfile',
                  title: 'Profile',
                  icon: Icon(Icons.person_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.dashboardCardModel5,
                updateCallback: () => safeSetState(() {}),
                child: const DashboardCardWidget(
                  target: 'Announcements',
                  title: 'Announcements',
                  icon: Icon(Icons.campaign_rounded),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: wrapWithModel(
                model: _model.dashboardCardModel6,
                updateCallback: () => safeSetState(() {}),
                child: const DashboardCardWidget(
                  target: 'Students',
                  title: 'Students',
                  icon: Icon(Icons.people_rounded),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Recent Activity'),
        const SizedBox(height: 12.0),
        FutureBuilder<List<DailyReport>>(
          future: ref.read(dailyReportRepositoryProvider).getRecentReports(limit: 3).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reports = snapshot.data!;
            if (reports.isEmpty) {
              return Text(
                'No recent activity found.',
                style: FlutterFlowTheme.of(context).bodySmall,
              );
            }
            return Column(
              children: reports.map((report) {
                return RecentActivityItemWidget(
                  title: '${report.className} - ${report.subject}',
                  subtitle: 'Topic: ${report.chapter}\n${dateTimeFormat('yMMMd', report.createdAt)}',
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
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primary,
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
