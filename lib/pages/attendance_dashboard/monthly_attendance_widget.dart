import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'monthly_attendance_model.dart';

class MonthlyAttendanceWidget extends ConsumerStatefulWidget {
  const MonthlyAttendanceWidget({super.key});

  static String routeName = 'MonthlyAttendance';
  static String routePath = '/monthlyAttendance';

  @override
  ConsumerState<MonthlyAttendanceWidget> createState() => _MonthlyAttendanceWidgetState();
}

class _MonthlyAttendanceWidgetState extends ConsumerState<MonthlyAttendanceWidget> {
  late MonthlyAttendanceModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MonthlyAttendanceModel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final logsAsync = ref.watch(studentAttendanceLogsProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);

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
            title: "Monthly Attendance",
            subtitle: "Academic Trends",
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 12),
                studentsAsync.when(
                  data: (students) {
                    final classes = students.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList()..sort();
                    return DropDownWidget(
                      label: 'Filter by Class',
                      options: ['All Classes', ...classes],
                      onChanged: (val) => setState(() => _model.selectedClass = val == 'All Classes' ? null : val),
                      hint: 'All Classes',
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final monthLogs = logs.where((l) => 
                  l.date.year == _model.selectedYear && 
                  l.date.month == _model.selectedMonth
                ).toList();

                var filtered = monthLogs.where((l) {
                  return _model.selectedClass == null || l.className == _model.selectedClass;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 48, color: theme.secondaryText),
                        const SizedBox(height: 12),
                        Text('No records for this month.', style: theme.labelSmall),
                      ],
                    ),
                  );
                }

                return _buildMonthSummary(context, filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(BuildContext context, List<StudentAttendance> logs) {
    final total = logs.length;
    final present = logs.where((l) => l.status == 'Present').length;
    final absent = logs.where((l) => l.status == 'Absent').length;
    final rate = total == 0 ? 0 : ((present / total) * 100).toInt();

    // Group by day
    final Map<int, List<StudentAttendance>> dayGroups = {};
    for (var l in logs) {
      dayGroups[l.date.day] = (dayGroups[l.date.day] ?? [])..add(l);
    }
    final sortedDays = dayGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, rate, total, present, absent),
          const SizedBox(height: 24),
          Text('DAILY PERFORMANCE', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
          const SizedBox(height: 8),
          ...sortedDays.map((day) {
            final dayLogs = dayGroups[day]!;
            final dayTotal = dayLogs.length;
            final dayPresent = dayLogs.where((l) => l.status == 'Present').length;
            final dayRate = (dayPresent / dayTotal);
            
            return _buildDayProgress(context, day, dayRate, dayTotal, dayPresent);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int rate, int total, int present, int absent) {
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
                  Text('Average Attendance', style: AppTypography.caption.copyWith(color: Colors.white.withAlpha(200))),
                  Text('$rate%', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 32)),
                ],
              ),
              const Icon(Icons.analytics_rounded, color: Colors.white, size: 36),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat('Total Logs', total.toString()),
              _buildSimpleStat('Present', present.toString()),
              _buildSimpleStat('Absent', absent.toString()),
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
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white.withAlpha(180), fontSize: 10)),
      ],
    );
  }

  Widget _buildDayProgress(BuildContext context, int day, double value, int total, int present) {
    final theme = FlutterFlowTheme.of(context);
    final color = value >= 0.9 ? theme.success : (value >= 0.75 ? theme.primary : theme.warning);
    
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
              Text('Day $day', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$present / $total', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
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
}
