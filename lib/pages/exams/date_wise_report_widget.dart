import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'date_wise_report_model.dart';

class DateWiseReportWidget extends ConsumerStatefulWidget {
  const DateWiseReportWidget({super.key});

  static String routeName = 'DateWiseReport';
  static String routePath = '/dateWiseReport';

  @override
  ConsumerState<DateWiseReportWidget> createState() => _DateWiseReportWidgetState();
}

class _DateWiseReportWidgetState extends ConsumerState<DateWiseReportWidget> {
  late DateWiseReportModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DateWiseReportModel());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _model.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _model.selectedDate) {
      setState(() {
        _model.selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final examsAsync = ref.watch(dateExamsStreamProvider(_model.selectedDate));

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Schedule Report',
            subtitle: dateTimeFormat('yMMMd', _model.selectedDate),
            onBackPressed: () async => context.safePop(),
            actionIcon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            onActionPressed: () async => _selectDate(context),
          ),
          Expanded(
            child: examsAsync.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 48, color: theme.secondaryText),
                        const SizedBox(height: 12),
                        Text('No exams scheduled.', style: theme.labelSmall),
                        TextButton(onPressed: () => _selectDate(context), child: const Text('Change Date', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _buildExamCard(context, exam);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
    final resultsAsync = ref.watch(examResultsStreamProvider(exam.id));
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.alternate),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${exam.subject} - ${exam.className}', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: theme.primary.withAlpha(25), borderRadius: BorderRadius.circular(4)),
                  child: Text(exam.startTime, style: AppTypography.caption.copyWith(color: theme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Venue: ${exam.venue}', style: AppTypography.caption.copyWith(fontSize: 10)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider(height: 1)),
            resultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Text('Results not yet published.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10));
                }
                double totalObtained = 0;
                for (var r in results) totalObtained += r.marksObtained;
                final avg = (totalObtained / (results.length * exam.totalMarks) * 100).toInt();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Students: ${results.length}', style: AppTypography.caption.copyWith(fontSize: 10)),
                    Text('Avg. Score: $avg%', style: AppTypography.caption.copyWith(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                );
              },
              loading: () => const SizedBox(height: 2, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
