import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class ReportService {
  final Ref ref;

  ReportService(this.ref);

  Future<void> submitDailyReport(DailyReport report) async {
    final repository = ref.read(dailyReportRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    Map<String, dynamic>? previousValue;
    if (report.id.isNotEmpty) {
      final existing = await repository.getReportById(report.id);
      previousValue = existing?.toFirestore();
    }

    await repository.submitReport(report);

    await auditRepo.logAction(
      module: 'REPORTS',
      action: report.id.isEmpty ? 'SUBMIT_DAILY' : 'UPDATE_DAILY',
      previousValue: previousValue,
      newValue: report.toFirestore(),
    );
  }

  Future<void> exportHistoryToExcel() async {
    // Logic for Excel export with auditing
  }
}
