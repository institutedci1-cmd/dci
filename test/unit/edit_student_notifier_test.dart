import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/features/student/application/edit_student_notifier.dart';
import 'package:d_c_i_teacher_app/backend/repositories/student_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/user_repository.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';

class MockStudentRepository extends Mock implements StudentRepository {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockStudentRepository mockStudentRepo;
  late MockUserRepository mockUserRepo;
  late ProviderContainer container;

  setUp(() {
    mockStudentRepo = MockStudentRepository();
    mockUserRepo = MockUserRepository();

    container = ProviderContainer(
      overrides: [
        studentRepositoryProvider.overrideWithValue(mockStudentRepo),
        userRepositoryProvider.overrideWithValue(mockUserRepo),
      ],
    );

    registerFallbackValue(Student(id: '', name: '', studentId: '', rollNo: '', className: ''));
  });

  tearDown(() {
    container.dispose();
  });

  test('initialize fetches current user data', () async {
    final user = Teacher(
      uid: '1', 
      role: 'Teacher', 
      displayName: 'Teacher John',
      email: 'john@dci.com',
      photoUrl: '',
      designation: 'Faculty',
      phoneNumber: '1234567890',
    );
    when(() => mockUserRepo.getUserData()).thenAnswer((_) async => user);

    final notifier = container.read(editStudentNotifierProvider.notifier);
    await notifier.initialize();

    final state = container.read(editStudentNotifierProvider);
    expect(state.currentUser, user);
    expect(state.isLoading, isFalse);
  });

  test('saveStudent calls repository and updates state', () async {
    final student = Student(id: 'S1', name: 'Student 1', studentId: 'S1', rollNo: '1', className: 'C1');
    when(() => mockStudentRepo.updateStudent(any())).thenAnswer((_) async => {});

    final notifier = container.read(editStudentNotifierProvider.notifier);
    final result = await notifier.saveStudent(student, isNew: false);

    expect(result, isTrue);
    verify(() => mockStudentRepo.updateStudent(any())).called(1);
    expect(container.read(editStudentNotifierProvider).isSaving, isFalse);
  });

  test('deleteStudent fails if user is not admin', () async {
    final user = Teacher(
      uid: '1', 
      role: 'Teacher', 
      displayName: 'Teacher John',
      email: 'john@dci.com',
      photoUrl: '',
      designation: 'Faculty',
      phoneNumber: '1234567890',
    );
    when(() => mockUserRepo.getUserData()).thenAnswer((_) async => user);

    final notifier = container.read(editStudentNotifierProvider.notifier);
    await notifier.initialize();

    final result = await notifier.deleteStudent('S1');

    expect(result, isFalse);
    verifyNever(() => mockStudentRepo.deleteStudent(any()));
  });

  test('deleteStudent succeeds if user is admin', () async {
    final admin = Teacher(
      uid: '1', 
      role: 'Admin', 
      displayName: 'Admin Joe',
      email: 'admin@dci.com',
      photoUrl: '',
      designation: 'Admin',
      phoneNumber: '1234567890',
    );
    when(() => mockUserRepo.getUserData()).thenAnswer((_) async => admin);
    when(() => mockStudentRepo.deleteStudent(any())).thenAnswer((_) async => {});

    final notifier = container.read(editStudentNotifierProvider.notifier);
    await notifier.initialize();

    final result = await notifier.deleteStudent('S1');

    expect(result, isTrue);
    verify(() => mockStudentRepo.deleteStudent('S1')).called(1);
  });
}
