import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/backend/models/student.dart';
import '/backend/providers/monthly_report_provider.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared/app_colors.dart';
import '/shared/app_style.dart';
import '/components/shared/app_card.dart';
import 'monthly_report_model.dart';

export 'monthly_report_model.dart';

class MonthlyReportWidget extends ConsumerStatefulWidget {
  const MonthlyReportWidget({super.key});

  static String routeName = 'MonthlyReport';
  static String routePath = '/monthlyReport';

  @override
  ConsumerState<MonthlyReportWidget> createState() => _MonthlyReportWidgetState();
}

class _MonthlyReportWidgetState extends ConsumerState<MonthlyReportWidget> {
  late MonthlyReportModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MonthlyReportModel());
    _model.selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _onFilterChanged() {
    if (_model.selectedClass != null && _model.selectedMonth != null) {
      ref.read(monthlyReportProvider.notifier).fetchReport(
            _model.selectedClass!,
            _model.selectedMonth!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(monthlyReportProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Monthly Attendance',
            subtitle: 'Analysis per student',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          _buildFilters(context),
          Expanded(
            child: _buildBody(reportState, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MonthlyReportState state, bool isDesktop) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (_model.selectedClass == null) {
      return _buildInitialState();
    }

    if (state.students.isEmpty) {
      return _buildEmptyState();
    }

    if (isDesktop) {
      return _buildGridView(state);
    }
    return _buildListView(state);
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text('Select Class & Month', style: AppTypography.sectionTitle),
          Text('Choose criteria to view analysis', style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text('No records found', style: AppTypography.sectionTitle),
          Text('Try selecting a different class or month', style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('Failed to load report', style: AppTypography.sectionTitle),
            Text(error, textAlign: TextAlign.center, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _onFilterChanged,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: ref.watch(studentRepositoryProvider).getAllStudentsStream(),
      builder: (context, snapshot) {
        final allStudents = snapshot.data ?? [];
        final classOptions = allStudents
            .map((s) => s.className)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: _model.classDropdownController ??= FormFieldController<String>(_model.selectedClass),
                  options: classOptions,
                  onChanged: (val) {
                    setState(() => _model.selectedClass = val);
                    _onFilterChanged();
                  },
                  height: 48,
                  hintText: 'Select Class',
                  fillColor: AppColors.surface,
                  borderRadius: AppRadius.md,
                  borderWidth: 1,
                  borderColor: AppColors.outline,
                  hidesUnderline: true,
                  textStyle: AppTypography.bodyMedium,
                  elevation: 0,
                  margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _model.selectedMonth ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                      helpText: 'SELECT MONTH',
                    );
                    if (picked != null) {
                      setState(() => _model.selectedMonth = DateTime(picked.year, picked.month));
                      _onFilterChanged();
                    }
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          DateFormat('MMM yyyy').format(_model.selectedMonth!),
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(MonthlyReportState state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      itemCount: state.students.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _buildReportCard(state, index),
    );
  }

  Widget _buildGridView(MonthlyReportState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: state.students.length,
      itemBuilder: (context, index) => _buildReportCard(state, index),
    );
  }

  Widget _buildReportCard(MonthlyReportState state, int index) {
    final student = state.students[index];
    final logs = state.attendanceData[student.studentId] ?? [];
    final presentCount = logs.where((l) => l.status == 'Present').length;
    final totalDays = logs.length;
    final percentage = totalDays == 0 ? 0.0 : (presentCount / totalDays) * 100;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Roll ${student.rollNo} • ${student.name}',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Present: $presentCount / $totalDays days',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildPercentageIndicator(percentage),
        ],
      ),
    );
  }

  Widget _buildPercentageIndicator(double percentage) {
    final color = percentage >= 90
        ? AppColors.success
        : (percentage >= 75 ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
