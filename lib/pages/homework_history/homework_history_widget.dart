import '/components/homework_card/homework_card_widget.dart';
import '/backend/models/homework_assignment.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homework_history_model.dart';
export 'homework_history_model.dart';

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
          wrapWithModel(
            model: _model.headerSectionModel,
            updateCallback: () => safeSetState(() {}),
            child: HeaderSectionWidget(
              title: 'Homework History',
              subtitle: 'Assignments you have published',
              description: 'View and track all homework given to classes.',
              onBackPressed: () async => context.safePop(),
              showActionIcon: false,
            ),
          ),
          Expanded(
            child: ref.watch(homeworkStreamProvider).when(
              data: (assignments) {
                if (assignments.isEmpty) {
                  return Center(
                    child: Text(
                      'No assignments found.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: assignments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...assignment.attachments.map((url) {
              final fileName = url.split('%2F').last.split('?').first;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(fileName, style: FlutterFlowTheme.of(context).bodyMedium),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                  onTap: () => launchURL(url),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
