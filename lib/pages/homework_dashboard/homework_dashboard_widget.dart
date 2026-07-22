import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/attendance_dashboard/attendance_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/teacher_profile/teacher_profile_widget.dart';
import 'package:d_c_i_teacher_app/pages/reports_dashboard/reports_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/homework_assignment/homework_assignment_widget.dart';
import 'package:d_c_i_teacher_app/pages/homework_history/homework_history_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homework_dashboard_model.dart';

class HomeworkDashboardWidget extends ConsumerStatefulWidget {
  const HomeworkDashboardWidget({super.key});

  static String routeName = 'HomeworkDashboard';
  static String routePath = '/homeworkDashboard';

  @override
  ConsumerState<HomeworkDashboardWidget> createState() => _HomeworkDashboardWidgetState();
}

class _HomeworkDashboardWidgetState extends ConsumerState<HomeworkDashboardWidget> {
  late HomeworkDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final homeworkAsync = ref.watch(homeworkStreamProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Homework Hub',
            subtitle: 'Assignment & Tracker',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSummary(context, homeworkAsync),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Quick Actions', style: AppTypography.section),
                  const SizedBox(height: AppSpacing.md),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Assignments', style: AppTypography.section),
                      TextButton(
                        onPressed: () => context.pushNamed(HomeworkHistoryWidget.routeName),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildRecentAssignments(context, homeworkAsync),
                ],
              ),
            ),
          ),
          AppBottomNavBar(
            currentIndex: -1, 
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

  Widget _buildStatsSummary(BuildContext context, AsyncValue<List<HomeworkAssignment>> homeworkAsync) {
    return homeworkAsync.when(
      data: (list) {
        final active = list.where((h) => h.status == 'published').length;
        final drafts = list.where((h) => h.status == 'draft').length;
        // Simplified "Due Today" logic for placeholder
        final dueToday = list.where((h) => h.dueDate.contains(dateTimeFormat('yMMMd', DateTime.now()))).length;

        return Row(
          children: [
            _buildStatCard('Active', active.toString(), Icons.assignment_turned_in_rounded, AppColors.success),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard('Drafts', drafts.toString(), Icons.edit_document, AppColors.warning),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard('Due Today', dueToday.toString(), Icons.today_rounded, AppColors.error),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.title.copyWith(fontSize: 20)),
            Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionBtn(
            context,
            'Assign New',
            Icons.add_task_rounded,
            AppColors.primary,
            () => context.pushNamed(HomeworkAssignmentWidget.routeName),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionBtn(
            context,
            'View History',
            Icons.history_rounded,
            AppColors.secondary,
            () => context.pushNamed(HomeworkHistoryWidget.routeName),
          ),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssignments(BuildContext context, AsyncValue<List<HomeworkAssignment>> homeworkAsync) {
    final theme = FlutterFlowTheme.of(context);
    return homeworkAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const AppEmptyState(
            icon: Icons.edit_note_rounded,
            title: 'No assignments',
            description: 'Create your first homework assignment to get started.',
          );
        }
        final recent = list.take(5).toList();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final h = recent[index];
            final isDraft = h.status == 'draft';
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.alternate),
              ),
              child: Material(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: (isDraft ? AppColors.warning : AppColors.primary).withAlpha(15), shape: BoxShape.circle),
                    child: Icon(isDraft ? Icons.edit_document : Icons.assignment_rounded, color: isDraft ? AppColors.warning : AppColors.primary, size: 20),
                  ),
                  title: Text(h.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text('${h.subject} • ${h.className}', style: AppTypography.caption),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDraft ? AppColors.warning : AppColors.success).withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDraft ? 'Draft' : 'Published',
                      style: TextStyle(color: isDraft ? AppColors.warning : AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () => context.pushNamed(HomeworkHistoryWidget.routeName),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
