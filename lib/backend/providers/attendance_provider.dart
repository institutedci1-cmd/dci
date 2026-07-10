import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_attendance.dart';
import 'repository_providers.dart';

class AttendanceState {
  final List<StudentAttendance> logs;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final DocumentSnapshot? lastDoc;
  final String? filterClass;
  final String? filterStatus;

  AttendanceState({
    this.logs = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.lastDoc,
    this.filterClass,
    this.filterStatus,
  });

  AttendanceState copyWith({
    List<StudentAttendance>? logs,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    DocumentSnapshot? lastDoc,
    String? filterClass,
    String? filterStatus,
  }) {
    return AttendanceState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      lastDoc: lastDoc ?? this.lastDoc,
      filterClass: filterClass ?? this.filterClass,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref ref;

  AttendanceNotifier(this.ref) : super(AttendanceState());

  Future<void> fetchLogs({bool isRefresh = false}) async {
    if (state.isLoading || (!state.hasMore && !isRefresh)) return;

    if (isRefresh) {
      state = state.copyWith(isLoading: true, logs: [], lastDoc: null, hasMore: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final snapshot = await repo.getPaginatedAttendanceLogs(
        limit: 20,
        startAfter: state.lastDoc,
        className: state.filterClass,
        status: state.filterStatus,
      );

      final newLogs = snapshot.docs.map((doc) => StudentAttendance.fromFirestore(doc)).toList();
      
      state = state.copyWith(
        logs: [...state.logs, ...newLogs],
        isLoading: false,
        lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : state.lastDoc,
        hasMore: snapshot.docs.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateFilters({String? className, String? status}) {
    state = state.copyWith(
      filterClass: className,
      filterStatus: status,
      logs: [],
      lastDoc: null,
      hasMore: true,
    );
    fetchLogs(isRefresh: true);
  }
}

final paginatedAttendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref);
});
