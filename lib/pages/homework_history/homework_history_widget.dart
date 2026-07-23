import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/homework_card/homework_card_widget.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                        onTap: () async {
                          context.pushNamed(
                            'HomeworkDetails',
                            extra: {'assignment': assignment},
                          );
                        },
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
}
