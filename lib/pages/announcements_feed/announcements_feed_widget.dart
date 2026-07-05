import '/components/announcement_card/announcement_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'announcements_feed_model.dart';
export 'announcements_feed_model.dart';

class AnnouncementsFeedWidget extends StatefulWidget {
  const AnnouncementsFeedWidget({super.key});

  static String routeName = 'AnnouncementsFeed';
  static String routePath = '/announcementsFeed';

  @override
  State<AnnouncementsFeedWidget> createState() =>
      _AnnouncementsFeedWidgetState();
}

class _AnnouncementsFeedWidgetState extends State<AnnouncementsFeedWidget> {
  late AnnouncementsFeedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnnouncementsFeedModel());

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
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 48.0, 24.0, 24.0),
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
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.search_rounded,
                              color: FlutterFlowTheme.of(context).onPrimary,
                              size: 24.0,
                            ),
                            onPressed: () {
                              // print('IconButton pressed ...');
                            },
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Announcements',
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).onPrimary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                  lineHeight: 1.25,
                                ),
                          ),
                          Text(
                            'Latest updates from Deshmukh Institute',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).onPrimary80,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  lineHeight: 1.47,
                                ),
                          ),
                        ].divide(const SizedBox(height: 4.0)),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
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
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              wrapWithModel(
                                model: _model.announcementCardModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: const AnnouncementCardWidget(
                                  category: 'EXAM NOTICE',
                                  date: '24 Oct 2023',
                                  description:
                                      'The final term examination schedule for the Fall 2023 semester has been published. Please check the student portal for specific timings and room assignments.',
                                  title:
                                      'Final Term Examination Schedule Released',
                                ),
                              ),
                              wrapWithModel(
                                model: _model.announcementCardModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: const AnnouncementCardWidget(
                                  category: 'HOLIDAY',
                                  date: '22 Oct 2023',
                                  description:
                                      'The institute will remain closed from Oct 30 to Nov 5 for Diwali festivities. Classes will resume on Nov 6 with the regular schedule.',
                                  title: 'Diwali Break Announcement',
                                ),
                              ),
                              wrapWithModel(
                                model: _model.announcementCardModel3,
                                updateCallback: () => safeSetState(() {}),
                                child: const AnnouncementCardWidget(
                                  category: 'EVENT',
                                  date: '20 Oct 2023',
                                  description:
                                      'Join us for a day of athletic excellence and team spirit at the Deshmukh Annual Sports Meet. Participation forms are available at the admin office.',
                                  title: 'Annual Sports Day 2023',
                                ),
                              ),
                              wrapWithModel(
                                model: _model.announcementCardModel4,
                                updateCallback: () => safeSetState(() {}),
                                child: const AnnouncementCardWidget(
                                  category: 'ACADEMIC',
                                  date: '18 Oct 2023',
                                  description:
                                      'Starting next Monday, we are launching a specialized batch for Advanced Physics focusing on quantum mechanics and thermodynamics.',
                                  title: 'New Advanced Physics Batch',
                                ),
                              ),
                              wrapWithModel(
                                model: _model.announcementCardModel5,
                                updateCallback: () => safeSetState(() {}),
                                child: const AnnouncementCardWidget(
                                  category: 'FACULTY',
                                  date: '15 Oct 2023',
                                  description:
                                      'We are pleased to announce that three new experienced teachers have joined the Deshmukh family this month. Please give them a warm welcome.',
                                  title: 'Welcome New Faculty Members',
                                ),
                              ),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Container(
                                    child: Container(
                                      alignment:
                                          const AlignmentDirectional(0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onSurface,
                                            size: 20.0,
                                          ),
                                          Text(
                                            'You\'re all caught up!',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .onSurface,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                  lineHeight: 1.38,
                                                ),
                                          ),
                                        ].divide(const SizedBox(height: 4.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 80.0,
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
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 16.0, 24.0, 16.0),
                    child: Container(
                      child: Container(
                        height: 47.0,
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context
                                      .goNamed(HomeDashboardWidget.routeName);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.home_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Home',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context
                                      .goNamed(DailyReportFormWidget.routeName);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.assessment_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Report',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // Already on Announcements page
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.campaign_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Notices',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context
                                      .goNamed(TeacherProfileWidget.routeName);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Profile',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
