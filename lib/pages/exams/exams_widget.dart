import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/exam_card/exam_card_widget.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/exams/add_exam_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/exams/exams_model.dart';

class ExamsWidget extends ConsumerStatefulWidget {
  const ExamsWidget({super.key});

  static String routeName = 'Exams';
  static String routePath = '/exams';

  @override
  ConsumerState<ExamsWidget> createState() => _ExamsWidgetState();
}

class _ExamsWidgetState extends ConsumerState<ExamsWidget> {
  late ExamsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExamsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _deleteExam(Exam exam) async {
    final theme = FlutterFlowTheme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Exam', style: AppTypography.section),
        content: Text('Are you sure you want to delete the ${exam.subject} exam for ${exam.className}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: theme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await ref.read(examServiceProvider).deleteExam(exam.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam deleted successfully.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final user = ref.read(currentUserDataStreamProvider).value;
    final isAdmin = user?.role == 'Admin';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => context.pushNamed(AddExamWidget.routeName),
        backgroundColor: theme.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ) : null,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Exams List',
            subtitle: 'Academic Schedule',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: ref.watch(examsStreamProvider).when(
              data: (exams) {
                if (exams.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.assignment_rounded,
                    title: 'No exams scheduled',
                    description: 'Keep track of all tests and exams here.',
                    actionLabel: isAdmin ? 'Schedule First Exam' : null,
                    onActionPressed: isAdmin ? () => context.pushNamed(AddExamWidget.routeName) : null,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return ExamCardWidget(
                      exam: exam,
                      onDelete: isAdmin ? () => _deleteExam(exam) : null,
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
