import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:uuid/uuid.dart';

class EditStudentState {
  final bool isLoading;
  final bool isSaving;
  final Teacher? currentUser;
  final String? photoUrl;

  EditStudentState({
    this.isLoading = false,
    this.isSaving = false,
    this.currentUser,
    this.photoUrl,
  });

  EditStudentState copyWith({
    bool? isLoading,
    bool? isSaving,
    Teacher? currentUser,
    String? photoUrl,
  }) {
    return EditStudentState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      currentUser: currentUser ?? this.currentUser,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class EditStudentNotifier extends StateNotifier<EditStudentState> {
  EditStudentNotifier(this.ref) : super(EditStudentState());

  final Ref ref;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final userData = await ref.read(userRepositoryProvider).getUserData();
      state = state.copyWith(currentUser: userData, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setPhotoUrl(String? url) => state = state.copyWith(photoUrl: url);

  bool get isAdmin => state.currentUser?.role == 'Admin';

  Future<bool> saveStudent(Student student, {required bool isNew}) async {
    state = state.copyWith(isSaving: true);
    try {
      String finalId = student.id;
      if (isNew && finalId.isEmpty) {
        finalId = 'STU-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      }

      final studentToSave = student.copyWith(id: finalId, photoUrl: state.photoUrl);
      await ref.read(studentServiceProvider).saveStudent(studentToSave, isNew: isNew);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    state = state.copyWith(isSaving: true);
    try {
      await ref.read(studentServiceProvider).deleteStudent(id);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

final editStudentNotifierProvider = StateNotifierProvider.autoDispose<EditStudentNotifier, EditStudentState>((ref) {
  return EditStudentNotifier(ref);
});
