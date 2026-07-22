import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/exams/add_exam_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/exams_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/enter_marks_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/merit_list_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/teacher_wise_report_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/date_wise_report_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/monthly_report_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/class_wise_report_widget.dart';
import 'package:d_c_i_teacher_app/pages/reports_dashboard/reports_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/attendance_dashboard/attendance_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/teacher_profile/teacher_profile_widget.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/core/services/navigation_service.dart';
import 'package:d_c_i_teacher_app/core/services/report_card_service.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'exams_dashboard_model.dart';

class ExamsDashboardWidget extends ConsumerStatefulWidget {
  const ExamsDashboardWidget({super.key});

  static String routeName = 'ExamsDashboard';
  static String routePath = '/examsDashboard';

  @override
  ConsumerState<ExamsDashboardWidget> createState() => _ExamsDashboardWidgetState();
}

class _ExamsDashboardWidgetState extends ConsumerState<ExamsDashboardWidget> {
  late ExamsDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExamsDashboardModel());
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
            title: 'Exams Dashboard',
            subtitle: 'Academic Evaluation Center',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // Extreme compression: disable outer scroll if possible
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Micro Statistics Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('STATISTICS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                      const Icon(Icons.analytics_outlined, size: 14, color: AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  examsAsync.when(
                    data: (exams) {
                      final totalExams = exams.length;
                      final upcomingExams = exams.where((e) => e.date.isAfter(DateTime.now())).length;
                      
                      return Row(
                        children: [
                          _buildMicroStat(context, 'Total', totalExams.toString(), Icons.assignment_outlined, theme.primary),
                          const SizedBox(width: 8),
                          _buildMicroStat(context, 'Upcoming', upcomingExams.toString(), Icons.event_available_outlined, AppColors.info),
                          const SizedBox(width: 8),
                          _buildMicroStat(context, 'Analysis', 'View', Icons.analytics_rounded, AppColors.secondary, onTap: () => NavigationService.navigateToResults(context)),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Error: $err', style: const TextStyle(fontSize: 10)),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Ultra-Slim Performance Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Row(
                      children: [
                        Text('Class Performance', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        Text('85%', style: AppTypography.caption.copyWith(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.85,
                              minHeight: 4,
                              backgroundColor: theme.alternate,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Consolidated Action Grid (3 columns)
                  Text('QUICK ACTIONS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      _buildActionBtn(context, 'Create', Icons.add_task_rounded, theme.primary, () => context.pushNamed(AddExamWidget.routeName)),
                      _buildActionBtn(context, 'Marks', Icons.edit_note_rounded, AppColors.info, () => context.pushNamed(ExamsWidget.routeName)),
                      _buildActionBtn(context, 'Publish', Icons.publish_rounded, AppColors.success, () => context.pushNamed(ExamsWidget.routeName)),
                      _buildActionBtn(context, 'Monthly', Icons.insights_rounded, theme.primary, () => context.pushNamed(MonthlyReportWidget.routeName)),
                      _buildActionBtn(context, 'Class', Icons.grade_rounded, AppColors.info, () => context.pushNamed(ClassWiseReportWidget.routeName)),
                      _buildActionBtn(context, 'Report', Icons.print_rounded, theme.secondary, () => _showStudentSelectionDialog(context, ref)),
                      _buildActionBtn(context, 'Faculty', Icons.person_search_rounded, AppColors.warning, () => context.pushNamed(TeacherWiseReportWidget.routeName)),
                      _buildActionBtn(context, 'Date', Icons.calendar_month_rounded, AppColors.secondary, () => context.pushNamed(DateWiseReportWidget.routeName)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Mini Recent Activity (Top 2 only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RECENT ACTIVITY', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                      TextButton(
                        onPressed: () => context.pushNamed(ExamsWidget.routeName),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 20), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text('View All', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  examsAsync.when(
                    data: (exams) {
                      if (exams.isEmpty) return const SizedBox();
                      final recentExams = exams.take(2).toList();
                      return Column(
                        children: recentExams.map((exam) => _buildMiniActivityCard(context, exam, theme)).toList(),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNavBar(
            currentIndex: 1, 
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

  Widget _buildMicroStat(BuildContext context, String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                const SizedBox(height: 8),
                Text(value, style: AppTypography.title.copyWith(fontSize: 18, height: 1.1)),
                Text(label, style: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniActivityCard(BuildContext context, Exam exam, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_rounded, color: theme.primary, size: 16),
          ),
          title: Text('${exam.subject} - ${exam.className}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          subtitle: Text(dateTimeFormat('yMMMd', exam.date), style: AppTypography.caption.copyWith(fontSize: 11)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 16),
          onTap: () => context.pushNamed(ExamsWidget.routeName),
        ),
      ),
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
            title: Text('Select Student', style: AppTypography.section),
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
