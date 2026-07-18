import '/backend/models/announcement.dart';
import '/backend/providers/repository_providers.dart';
import '/components/announcement_card/announcement_card_widget.dart';
import '/components/shared/app_bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _shareAnnouncement(Announcement announcement) async {
    final isParentMeeting = announcement.category == 'PARENT_MEETING';
    final message = isParentMeeting 
      ? '''
🤝 *Parent Meeting Invitation*
Title: ${announcement.title}
Date: ${dateTimeFormat('yMMMd', announcement.createdAt ?? DateTime.now())}

Dear Parents,
${announcement.description}

Please make it convenient to attend.
Regards,
DCI Team
'''
      : '''
📢 *New Announcement: ${announcement.title}*
Category: ${announcement.category}
Date: ${dateTimeFormat('yMMMd', announcement.createdAt ?? DateTime.now())}

${announcement.description}

Read more in the DCI Teacher App.
''';

    try {
      final whatsappService = ref.read(whatsappServiceProvider);
      await whatsappService.launchWhatsapp(message: message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateAnnouncementBottomSheet(context),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildAnnouncementsList(context),
            ),
            AppBottomNavBar(
              currentIndex: -1,
              onTap: (index) {
                final routes = [
                  HomeDashboardWidget.routeName,
                  ReportsDashboardWidget.routeName,
                  AttendanceDashboardWidget.routeName,
                  TeacherProfileWidget.routeName,
                ];
                context.goNamed(routes[index]);
              },
            ),
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
              const SizedBox(width: 40),
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
                'Latest updates from DCI Teachers',
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
    return ref.watch(announcementsStreamProvider).when(
      data: (announcements) {
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
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return AnnouncementCardWidget(
              category: announcement.category,
              date: dateTimeFormat('yMMMd', announcement.createdAt),
              description: announcement.description,
              title: announcement.title,
              onTap: () async => _showAnnouncementDialog(context, announcement),
              onShare: () => _shareAnnouncement(announcement),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  void _showCreateAnnouncementBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'GENERAL';
    final categories = ['GENERAL', 'EXAM', 'EVENT', 'HOLIDAY', 'URGENT', 'PARENT_MEETING'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Post New Announcement',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Weekly Test Schedule',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedCategory = val!),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide details about the announcement...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    await ref.read(announcementRepositoryProvider).createAnnouncement(
                          title: titleController.text,
                          description: descriptionController.text,
                          category: selectedCategory,
                        );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Announcement posted successfully')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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
}
