import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';

abstract class IDailyReportRepository {
  Future<void> submitReport(DailyReport report);
  Future<DailyReport?> getLastReport();
  Stream<List<DailyReport>> getRecentReports({int limit = 10});
  Future<List<DailyReport>> getReportsByDateRange(DateTime start, DateTime end);
}
