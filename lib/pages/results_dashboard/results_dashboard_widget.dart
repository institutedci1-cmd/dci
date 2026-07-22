import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';
import 'package:d_c_i_teacher_app/core/services/report_card_service.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/exams/merit_list_widget.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/attendance_dashboard/attendance_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/teacher_profile/teacher_profile_widget.dart';
import 'package:d_c_i_teacher_app/pages/reports_dashboard/reports_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/comparative_results/comparative_results_widget.dart';
import 'results_dashboard_model.dart';

class ResultsDashboardWidget extends ConsumerStatefulWidget {
  const ResultsDashboardWidget({super.key});

  static String routeName = 'ResultsDashboard';
  static String routePath = '/resultsDashboard';

  @override
  ConsumerState<ResultsDashboardWidget> createState() => _ResultsDashboardWidgetState();
}

class _ResultsDashboardWidgetState extends ConsumerState<ResultsDashboardWidget> {
  late ResultsDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultsDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final examsAsync = ref.watch(examsStreamProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Results & Analytics',
            subtitle: 'Academic Performance Hub',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPerformanceSummary(context, ref),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Quick Actions', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.md),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Recent Exam Results', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.md),
                  _buildRecentResultsList(context, examsAsync),
                ],
              ),
            ),
          ),
          AppBottomNavBar(
            currentIndex: 1, // Results usually mapped to index 1 or similar
            onTap: (index) {
              final routes = [
                HomeDashboardWidget.routeName,
                ReportsDashboardWidget.routeName,
                AttendanceDashboardWidget.routeName,
                TeacherProfileWidget.routeName,
              ];
              context.goNamed(routes[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    // This would ideally come from a specialized analytics provider
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Pass %', '94.2%', Icons.check_circle_outline),
              _buildStatDivider(),
              _buildStatItem('Avg Score', '78.5', Icons.analytics_outlined),
              _buildStatDivider(),
              _buildStatItem('Rank 1s', '12', Icons.emoji_events_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withAlpha(200), size: 20),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.title.copyWith(color: Colors.white, fontSize: 22)),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white.withAlpha(180), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: Colors.white.withAlpha(50));
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            'Individual\nReport Card',
            Icons.person_pin_rounded,
            AppColors.primary,
            () => _showStudentSelectionDialog(context, ref),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionCard(
            context,
            'Comparative\nAnalysis',
            Icons.stacked_bar_chart_rounded,
            AppColors.secondary,
            () => context.pushNamed(ComparativeResultsWidget.routeName),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.alternate),
          boxShadow: AppShadows.low,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(fontSize: 13, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentResultsList(BuildContext context, AsyncValue<List<Exam>> examsAsync) {
    final theme = FlutterFlowTheme.of(context);
    
    return examsAsync.when(
      data: (exams) {
        // Filter exams that already happened (for which results might exist)
        final pastExams = exams.where((e) => e.date.isBefore(DateTime.now())).toList();
        
        if (pastExams.isEmpty) {
          return const AppEmptyState(
            icon: Icons.grade_rounded,
            title: 'No past exams',
            description: 'Completed exams will appear here for result analysis.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pastExams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final exam = pastExams[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.alternate),
                boxShadow: AppShadows.low,
              ),
              child: Material(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: AppColors.success, size: 20),
                  ),
                  title: Text('${exam.subject} - ${exam.className}', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Exam Date: ${dateTimeFormat('yMMMd', exam.date)}', style: AppTypography.caption),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.pushNamed(
                    MeritListWidget.routeName,
                    extra: {'exam': exam},
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error loading exams: $err'),
    );
  }

  Future<void> _showStudentSelectionDialog(BuildContext context, WidgetRef ref) async {
    final students = await ref.read(studentRepositoryProvider).getAllStudentsStream().first;
    final config = ref.read(instituteInfoStreamProvider).value;
    final instituteName = config?['name'] ?? 'DCI Teachers';

    if (!context.mounted) return;

    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final query = searchController.text.toLowerCase();
          final filteredStudents = students.where((s) {
            return s.name.toLowerCase().contains(query) || 
                   s.rollNo.toLowerCase().contains(query) ||
                   s.className.toLowerCase().contains(query);
          }).toList();

          return AlertDialog(
            title: Text('Generate Report Card', style: AppTypography.section),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSearchBar(
                    controller: searchController,
                    hintText: 'Search by name or roll...',
                    onChanged: (_) => setDialogState(() {}),
                    onClear: () {
                      searchController.clear();
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  if (filteredStudents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('No students found.', style: AppTypography.caption),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredStudents.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${student.className} • Roll: ${student.rollNo}'),
                            trailing: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 20),
                            onTap: () async {
                              Navigator.pop(context);
                              final results = await ref.read(resultRepositoryProvider).getStudentResultsStream(student.id).first;
                              if (results.isEmpty) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No results found for this student.')));
                                }
                                return;
                              }
                              await ReportCardService.generateAndPrintReportCard(
                                student: student,
                                results: results,
                                instituteName: instituteName,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ],
          );
        },
      ),
    );
  }
}
