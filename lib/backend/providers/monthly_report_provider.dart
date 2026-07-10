import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/student_attendance.dart';
import 'repository_providers.dart';

class MonthlyReportState {
  final List<Student> students;
  final Map<String, List<StudentAttendance>> attendanceData;
  final bool isLoading;
  final String? errorMessage;

  MonthlyReportState({
    this.students = const [],
    this.attendanceData = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  MonthlyReportState copyWith({
    List<Student>? students,
    Map<String, List<StudentAttendance>>? attendanceData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MonthlyReportState(
      students: students ?? this.students,
      attendanceData: attendanceData ?? this.attendanceData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class MonthlyReportNotifier extends StateNotifier<MonthlyReportState> {
  final Ref ref;

  MonthlyReportNotifier(this.ref) : super(MonthlyReportState());

  Future<void> fetchReport(String className, DateTime month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final studentRepo = ref.read(studentRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      final students = await studentRepo.getStudentsByClass(className);
      final attendance = await attendanceRepo.getMonthlyAttendance(className, month);

      final grouped = <String, List<StudentAttendance>>{};
      for (var record in attendance) {
        grouped.putIfAbsent(record.studentId, () => []).add(record);
      }

      state = state.copyWith(
        students: students,
        attendanceData: grouped,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load report: $e',
      );
    }
  }
}

final monthlyReportProvider = StateNotifierProvider<MonthlyReportNotifier, MonthlyReportState>((ref) {
  return MonthlyReportNotifier(ref);
});
