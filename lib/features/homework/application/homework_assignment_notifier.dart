import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeworkAssignmentState {
  final bool isSaving;
  final bool isUploading;
  final List<String> attachmentUrls;

  HomeworkAssignmentState({
    this.isSaving = false,
    this.isUploading = false,
    this.attachmentUrls = const [],
  });

  HomeworkAssignmentState copyWith({
    bool? isSaving,
    bool? isUploading,
    List<String>? attachmentUrls,
  }) {
    return HomeworkAssignmentState(
      isSaving: isSaving ?? this.isSaving,
      isUploading: isUploading ?? this.isUploading,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }
}

class HomeworkAssignmentNotifier extends AutoDisposeAsyncNotifier<HomeworkAssignmentState> {
  @override
  FutureOr<HomeworkAssignmentState> build() {
    return HomeworkAssignmentState();
  }

  void addAttachment(String url) {
    final currentUrls = state.value!.attachmentUrls;
    state = AsyncData(state.value!.copyWith(attachmentUrls: [...currentUrls, url]));
  }

  void removeAttachment(String url) {
    final currentUrls = state.value!.attachmentUrls;
    state = AsyncData(state.value!.copyWith(
      attachmentUrls: currentUrls.where((u) => u != url).toList(),
    ));
    // Optionally call storage service to delete
  }

  void setUploading(bool val) {
    state = AsyncData(state.value!.copyWith(isUploading: val));
  }

  Future<bool> saveHomework({
    required String className,
    required String subject,
    required String teacher,
    required String title,
    required String description,
    required DateTime? dueDate,
    required String status,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    state = AsyncData(state.value!.copyWith(isSaving: true));
    try {
      final assignment = HomeworkAssignment(
        id: '',
        className: className,
        subject: subject,
        teacher: teacher,
        title: title,
        description: description,
        dueDate: dueDate != null ? dueDate.toIso8601String() : 'No Due Date', // Format properly as needed
        status: status,
        attachments: state.value!.attachmentUrls,
        createdBy: user.uid,
        createdByEmail: user.email ?? '',
      );

      await ref.read(homeworkServiceProvider).saveHomework(assignment);
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return true;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isSaving: false));
      return false;
    }
  }
}

final homeworkAssignmentNotifierProvider = AsyncNotifierProvider.autoDispose<HomeworkAssignmentNotifier, HomeworkAssignmentState>(() {
  return HomeworkAssignmentNotifier();
});
