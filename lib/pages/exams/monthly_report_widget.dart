import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'monthly_report_model.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final years = List.generate(5, (i) => (DateTime.now().year - i).toString());

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Monthly Analytics',
            subtitle: 'Academic trends & insights',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropDownWidget(
                    label: 'Year',
                    options: years,
                    controller: FormFieldController<String>(_model.selectedYear.toString()),
                    onChanged: (val) => setState(() => _model.selectedYear = int.parse(val!)),
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropDownWidget(
                    label: 'Month',
                    options: months,
                    controller: FormFieldController<String>(months[_model.selectedMonth - 1]),
                    onChanged: (val) => setState(() => _model.selectedMonth = months.indexOf(val!) + 1),
                    height: 48,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildPerformanceView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 20),
          Text('SUBJECT-WISE ANALYSIS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
          const SizedBox(height: 8),
          _buildSubjectProgress(context, 'Mathematics', 0.88, AppColors.primary),
          _buildSubjectProgress(context, 'Science', 0.76, AppColors.info),
          _buildSubjectProgress(context, 'English', 0.92, AppColors.success),
          _buildSubjectProgress(context, 'Social Studies', 0.70, AppColors.warning),
          const SizedBox(height: 24),
          _buildInsightSection(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Performance', style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                  Text('82.5%', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 32)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withAlpha(50), shape: BoxShape.circle),
                child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat('Tests', '14'),
              _buildSimpleStat('Avg Pass', '94%'),
              _buildSimpleStat('Top Score', '98'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.label.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildSubjectProgress(BuildContext context, String subject, double value, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Insight', style: AppTypography.label.copyWith(color: AppColors.info, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Mathematics performance has improved by 5% since last month. Consider focusing on Science fundamentals for upcoming mid-terms.',
                  style: AppTypography.caption.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
