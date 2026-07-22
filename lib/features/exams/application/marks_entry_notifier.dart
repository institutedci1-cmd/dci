import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/auth/firebase_auth/auth_util.dart';

class MarksEntryState {
  final bool isSaving;

  MarksEntryState({
    this.isSaving = false,
  });

  MarksEntryState copyWith({
    bool? isSaving,
  }) {
    return MarksEntryState(
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class MarksEntryNotifier extends AutoDisposeAsyncNotifier<MarksEntryState> {
  @override
  FutureOr<MarksEntryState> build() {
    return MarksEntryState();
  }

  Future<bool> saveResults({
    required String examId,
    required String subject,
    required int totalMarks,
    required int passingMarks,
    required List<({String studentId, String studentName, String className, double marks, String remarks})> entries,
  }) async {
    state = AsyncData(state.value!.copyWith(isSaving: true));
    try {
      final List<ExamResult> results = entries.map((e) {
        return ExamResult(
          id: '',
          examId: examId,
          studentId: e.studentId,
          studentName: e.studentName,
          className: e.className,
          subject: subject,
          marksObtained: e.marks,
          totalMarks: totalMarks,
          passingMarks: passingMarks,
          grade: ExamResult.calculateGrade(e.marks, totalMarks),
          remarks: e.remarks,
          recordedBy: currentUserUid,
        );
      }).toList();

      await ref.read(resultServiceProvider).saveMarks(results);
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return true;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return false;
    }
  }
}

final marksEntryNotifierProvider = AsyncNotifierProvider.autoDispose<MarksEntryNotifier, MarksEntryState>(() {
  return MarksEntryNotifier();
});
