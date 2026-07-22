import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_c_i_teacher_app/backend/models/attendance_record.dart';
import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';

abstract class IAttendanceRepository {
  Future<void> recordStaffAttendance(AttendanceRecord record);
  Future<bool> checkAttendanceExists(String className, String subject, DateTime date);
  Future<void> recordStudentAttendance(List<StudentAttendance> attendanceData);
  Stream<List<AttendanceRecord>> getUserAttendance({int limit = 20, String? userId});
  Stream<List<StudentAttendance>> getStudentAttendanceLogs({int limit = 50, String? userId});
  Future<List<StudentAttendance>> getDailyAttendance(String className, DateTime date);
  Future<List<StudentAttendance>> getAttendanceByDateRange(String className, DateTime start, DateTime end);
  Stream<List<StudentAttendance>> getStudentAttendanceHistory(String studentId, {int limit = 100});
  Future<List<StudentAttendance>> getStudentAttendanceHistoryPaginated(String studentId, int limit, {DocumentSnapshot? lastDocument});
}
