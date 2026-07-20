import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// State for the attendance tracker
class AttendanceTrackerState {
  final bool isSaving;
  final bool isAlreadySubmitted;
  final String? selectedClass;
  final String? selectedSubject;
  final DateTime selectedDate;
  final List<Student> students;
  final Map<String, String> attendanceMap;
  final List<String> subjectOptions;
  final String searchQuery;

  AttendanceTrackerState({
    this.isSaving = false,
    this.isAlreadySubmitted = false,
    this.selectedClass,
    this.selectedSubject,
    required this.selectedDate,
    this.students = const [],
    this.attendanceMap = const {},
    this.subjectOptions = const [],
    this.searchQuery = '',
  });

  AttendanceTrackerState copyWith({
    bool? isSaving,
    bool? isAlreadySubmitted,
    String? selectedClass,
    String? selectedSubject,
    DateTime? selectedDate,
    List<Student>? students,
    Map<String, String>? attendanceMap,
    List<String>? subjectOptions,
    String? searchQuery,
  }) {
    return AttendanceTrackerState(
      isSaving: isSaving ?? this.isSaving,
      isAlreadySubmitted: isAlreadySubmitted ?? this.isAlreadySubmitted,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedDate: selectedDate ?? this.selectedDate,
      students: students ?? this.students,
      attendanceMap: attendanceMap ?? this.attendanceMap,
      subjectOptions: subjectOptions ?? this.subjectOptions,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AttendanceTrackerNotifier extends AutoDisposeAsyncNotifier<AttendanceTrackerState> {
  @override
  FutureOr<AttendanceTrackerState> build() async {
    final userRepo = ref.read(userRepositoryProvider);
    final subjects = await userRepo.getAllUserSubjects();
    
    return AttendanceTrackerState(
      selectedDate: DateTime.now(),
      subjectOptions: subjects..sort(),
    );
  }

  void updateSearchQuery(String query) {
    state = AsyncData(state.value!.copyWith(searchQuery: query));
  }

  Future<void> setClass(String? className) async {
    final currentState = state.value!;
    if (className == currentState.selectedClass) return;

    state = const AsyncLoading();
    try {
      final repository = ref.read(studentRepositoryProvider);
      final students = className != null 
          ? await repository.getStudentsByClass(className)
          : <Student>[];
      
      final Map<String, String> newMap = {};
      for (final s in students) {
        newMap[s.id] = 'Present';
      }

      state = AsyncData(currentState.copyWith(
        selectedClass: className,
        students: students,
        attendanceMap: newMap,
      ));
      
      await checkExistingAttendance();
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  void setSubject(String? subject) {
    final currentState = state.value!;
    state = AsyncData(currentState.copyWith(selectedSubject: subject));
    checkExistingAttendance();
  }

  void setDate(DateTime date) {
    final currentState = state.value!;
    state = AsyncData(currentState.copyWith(selectedDate: date));
    checkExistingAttendance();
  }

  void toggleAttendance(String studentId) {
    final currentState = state.value!;
    final Map<String, String> newMap = Map.from(currentState.attendanceMap);
    final currentStatus = newMap[studentId] ?? 'Present';
    newMap[studentId] = currentStatus == 'Present' ? 'Absent' : 'Present';
    
    state = AsyncData(currentState.copyWith(attendanceMap: newMap));
  }

  void setAllStatus(String status) {
    final currentState = state.value!;
    final Map<String, String> newMap = Map.from(currentState.attendanceMap);
    for (final s in currentState.students) {
      newMap[s.id] = status;
    }
    state = AsyncData(currentState.copyWith(attendanceMap: newMap));
  }

  Future<void> checkExistingAttendance() async {
    final currentState = state.value!;
    final className = currentState.selectedClass;
    final subject = currentState.selectedSubject;
    final date = currentState.selectedDate;

    if (className == null || subject == null) {
      state = AsyncData(currentState.copyWith(isAlreadySubmitted: false));
      return;
    }

    try {
      final exists = await ref.read(attendanceRepositoryProvider).checkAttendanceExists(
        className, 
        subject, 
        date
      );
      state = AsyncData(state.value!.copyWith(isAlreadySubmitted: exists));
    } catch (e) {
      // Silently fail for check
    }
  }

  Future<bool> saveAttendance({bool sendWhatsApp = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final currentState = state.value!;
    if (currentState.selectedClass == null || currentState.selectedSubject == null) return false;

    state = AsyncData(currentState.copyWith(isSaving: true));
    try {
      final attendanceRepository = ref.read(attendanceRepositoryProvider);
      
      final attendanceList = currentState.students.map((s) {
        return StudentAttendance(
          id: '',
          studentId: s.studentId,
          studentName: s.name,
          className: currentState.selectedClass!,
          subject: currentState.selectedSubject!,
          status: currentState.attendanceMap[s.id] ?? 'Present',
          date: currentState.selectedDate,
          markedBy: user.uid,
        );
      }).toList();

      await attendanceRepository.recordStudentAttendance(attendanceList);

      if (sendWhatsApp) {
        final whatsappService = ref.read(whatsappServiceProvider);
        final absentStudents = currentState.students.where((s) => (currentState.attendanceMap[s.id] ?? 'Present') == 'Absent').toList();
        
        if (absentStudents.isNotEmpty) {
          final alertFutures = absentStudents
              .where((s) => s.parentPhone != null && s.parentPhone!.isNotEmpty)
              .map((s) => whatsappService.sendTemplateMessage(
                    to: s.parentPhone!,
                    templateName: 'student_absent_alert',
                    parameters: [s.name, dateTimeFormat('yMMMd', currentState.selectedDate)],
                  ));
          await Future.wait(alertFutures).catchError((_) => <bool>[]);
        }
      }

      state = AsyncData(state.value!.copyWith(isSaving: false));
      return true;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return false;
    }
  }
}

final attendanceTrackerNotifierProvider = AsyncNotifierProvider.autoDispose<AttendanceTrackerNotifier, AttendanceTrackerState>(() {
  return AttendanceTrackerNotifier();
});
