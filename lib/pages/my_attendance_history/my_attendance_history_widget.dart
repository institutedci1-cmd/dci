import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_attendance_history_model.dart';

class MyAttendanceHistoryWidget extends ConsumerStatefulWidget {
  const MyAttendanceHistoryWidget({super.key});

  static String routeName = 'MyAttendanceHistory';
  static String routePath = '/myAttendanceHistory';

  @override
  ConsumerState<MyAttendanceHistoryWidget> createState() => _MyAttendanceHistoryWidgetState();
}

class _MyAttendanceHistoryWidgetState extends ConsumerState<MyAttendanceHistoryWidget> {
  late MyAttendanceHistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyAttendanceHistoryModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final historyAsync = ref.watch(myAttendanceHistoryProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'My Attendance',
            subtitle: 'Tracking your presence',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: historyAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.fact_check_rounded,
                    title: 'No records found',
                    description: 'Your attendance history will appear here once marked by teachers.',
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.pagePadding,
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final color = _getStatusColor(record.status, theme);
                    
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
                          child: Icon(_getStatusIcon(record.status), color: color, size: 20),
                        ),
                        title: Text(record.subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateTimeFormat('yMMMd', record.date), style: AppTypography.caption),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withAlpha(50)),
                          ),
                          child: Text(record.status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
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

  Color _getStatusColor(String status, FlutterFlowTheme theme) {
    switch (status) {
      case 'Present': return theme.success;
      case 'Absent': return theme.error;
      case 'Leave': return theme.warning;
      default: return theme.secondaryText;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present': return Icons.check_circle_rounded;
      case 'Absent': return Icons.cancel_rounded;
      case 'Leave': return Icons.pause_circle_rounded;
      default: return Icons.help_rounded;
    }
  }
}
