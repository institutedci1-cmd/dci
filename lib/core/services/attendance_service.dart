import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';

class AttendanceService {
  final Ref ref;

  AttendanceService(this.ref);

  Future<void> recordAttendance({
    required List<StudentAttendance> attendanceList,
    bool sendWhatsApp = false,
  }) async {
    final repository = ref.read(attendanceRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.recordStudentAttendance(attendanceList);

    if (attendanceList.isNotEmpty) {
      final first = attendanceList.first;
      await auditRepo.logAction(
        module: 'ATTENDANCE',
        action: 'RECORD',
        metadata: {
          'className': first.className,
          'subject': first.subject,
          'count': attendanceList.length,
          'date': dateTimeFormat('yMMMd', first.date),
        },
      );
    }

    if (sendWhatsApp) {
      final absentees = attendanceList.where((a) => a.status == 'Absent').toList();
      
      if (absentees.isNotEmpty) {
        // In a real app, you'd fetch parent info if not already in student_attendance
        // or ensure the repository has it.
        // For now, we follow the pattern in the notifier.
        // This is a placeholder for centralized alert logic.
      }
    }
  }
}
