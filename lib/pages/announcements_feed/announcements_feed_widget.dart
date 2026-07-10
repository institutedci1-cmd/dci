import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../backend/models/announcement.dart';
import '../../backend/providers/repository_providers.dart';
import '../../components/announcement_card/announcement_card_widget.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_style.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../index.dart';

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
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateAnnouncementBottomSheet(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildAnnouncementsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
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
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () async => context.goNamed(HomeDashboardWidget.routeName),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                'Announcements',
                style: AppTypography.h1.copyWith(color: Colors.white),
              ),
              Text(
                'Latest updates from Deshmukh Institute',
                style: AppTypography.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: ref.watch(announcementRepositoryProvider).getAnnouncementsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final announcements = snapshot.data ?? [];
        if (announcements.isEmpty) {
          return Center(
            child: Text(
              'No announcements found.',
              style: AppTypography.body,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
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

  void _showCreateAnnouncementBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'GENERAL';
    final categories = ['GENERAL', 'EXAM', 'EVENT', 'HOLIDAY', 'URGENT'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
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
                style: AppTypography.h1,
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
                value: selectedCategory,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => selectedCategory = val!,
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
                  backgroundColor: AppColors.primary,
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
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(announcement.description, style: AppTypography.body),
              if (announcement.link != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => launchURL(announcement.link!),
                  child: Text(
                    'View Attachment/Link',
                    style: AppTypography.body.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Announcement?'),
                  content: const Text('This will remove it from the feed.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ) ?? false;
              if (confirm) {
                await ref.read(announcementRepositoryProvider).deleteAnnouncement(announcement.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
