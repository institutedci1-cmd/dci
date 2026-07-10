import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import 'repository_providers.dart';

class AttendanceTrackerState {
  final List<Student> allStudents;
  final List<Student> filteredStudents;
  final Map<String, String> attendanceMap;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  AttendanceTrackerState({
    this.allStudents = const [],
    this.filteredStudents = const [],
    this.attendanceMap = const {},
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  AttendanceTrackerState copyWith({
    List<Student>? allStudents,
    List<Student>? filteredStudents,
    Map<String, String>? attendanceMap,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return AttendanceTrackerState(
      allStudents: allStudents ?? this.allStudents,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      attendanceMap: attendanceMap ?? this.attendanceMap,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AttendanceTrackerNotifier extends StateNotifier<AttendanceTrackerState> {
  final Ref ref;

  AttendanceTrackerNotifier(this.ref) : super(AttendanceTrackerState());

  Future<void> loadStudents(String className) async {
    state = state.copyWith(isLoading: true, errorMessage: null, allStudents: [], filteredStudents: []);
    
    try {
      final students = await ref.read(studentRepositoryProvider).getStudentsByClass(className);
      
      final Map<String, String> initialMap = {};
      for (var s in students) {
        initialMap[s.studentId] = 'Present';
      }

      state = state.copyWith(
        allStudents: students,
        filteredStudents: students,
        attendanceMap: initialMap,
        isLoading: false,
        errorMessage: students.isEmpty ? 'No students found for this class.' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading students. Please try again.',
      );
    }
  }

  void updateSearch(String query) {
    final q = query.trim().toLowerCase();
    final filtered = state.allStudents.where((s) {
      return s.name.toLowerCase().contains(q) || s.rollNo.contains(q);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredStudents: filtered,
    );
  }

  void toggleAttendance(String studentId) {
    final currentStatus = state.attendanceMap[studentId] ?? 'Present';
    final newStatus = currentStatus == 'Present' ? 'Absent' : 'Present';
    
    state = state.copyWith(
      attendanceMap: {
        ...state.attendanceMap,
        studentId: newStatus,
      },
    );
  }

  void bulkMark(String status) {
    final newMap = Map<String, String>.from(state.attendanceMap);
    for (var s in state.filteredStudents) {
      newMap[s.studentId] = status;
    }
    state = state.copyWith(attendanceMap: newMap);
  }

  void reset() {
    state = AttendanceTrackerState();
  }
}

final attendanceTrackerProvider = StateNotifierProvider.autoDispose<AttendanceTrackerNotifier, AttendanceTrackerState>((ref) {
  return AttendanceTrackerNotifier(ref);
});
