import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'class_wise_report_model.dart';

class ClassWiseReportWidget extends ConsumerStatefulWidget {
  const ClassWiseReportWidget({super.key});

  static String routeName = 'ClassWiseReport';
  static String routePath = '/classWiseReport';

  @override
  ConsumerState<ClassWiseReportWidget> createState() => _ClassWiseReportWidgetState();
}

class _ClassWiseReportWidgetState extends ConsumerState<ClassWiseReportWidget> {
  late ClassWiseReportModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClassWiseReportModel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Class Analysis',
            subtitle: 'Performance by Grade',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: studentsAsync.when(
              data: (students) {
                final classOptions = students
                    .map((s) => s.className)
                    .where((c) => c.isNotEmpty)
                    .toSet()
                    .toList()..sort();
                
                return DropDownWidget(
                  label: 'Select Class',
                  options: classOptions,
                  onChanged: (val) => setState(() => _model.selectedClass = val),
                  hint: 'e.g. 10th Grade',
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading classes: $err', style: const TextStyle(fontSize: 10)),
            ),
          ),
          Expanded(
            child: _model.selectedClass == null
                ? Center(child: Text('Select a class to view report.', style: theme.labelSmall))
                : _buildClassReport(context, _model.selectedClass!),
          ),
        ],
      ),
    );
  }

  Widget _buildClassReport(BuildContext context, String className) {
    final theme = FlutterFlowTheme.of(context);
    final examsAsync = ref.watch(examsStreamProvider);

    return examsAsync.when(
      data: (exams) {
        final classExams = exams.where((e) => e.className == className).toList();
        if (classExams.isEmpty) {
          return Center(child: Text('No exams found for this class.', style: theme.labelSmall));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: classExams.length,
          itemBuilder: (context, index) {
            final exam = classExams[index];
            return _buildExamPerformanceTile(context, exam);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildExamPerformanceTile(BuildContext context, dynamic exam) {
    final theme = FlutterFlowTheme.of(context);
    final resultsAsync = ref.watch(examResultsStreamProvider(exam.id));

    return resultsAsync.when(
      data: (results) {
        double avg = 0;
        if (results.isNotEmpty) {
          double totalObtained = 0;
          for (var r in results) {
            totalObtained += r.marksObtained;
          }
          avg = (totalObtained / (results.length * exam.totalMarks)) * 100;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
            boxShadow: AppShadows.low,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(exam.subject, style: AppTypography.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '${avg.toInt()}%',
                    style: TextStyle(
                      color: avg >= 75 ? AppColors.success : (avg >= 50 ? AppColors.warning : AppColors.error),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStat(Icons.people_rounded, '${results.length} Students'),
                  const SizedBox(width: 16),
                  _buildMiniStat(Icons.event_rounded, dateTimeFormat('yMMMd', exam.date)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: avg / 100,
                  minHeight: 6,
                  backgroundColor: theme.alternate,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    avg >= 75 ? AppColors.success : (avg >= 50 ? AppColors.warning : AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: LinearProgressIndicator())),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildMiniStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
