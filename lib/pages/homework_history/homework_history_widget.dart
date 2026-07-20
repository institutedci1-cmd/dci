import 'package:d_c_i_teacher_app/components/homework_card/homework_card_widget.dart';
import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/pages/homework_history/homework_history_model.dart';
export 'package:d_c_i_teacher_app/pages/homework_history/homework_history_model.dart';

class HomeworkHistoryWidget extends ConsumerStatefulWidget {
  const HomeworkHistoryWidget({super.key});

  static String routeName = 'HomeworkHistory';
  static String routePath = '/homeworkHistory';

  @override
  ConsumerState<HomeworkHistoryWidget> createState() => _HomeworkHistoryWidgetState();
}

class _HomeworkHistoryWidgetState extends ConsumerState<HomeworkHistoryWidget> {
  late HomeworkHistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkHistoryModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _shareHomework(HomeworkAssignment assignment) async {
    final message = '''
📚 *New Homework Assigned*
Subject: ${assignment.subject}
Class: ${assignment.className}
Title: ${assignment.title}
Due Date: ${assignment.dueDate}

Description:
${assignment.description}

Check the app for details and attachments!
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Homework History',
            subtitle: 'Published Assignments',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: ref.watch(homeworkStreamProvider).when(
              data: (assignments) {
                if (assignments.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'No homework yet',
                    description: 'Start assigning tasks to your students.',
                    actionLabel: 'Assign Homework',
                    onActionPressed: () => context.pushNamed(HomeworkAssignmentWidget.routeName),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: assignments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    
                    return wrapWithModel(
                      model: createModel(context, () => HomeworkCardModel()),
                      updateCallback: () => safeSetState(() {}),
                      child: HomeworkCardWidget(
                        assignment: assignment,
                        onTap: () async => _showAttachments(context, assignment),
                        onShare: () => _shareHomework(assignment),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachments(BuildContext context, HomeworkAssignment assignment) {
    if (assignment.attachments.isEmpty) return;
    final theme = FlutterFlowTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.attachment_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Attachments',
                  style: AppTypography.title.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...assignment.attachments.map((url) {
              final fileName = url.split('%2F').last.split('?').first;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.alternate),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
                    title: Text(
                      fileName, 
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () => launchURL(url),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            AppPrimaryButton(
              text: 'Close',
              variant: 'outline',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
