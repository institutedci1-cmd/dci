import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/core/services/report_card_service.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_results_model.dart';

class MyResultsWidget extends ConsumerStatefulWidget {
  const MyResultsWidget({super.key});

  static String routeName = 'MyResults';
  static String routePath = '/myResults';

  @override
  ConsumerState<MyResultsWidget> createState() => _MyResultsWidgetState();
}

class _MyResultsWidgetState extends ConsumerState<MyResultsWidget> {
  late MyResultsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyResultsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final studentAsync = ref.watch(currentStudentStreamProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'My Results',
            subtitle: 'Academic Performance',
            onBackPressed: () async => context.safePop(),
            showActionIcon: true,
            actionIcon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            onActionPressed: () async {
              final student = studentAsync.value;
              if (student == null) return;
              
              final results = await ref.read(resultRepositoryProvider).getStudentResultsStream(student.id).first;
              if (results.isEmpty) return;

              final config = ref.read(instituteInfoStreamProvider).value;
              final instituteName = config?['name'] ?? 'DCI Teachers';

              await ReportCardService.generateAndPrintReportCard(
                student: student,
                results: results,
                instituteName: instituteName,
              );
            },
          ),
          Expanded(
            child: studentAsync.when(
              data: (student) {
                if (student == null) return const Center(child: Text('Profile not found.'));
                
                final resultsAsync = ref.watch(studentResultsStreamProvider(student.id));
                
                return resultsAsync.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.grade_rounded,
                        title: 'No results published',
                        description: 'Your exam results will appear here once released.',
                      );
                    }
                    return ListView.separated(
                      padding: AppSpacing.pagePadding,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final result = results[index];
                        final percentage = (result.marksObtained / result.totalMarks * 100);
                        final color = percentage >= 75 ? AppColors.success : (percentage >= 50 ? AppColors.warning : AppColors.error);

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.alternate),
                            boxShadow: AppShadows.low,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                              child: Icon(Icons.star_rounded, color: color, size: 20),
                            ),
                            title: Text(result.subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('Grade: ${result.grade} • ${result.remarks}', style: AppTypography.caption),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${result.marksObtained.toInt()}/${result.totalMarks}', 
                                    style: AppTypography.label.copyWith(color: color, fontWeight: FontWeight.bold)),
                                Text('${percentage.toStringAsFixed(1)}%', style: AppTypography.caption.copyWith(fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
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
}
