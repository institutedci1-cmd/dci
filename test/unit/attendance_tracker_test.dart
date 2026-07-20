import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/features/attendance/application/attendance_tracker_notifier.dart';
import 'package:d_c_i_teacher_app/backend/repositories/student_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/attendance_repository.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';

class MockStudentRepository extends Mock implements StudentRepository {}
class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  late MockStudentRepository mockStudentRepo;
  late MockAttendanceRepository mockAttendanceRepo;
  late ProviderContainer container;

  setUp(() {
    mockStudentRepo = MockStudentRepository();
    mockAttendanceRepo = MockAttendanceRepository();

    container = ProviderContainer(
      overrides: [
        studentRepositoryProvider.overrideWithValue(mockStudentRepo),
        attendanceRepositoryProvider.overrideWithValue(mockAttendanceRepo),
      ],
    );

    registerFallbackValue(DateTime.now());
  });

  tearDown(() {
    container.dispose();
  });

  test('loadStudents updates state with students and default Present status', () async {
    final students = [
      Student(id: '1', name: 'Student 1', studentId: 'S1', rollNo: '1', className: 'Class 1'),
      Student(id: '2', name: 'Student 2', studentId: 'S2', rollNo: '2', className: 'Class 1'),
    ];

    when(() => mockStudentRepo.getStudentsByClass('Class 1'))
        .thenAnswer((_) async => students);
    when(() => mockAttendanceRepo.checkAttendanceExists(any(), any(), any()))
        .thenAnswer((_) async => false);

    final notifier = container.read(attendanceTrackerNotifierProvider.notifier);
    await notifier.loadStudents('Class 1');

    final state = container.read(attendanceTrackerNotifierProvider);
    expect(state.students, students);
    expect(state.attendanceMap['1'], 'Present');
    expect(state.attendanceMap['2'], 'Present');
  });

  test('toggleAttendance switches between Present and Absent', () async {
    final students = [
      Student(id: '1', name: 'Student 1', studentId: 'S1', rollNo: '1', className: 'Class 1'),
    ];
    
    when(() => mockStudentRepo.getStudentsByClass('Class 1'))
        .thenAnswer((_) async => students);
    when(() => mockAttendanceRepo.checkAttendanceExists(any(), any(), any()))
        .thenAnswer((_) async => false);

    final notifier = container.read(attendanceTrackerNotifierProvider.notifier);
    await notifier.loadStudents('Class 1');
    
    notifier.toggleAttendance('1');
    expect(container.read(attendanceTrackerNotifierProvider).attendanceMap['1'], 'Absent');
    
    notifier.toggleAttendance('1');
    expect(container.read(attendanceTrackerNotifierProvider).attendanceMap['1'], 'Present');
  });

  test('setAllStatus updates all students at once', () async {
    final students = [
      Student(id: '1', name: 'S1', studentId: 'S1', rollNo: '1', className: 'C1'),
      Student(id: '2', name: 'S2', studentId: 'S2', rollNo: '2', className: 'C1'),
    ];
    
    when(() => mockStudentRepo.getStudentsByClass('C1'))
        .thenAnswer((_) async => students);
    when(() => mockAttendanceRepo.checkAttendanceExists(any(), any(), any()))
        .thenAnswer((_) async => false);

    final notifier = container.read(attendanceTrackerNotifierProvider.notifier);
    await notifier.loadStudents('C1');
    
    notifier.setAllStatus('Absent');
    expect(container.read(attendanceTrackerNotifierProvider).attendanceMap['1'], 'Absent');
    expect(container.read(attendanceTrackerNotifierProvider).attendanceMap['2'], 'Absent');
  });
}
