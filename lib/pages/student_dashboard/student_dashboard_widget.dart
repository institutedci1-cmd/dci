import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_icon_button.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/shared/responsive_scaffold.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_dashboard_model.dart';

class StudentDashboardWidget extends ConsumerStatefulWidget {
  const StudentDashboardWidget({super.key});

  static String routeName = 'StudentDashboard';
  static String routePath = '/studentDashboard';

  @override
  ConsumerState<StudentDashboardWidget> createState() => _StudentDashboardWidgetState();
}

class _StudentDashboardWidgetState extends ConsumerState<StudentDashboardWidget> {
  late StudentDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(currentStudentStreamProvider);

    return studentAsync.when(
      data: (student) {
        if (student == null) {
          return const Scaffold(body: Center(child: Text('Student profile not found.')));
        }
        return _buildDashboard(context, student);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildDashboard(BuildContext context, Student student) {
    return ResponsiveScaffold(
      currentIndex: 0,
      body: Column(
        children: [
          _buildTopHeader(context, student),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(context, student),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Quick Actions', style: AppTypography.section.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Learning Center', style: AppTypography.section.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  _buildLearningCenter(context, student),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, Student student) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primaryDark],
          begin: const AlignmentDirectional(0.0, -1.0),
          end: const AlignmentDirectional(0, 1.0),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32.0),
          bottomRight: Radius.circular(32.0),
        ),
        boxShadow: AppShadows.low,
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 44.0, 24.0, 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(100), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: student.photoUrl != null && student.photoUrl!.isNotEmpty
                      ? Image.network(student.photoUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${student.name.split(' ').first}',
                        style: theme.titleMedium.override(
                            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            color: Colors.white,
                            fontSize: 22)),
                    Text('${student.className} • Roll No: ${student.rollNo}',
                        style: theme.labelSmall.override(
                            font: GoogleFonts.inter(),
                            color: Colors.white.withAlpha(200),
                            fontSize: 13)),
                  ],
                ),
              ),
              FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 40.0,
                fillColor: theme.onPrimary15,
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24.0),
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.goNamed(LoginWidget.routeName);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, Student student) {
    final attendanceAsync = ref.watch(studentAttendanceHistoryProvider(student.id));
    final examsAsync = ref.watch(studentExamsStreamProvider(student.className));
    final homeworkAsync = ref.watch(studentHomeworkStreamProvider(student.className));
    final resultsAsync = ref.watch(studentResultsStreamProvider(student.id));

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          context,
          'Attendance',
          attendanceAsync.when(
            data: (logs) {
              if (logs.isEmpty) return '0%';
              final present = logs.where((l) => l.status == 'Present').length;
              return '${(present / logs.length * 100).toInt()}%';
            },
            loading: () => '...',
            error: (_, __) => 'Error',
          ),
          Icons.calendar_today_rounded,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          'Upcoming Exams',
          examsAsync.when(
            data: (exams) => exams.where((e) => e.date.isAfter(DateTime.now())).length.toString(),
            loading: () => '...',
            error: (_, __) => '0',
          ),
          Icons.assignment_rounded,
          AppColors.info,
        ),
        _buildMetricCard(
          context,
          'Homework Due',
          homeworkAsync.when(
            data: (hw) => hw.length.toString(),
            loading: () => '...',
            error: (_, __) => '0',
          ),
          Icons.edit_note_rounded,
          AppColors.secondary,
        ),
        _buildMetricCard(
          context,
          'Latest Result',
          resultsAsync.when(
            data: (res) => res.isNotEmpty ? '${res.first.marksObtained.toInt()}/${res.first.totalMarks}' : 'N/A',
            loading: () => '...',
            error: (_, __) => 'N/A',
          ),
          Icons.grade_rounded,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.title.copyWith(fontSize: 20)),
          Text(title, style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(context, 'Homework', Icons.book_rounded, AppColors.primary, () => context.pushNamed(MyHomeworkWidget.routeName)),
        _buildActionButton(context, 'Results', Icons.assessment_rounded, AppColors.success, () => context.pushNamed(MyResultsWidget.routeName)),
        _buildActionButton(context, 'Attendance', Icons.fact_check_rounded, AppColors.info, () => context.pushNamed(MyAttendanceHistoryWidget.routeName)),
        _buildActionButton(context, 'Notices', Icons.campaign_rounded, AppColors.secondary, () => context.pushNamed(AnnouncementsFeedWidget.routeName)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildLearningCenter(BuildContext context, Student student) {
    final examsAsync = ref.watch(studentExamsStreamProvider(student.className));
    final resultsAsync = ref.watch(studentResultsStreamProvider(student.id));

    return Column(
      children: [
        _buildSectionTitle('Upcoming Tests'),
        examsAsync.when(
          data: (exams) {
            final upcoming = exams.where((e) => e.date.isAfter(DateTime.now())).toList();
            if (upcoming.isEmpty) return _buildEmptyState('No upcoming tests scheduled.');
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcoming.length.clamp(0, 3),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _buildExamTile(context, upcoming[index]),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Recent Performance'),
        resultsAsync.when(
          data: (results) {
            if (results.isEmpty) return _buildEmptyState('No results available yet.');
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length.clamp(0, 3),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _buildResultTile(context, results[index]),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(message, style: AppTypography.caption),
    );
  }

  Widget _buildExamTile(BuildContext context, Exam exam) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.info.withAlpha(20), shape: BoxShape.circle),
            child: const Icon(Icons.event_note_rounded, color: AppColors.info, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(dateTimeFormat('yMMMd', exam.date), style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Text(exam.startTime, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: theme.primary)),
        ],
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, dynamic result) {
    final theme = FlutterFlowTheme.of(context);
    final percentage = (result.marksObtained / result.totalMarks * 100);
    final color = percentage >= 75 ? AppColors.success : (percentage >= 50 ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
            child: Icon(Icons.grade_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Grade: ${result.grade}', style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Text('${result.marksObtained.toInt()}/${result.totalMarks}',
              style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
