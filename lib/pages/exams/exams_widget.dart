import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/exam_card/exam_card_widget.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
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
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await ref.read(examRepositoryProvider).deleteExam(exam.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam deleted successfully.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AddExamWidget.routeName),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
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
                    actionLabel: 'Schedule First Exam',
                    onActionPressed: () => context.pushNamed(AddExamWidget.routeName),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return ExamCardWidget(
                      exam: exam,
                      onDelete: () => _deleteExam(exam),
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
