import '/backend/models/announcement.dart';
import '/backend/providers/repository_providers.dart';
import '/components/announcement_card/announcement_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'announcements_feed_model.dart';
export 'announcements_feed_model.dart';

class AnnouncementsFeedWidget extends ConsumerStatefulWidget {
  const AnnouncementsFeedWidget({super.key});

  static String routeName = 'AnnouncementsFeed';
  static String routePath = '/announcementsFeed';

  @override
  ConsumerState<AnnouncementsFeedWidget> createState() =>
      _AnnouncementsFeedWidgetState();
}

class _AnnouncementsFeedWidgetState extends ConsumerState<AnnouncementsFeedWidget> {
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildAnnouncementsList(context),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                onPressed: () async => context.goNamed(HomeDashboardWidget.routeName),
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
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                'Announcements',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Latest updates from Deshmukh Institute',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).onPrimary80,
                ),
              ),
            ].divide(const SizedBox(height: 4.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: ref.watch(announcementRepositoryProvider).getAnnouncementsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final announcements = snapshot.data!;
        if (announcements.isEmpty) {
          return Center(
            child: Text(
              'No announcements found.',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: announcements.length + 1,
          itemBuilder: (context, index) {
            if (index == announcements.length) {
              return _buildEndOfList();
            }
            final announcement = announcements[index];
            return AnnouncementCardWidget(
              category: announcement.category,
              date: dateTimeFormat('yMMMd', announcement.createdAt),
              description: announcement.description,
              title: announcement.title,
              onTap: () async => _showAnnouncementDialog(context, announcement),
            );
          },
        );
      },
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, color: FlutterFlowTheme.of(context).onSurface, size: 20.0),
          Text(
            'You\'re all caught up!',
            style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).onSurface,
            ),
          ),
        ].divide(const SizedBox(height: 4.0)),
      ),
    );
  }

  void _showAnnouncementDialog(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.category,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(announcement.description, style: FlutterFlowTheme.of(context).bodyMedium),
              if (announcement.link != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => launchURL(announcement.link!),
                  child: Text(
                    'View Attachment/Link',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(decoration: TextDecoration.underline),
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(top: BorderSide(color: FlutterFlowTheme.of(context).alternate)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home_rounded, 'Home', false, () => context.goNamed(HomeDashboardWidget.routeName)),
          _buildNavBarItem(Icons.assessment_rounded, 'Report', false, () => context.goNamed(DailyReportFormWidget.routeName)),
          _buildNavBarItem(Icons.campaign_rounded, 'Notices', true, () {}),
          _buildNavBarItem(Icons.person_rounded, 'Profile', false, () => context.goNamed(TeacherProfileWidget.routeName)),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    final color = isSelected ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).secondaryText;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
