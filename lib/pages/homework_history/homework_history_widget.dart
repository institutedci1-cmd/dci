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
            child: StreamBuilder<List<HomeworkAssignment>>(
              stream: ref.watch(homeworkRepositoryProvider).getUserHomework(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final assignments = snapshot.data!;
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
                    final status = assignment.status;

                    return Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          '${assignment.className} - ${assignment.subject}',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(assignment.title),
                            if (assignment.teacher.isNotEmpty)
                              Text('Assigned by: ${assignment.teacher}',
                                  style: FlutterFlowTheme.of(context).bodySmall),
                            Text(
                              'Due: ${assignment.dueDate}',
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            if (assignment.attachments.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.attachment_rounded,
                                        size: 14,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${assignment.attachments.length} attachment(s)',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(),
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'published'
                                  ? FlutterFlowTheme.of(context).success
                                  : FlutterFlowTheme.of(context).warning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () {
                          if (assignment.attachments.isEmpty) return;
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attachments',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...assignment.attachments.map((url) {
                                    final fileName =
                                        url.split('%2F').last.split('?').first;
                                    return ListTile(
                                      leading: const Icon(
                                          Icons.insert_drive_file_outlined),
                                      title: Text(fileName,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium),
                                      trailing: const Icon(
                                          Icons.open_in_new_rounded,
                                          size: 20),
                                      onTap: () => launchURL(url),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
