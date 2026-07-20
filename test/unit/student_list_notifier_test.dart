import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/features/student/application/student_list_notifier.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';

void main() {
  late ProviderContainer container;
  final mockStudents = [
    Student(id: '1', name: 'John Doe', studentId: 'S1', rollNo: '101', className: '10-A'),
    Student(id: '2', name: 'Jane Smith', studentId: 'S2', rollNo: '102', className: '10-B'),
    Student(id: '3', name: 'Bob Wilson', studentId: 'S3', rollNo: '103', className: '10-A'),
  ];

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('initialize sets all students and resets filters', () {
    final notifier = container.read(studentListNotifierProvider.notifier);
    notifier.initialize(mockStudents);

    final state = container.read(studentListNotifierProvider);
    expect(state.allStudents, mockStudents);
    expect(state.filteredStudents, mockStudents);
    expect(state.searchQuery, '');
    expect(state.selectedClass, isNull);
  });

  test('updateSearchQuery filters students by name', () {
    final notifier = container.read(studentListNotifierProvider.notifier);
    notifier.initialize(mockStudents);

    notifier.updateSearchQuery('Jane');
    
    final state = container.read(studentListNotifierProvider);
    expect(state.searchQuery, 'Jane');
    expect(state.filteredStudents.length, 1);
    expect(state.filteredStudents.first.name, 'Jane Smith');
  });

  test('updateSearchQuery filters students by roll number', () {
    final notifier = container.read(studentListNotifierProvider.notifier);
    notifier.initialize(mockStudents);

    notifier.updateSearchQuery('103');
    
    final state = container.read(studentListNotifierProvider);
    expect(state.filteredStudents.length, 1);
    expect(state.filteredStudents.first.name, 'Bob Wilson');
  });

  test('updateClassFilter filters students by class', () {
    final notifier = container.read(studentListNotifierProvider.notifier);
    notifier.initialize(mockStudents);

    notifier.updateClassFilter('10-A');
    
    var state = container.read(studentListNotifierProvider);
    expect(state.selectedClass, '10-A');
    expect(state.filteredStudents.length, 2);
    expect(state.filteredStudents.every((s) => s.className == '10-A'), isTrue);

    notifier.updateClassFilter('All Classes');
    state = container.read(studentListNotifierProvider);
    expect(state.selectedClass, isNull);
    expect(state.filteredStudents.length, 3);
  });

  test('Combined filters (search + class) work correctly', () {
    final notifier = container.read(studentListNotifierProvider.notifier);
    notifier.initialize(mockStudents);

    notifier.updateClassFilter('10-A');
    notifier.updateSearchQuery('Bob');
    
    final state = container.read(studentListNotifierProvider);
    expect(state.filteredStudents.length, 1);
    expect(state.filteredStudents.first.name, 'Bob Wilson');
  });

  test('clearFilters resets search and class filter', () {
    final notifier = container.read(studentListNotifierProvider.notifier);
    notifier.initialize(mockStudents);

    notifier.updateClassFilter('10-B');
    notifier.updateSearchQuery('Jane');
    notifier.clearFilters();
    
    final state = container.read(studentListNotifierProvider);
    expect(state.searchQuery, '');
    expect(state.selectedClass, isNull);
    expect(state.filteredStudents.length, 3);
  });
}
