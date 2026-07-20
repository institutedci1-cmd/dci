import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/core/services/report_card_service.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'merit_list_model.dart';

class MeritListWidget extends ConsumerStatefulWidget {
  const MeritListWidget({super.key, required this.exam});

  final Exam exam;

  static String routeName = 'MeritList';
  static String routePath = '/meritList';

  @override
  ConsumerState<MeritListWidget> createState() => _MeritListWidgetState();
}

class _MeritListWidgetState extends ConsumerState<MeritListWidget> {
  late MeritListModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MeritListModel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final resultsAsync = ref.watch(examResultsStreamProvider(widget.exam.id));

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Merit List',
            subtitle: '${widget.exam.subject} - ${widget.exam.className}',
            onBackPressed: () async => context.safePop(),
            showActionIcon: true,
            actionIcon: const Icon(Icons.print_rounded, color: Colors.white),
            onActionPressed: () async {
              final results = await ref.read(resultRepositoryProvider).getExamResultsStream(widget.exam.id).first;
              if (results.isEmpty) return;
              
              final config = ref.read(instituteInfoStreamProvider).value;
              final instituteName = config?['name'] ?? 'DCI Teachers';

              await ReportCardService.generateAndPrintMeritList(
                examTitle: widget.exam.subject,
                className: widget.exam.className,
                results: results,
                instituteName: instituteName,
              );
            },
          ),
          Expanded(
            child: resultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('No results published yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final rank = index + 1;
                    final isTop3 = rank <= 3;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: theme.alternate),
                        boxShadow: AppShadows.low,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isTop3 ? AppColors.secondary : AppColors.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              rank.toString(),
                              style: TextStyle(
                                color: isTop3 ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(result.studentName, 
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Grade: ${result.grade} ${result.remarks.isNotEmpty ? "• ${result.remarks}" : ""}', 
                              style: AppTypography.caption.copyWith(fontSize: 12),
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${result.marksObtained.toInt()}/${result.totalMarks}',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.primary, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${((result.marksObtained / result.totalMarks) * 100).toStringAsFixed(1)}%',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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
