import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyReportFormState {
  final bool isSaving;
  final List<String> teacherOptions;
  final List<String> subjectOptions;
  final List<String> classOptions;
  final DailyReport? lastReport;
  
  // Form values
  final String? selectedClass;
  final String? selectedSubject;
  final String? selectedTeacher;
  final int presentCount;
  final int absentCount;

  DailyReportFormState({
    this.isSaving = false,
    this.teacherOptions = const [],
    this.subjectOptions = const [],
    this.classOptions = const [],
    this.lastReport,
    this.selectedClass,
    this.selectedSubject,
    this.selectedTeacher,
    this.presentCount = 0,
    this.absentCount = 0,
  });

  DailyReportFormState copyWith({
    bool? isSaving,
    List<String>? teacherOptions,
    List<String>? subjectOptions,
    List<String>? classOptions,
    DailyReport? lastReport,
    String? selectedClass,
    String? selectedSubject,
    String? selectedTeacher,
    int? presentCount,
    int? absentCount,
  }) {
    return DailyReportFormState(
      isSaving: isSaving ?? this.isSaving,
      teacherOptions: teacherOptions ?? this.teacherOptions,
      subjectOptions: subjectOptions ?? this.subjectOptions,
      classOptions: classOptions ?? this.classOptions,
      lastReport: lastReport ?? this.lastReport,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedTeacher: selectedTeacher ?? this.selectedTeacher,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
    );
  }
}

class DailyReportNotifier extends AutoDisposeAsyncNotifier<DailyReportFormState> {
  @override
  FutureOr<DailyReportFormState> build() async {
    final userRepo = ref.read(userRepositoryProvider);
    final studentRepo = ref.read(studentRepositoryProvider);
    final reportRepo = ref.read(dailyReportRepositoryProvider);
    
    final results = await Future.wait([
      userRepo.getTeachers(),
      studentRepo.getAllStudents(),
      userRepo.getAllUserSubjects(),
      reportRepo.getLastReport(),
    ]);

    final teachers = results[0] as List<Teacher>;
    final allStudents = results[1] as List<Student>;
    final subjects = results[2] as List<String>;
    final lastReport = results[3] as DailyReport?;

    final teacherNames = teachers.map((t) => t.displayName).toSet().toList();
    final classNames = allStudents.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList();

    String? initialTeacher;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      initialTeacher = teachers.firstWhereOrNull((t) => t.uid == currentUser.uid)?.displayName;
    }

    return DailyReportFormState(
      teacherOptions: teacherNames..sort(),
      subjectOptions: {'English', 'Marathi', 'Math', 'Science', ...subjects}.toList()..sort(),
      classOptions: classNames..sort(),
      lastReport: lastReport,
      selectedTeacher: initialTeacher,
    );
  }

  void setClass(String? val) => state = AsyncData(state.value!.copyWith(selectedClass: val));
  void setSubject(String? val) => state = AsyncData(state.value!.copyWith(selectedSubject: val));
  void setTeacher(String? val) => state = AsyncData(state.value!.copyWith(selectedTeacher: val));
  void setPresentCount(int val) => state = AsyncData(state.value!.copyWith(presentCount: val));
  void setAbsentCount(int val) => state = AsyncData(state.value!.copyWith(absentCount: val));

  void applyLastReport() {
    final report = state.value!.lastReport;
    if (report == null) return;
    state = AsyncData(state.value!.copyWith(
      selectedClass: report.className,
      selectedSubject: report.subject,
      selectedTeacher: report.teacher,
      presentCount: report.presentCount,
      absentCount: report.absentCount,
    ));
  }

  Future<bool> submitReport({
    required String chapter,
    required String topics,
    required String homework,
    required String remarks,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final currentState = state.value!;
    if (currentState.selectedClass == null || currentState.selectedSubject == null || currentState.selectedTeacher == null) {
      return false;
    }

    state = AsyncData(currentState.copyWith(isSaving: true));
    try {
      final report = DailyReport(
        id: '',
        className: currentState.selectedClass!,
        subject: currentState.selectedSubject!,
        teacher: currentState.selectedTeacher!,
        chapter: chapter,
        topics: topics,
        presentCount: currentState.presentCount,
        absentCount: currentState.absentCount,
        homeworkAssigned: homework,
        remarks: remarks,
        createdBy: user.uid,
        createdByEmail: user.email ?? '',
      );

      await ref.read(reportServiceProvider).submitDailyReport(report);
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return true;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return false;
    }
  }
}

final dailyReportNotifierProvider = AsyncNotifierProvider.autoDispose<DailyReportNotifier, DailyReportFormState>(() {
  return DailyReportNotifier();
});
