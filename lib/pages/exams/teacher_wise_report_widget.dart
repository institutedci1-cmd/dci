import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teacher_wise_report_model.dart';

class TeacherWiseReportWidget extends ConsumerStatefulWidget {
  const TeacherWiseReportWidget({super.key});

  static String routeName = 'TeacherWiseReport';
  static String routePath = '/teacherWiseReport';

  @override
  ConsumerState<TeacherWiseReportWidget> createState() => _TeacherWiseReportWidgetState();
}

class _TeacherWiseReportWidgetState extends ConsumerState<TeacherWiseReportWidget> {
  late TeacherWiseReportModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeacherWiseReportModel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final usersAsync = ref.watch(allUsersStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Faculty Report',
            subtitle: 'Academic Performance',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: usersAsync.when(
              data: (users) {
                return DropDownWidget(
                  label: 'Faculty Member',
                  options: users.map((u) => u.uid).toList(),
                  optionLabels: users.map((u) => u.displayName).toList(),
                  onChanged: (val) => setState(() => _model.selectedTeacherUid = val),
                  hint: 'Select Teacher',
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading teachers: $err', style: const TextStyle(fontSize: 10)),
            ),
          ),
          Expanded(
            child: _model.selectedTeacherUid == null
                ? Center(child: Text('Select a teacher to view details.', style: theme.labelSmall))
                : _buildReport(context, _model.selectedTeacherUid!),
          ),
        ],
      ),
    );
  }

  Widget _buildReport(BuildContext context, String uid) {
    final theme = FlutterFlowTheme.of(context);
    final examsAsync = ref.watch(teacherExamsStreamProvider(uid));
    final resultsAsync = ref.watch(teacherResultsStreamProvider(uid));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          examsAsync.when(
            data: (exams) {
              return resultsAsync.when(
                data: (results) {
                  if (exams.isEmpty) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text('No exams conducted.', style: theme.labelSmall),
                    ));
                  }
                  
                  double totalObtained = 0;
                  int totalMax = 0;
                  for (var r in results) {
                    totalObtained += r.marksObtained;
                    totalMax += r.totalMarks;
                  }
                  final avgPerformance = totalMax == 0 ? 0 : ((totalObtained / totalMax) * 100).toInt();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildMiniStatCard(context, 'Exams', exams.length.toString(), Icons.assignment_rounded, theme.primary),
                          const SizedBox(width: 12),
                          _buildMiniStatCard(context, 'Avg.', '$avgPerformance%', Icons.trending_up_rounded, AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('EXAMS LIST', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exams.length,
                        itemBuilder: (context, index) {
                          final exam = exams[index];
                          final examResults = results.where((r) => r.examId == exam.id).toList();
                          double examObtained = 0;
                          for (var r in examResults) {
                            examObtained += r.marksObtained;
                          }
                          final examAvg = examResults.isEmpty ? 0 : (examObtained / (examResults.length * exam.totalMarks) * 100).toInt();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.alternate),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: ListTile(
                                dense: true,
                                title: Text('${exam.subject} - ${exam.className}', style: AppTypography.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text(dateTimeFormat('yMMMd', exam.date), style: AppTypography.caption.copyWith(fontSize: 10)),
                                trailing: Text('$examAvg%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primary, fontSize: 12)),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTypography.label.copyWith(fontSize: 16, color: theme.primaryText, fontWeight: FontWeight.bold)),
                Text(label, style: AppTypography.caption.copyWith(fontSize: 10, color: theme.secondaryText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
