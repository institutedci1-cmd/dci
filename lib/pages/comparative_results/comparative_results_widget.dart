import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparativeResultsWidget extends ConsumerStatefulWidget {
  const ComparativeResultsWidget({super.key});

  static String routeName = 'ComparativeResults';
  static String routePath = '/comparativeResults';

  @override
  ConsumerState<ComparativeResultsWidget> createState() => _ComparativeResultsWidgetState();
}

class _ComparativeResultsWidgetState extends ConsumerState<ComparativeResultsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final resultsAsync = ref.watch(allResultsStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Result Analytics',
            subtitle: 'Academic Benchmarking',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: resultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('No results available for comparison.'));
                }
                return SingleChildScrollView(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Subject Benchmarking'),
                      const SizedBox(height: 12),
                      _buildSubjectBenchmarking(context, results),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Class Standings'),
                      const SizedBox(height: 12),
                      _buildClassStandings(context, results),
                      const SizedBox(height: 40),
                    ],
                  ),
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.section.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildSubjectBenchmarking(BuildContext context, List<dynamic> results) {
    final theme = FlutterFlowTheme.of(context);
    final Map<String, List<double>> subjectScores = {};
    for (var r in results) {
      final percentage = (r.marksObtained / r.totalMarks) * 100;
      subjectScores[r.subject] = (subjectScores[r.subject] ?? [])..add(percentage);
    }

    final subjects = subjectScores.keys.toList()..sort();

    return Column(
      children: subjects.map((subject) {
        final scores = subjectScores[subject]!;
        final avg = scores.reduce((a, b) => a + b) / scores.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: theme.primary.withAlpha(20), shape: BoxShape.circle),
                child: Icon(Icons.book_rounded, color: theme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: avg / 100,
                        minHeight: 6,
                        backgroundColor: theme.alternate,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text('${avg.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primary, fontSize: 16)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassStandings(BuildContext context, List<dynamic> results) {
    final theme = FlutterFlowTheme.of(context);
    final Map<String, List<double>> classScores = {};
    for (var r in results) {
      final percentage = (r.marksObtained / r.totalMarks) * 100;
      classScores[r.className] = (classScores[r.className] ?? [])..add(percentage);
    }

    final classes = classScores.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: classes.map((className) {
          final scores = classScores[className]!;
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          final color = avg >= 75 ? AppColors.success : (avg >= 50 ? AppColors.warning : AppColors.error);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(className, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold))),
                Expanded(
                  flex: 7,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(height: 12, decoration: BoxDecoration(color: theme.alternate, borderRadius: BorderRadius.circular(6))),
                      FractionallySizedBox(
                        widthFactor: (avg / 100).clamp(0.0, 1.0),
                        child: Container(height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(width: 40, child: Text('${avg.toInt()}%', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: color))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
