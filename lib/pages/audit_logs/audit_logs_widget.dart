import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuditLogsWidget extends ConsumerStatefulWidget {
  const AuditLogsWidget({super.key});

  static String routeName = 'AuditLogs';
  static String routePath = '/auditLogs';

  @override
  ConsumerState<AuditLogsWidget> createState() => _AuditLogsWidgetState();
}

class _AuditLogsWidgetState extends ConsumerState<AuditLogsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final logsAsync = ref.watch(auditLogsStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'System Activity',
            subtitle: 'Transparency & Oversight',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return Center(child: Text('No activity logs found.', style: theme.labelSmall));
                }
                return ListView.separated(
                  padding: AppSpacing.pagePadding,
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildLogTile(context, log);
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

  Widget _buildLogTile(BuildContext context, Map<String, dynamic> log) {
    final theme = FlutterFlowTheme.of(context);
    final timestamp = (log['timestamp'] as Timestamp?)?.toDate();
    final module = log['module']?.toString().toUpperCase() ?? 'SYSTEM';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.primary.withAlpha(20), shape: BoxShape.circle),
            child: Icon(_getModuleIcon(module), color: theme.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(module, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 10, color: theme.primary)),
                    Text(
                      timestamp != null ? dateTimeFormat('relative', timestamp) : '...',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(log['action'] ?? 'Unknown action', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('By: ${log['userEmail'] ?? 'anonymous'}', style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModuleIcon(String module) {
    return switch (module) {
      'AUTH' => Icons.lock_outline_rounded,
      'STUDENT' => Icons.people_rounded,
      'ATTENDANCE' => Icons.fact_check_rounded,
      'EXAM' => Icons.assignment_rounded,
      'REPORT' => Icons.assessment_rounded,
      'AI_CHAT' => Icons.auto_awesome_rounded,
      'SETTINGS' => Icons.settings_rounded,
      'ANNOUNCEMENT' => Icons.campaign_rounded,
      _ => Icons.info_outline_rounded,
    };
  }
}
