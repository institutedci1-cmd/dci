import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class ResultService {
  final Ref ref;

  ResultService(this.ref);

  Future<void> saveMarks(List<ExamResult> results) async {
    final repository = ref.read(resultRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.saveResults(results);

    if (results.isNotEmpty) {
      final first = results.first;
      await auditRepo.logAction(
        module: 'RESULTS',
        action: 'SAVE_MARKS',
        newValue: {'count': results.length},
        metadata: {
          'examId': first.examId,
          'className': first.className,
          'subject': first.subject,
        },
      );
    }
  }

  Future<void> printReportCard(String studentId, String examId) async {
    // Logic to fetch data and call ReportCardService
  }

  Future<void> printMeritList(String examId) async {
    // Logic to fetch data and call ReportCardService
  }
}
