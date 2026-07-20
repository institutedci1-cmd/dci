import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/announcement_card/announcement_card_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
export 'package:d_c_i_teacher_app/pages/announcements_feed/announcements_feed_model.dart';

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
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
        body: Column(
          children: [
            HeaderSectionWidget(
              title: 'Notice Board',
              subtitle: 'Latest updates & alerts',
              onBackPressed: () async => context.goNamed(HomeDashboardWidget.routeName),
              showActionIcon: false,
            ),
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

  Widget _buildAnnouncementsList(BuildContext context) {
    return ref.watch(announcementsStreamProvider).when(
      data: (announcements) {
        if (announcements.isEmpty) {
          return AppEmptyState(
            icon: Icons.campaign_rounded,
            title: 'No notices posted',
            description: 'Important updates will appear here.',
            actionLabel: 'Post Now',
            onActionPressed: () => _showCreateAnnouncementBottomSheet(context),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return wrapWithModel(
              model: createModel(context, () => AnnouncementCardModel()),
              updateCallback: () => safeSetState(() {}),
              child: AnnouncementCardWidget(
                category: announcement.category,
                date: dateTimeFormat('yMMMd', announcement.createdAt),
                description: announcement.description,
                title: announcement.title,
                onTap: () async => _showAnnouncementDialog(context, announcement),
                onShare: () => _shareAnnouncement(announcement),
              ),
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
    final theme = FlutterFlowTheme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post New Notice',
                      style: AppTypography.title.copyWith(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFieldWidget(
                  controller: titleController,
                  label: 'Title',
                  hint: 'e.g. Weekly Test Schedule',
                  variant: 'outlined',
                ),
                const SizedBox(height: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTypography.body)))
                          .toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val!),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: theme.alternate),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: theme.alternate),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFieldWidget(
                  controller: descriptionController,
                  label: 'Description',
                  hint: 'Provide details about the announcement...',
                  variant: 'outlined',
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  text: 'Post Announcement',
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
                ),
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
