import 'dart:io';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';

abstract class IUserRepository {
  Stream<Teacher?> getUserStream();
  Stream<Teacher?> getUserStreamById(String uid);
  Future<Teacher?> getUserData();
  Future<List<Teacher>> getTeachers();
  Stream<List<Teacher>> getAllUsersStream();
  Future<void> updateProfile(Teacher user);
  Future<String> uploadProfilePicture(File file, {String? targetUid});
  Future<void> saveFCMToken(String token);
  Future<void> toggleNotifications(bool enabled);
  Future<List<String>> getAllUserSubjects();
}
