import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:rxdart/rxdart.dart';

/// Provider for the raw search query from the text field
final studentSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for the class filter selection
final studentClassFilterProvider = StateProvider<String?>((ref) => null);

/// A provider that provides a debounced version of the search query
final debouncedStudentSearchQueryProvider = StreamProvider<String>((ref) {
  final queryController = StreamController<String>();
  
  // Watch the raw query and add to stream
  final sub = ref.listen(studentSearchQueryProvider, (prev, next) {
    queryController.add(next);
  });
  
  ref.onDispose(() {
    sub.close();
    queryController.close();
  });

  // Use RxDart to debounce
  return queryController.stream
      .debounceTime(const Duration(milliseconds: 350))
      .distinct();
});

/// Provider for the filtered list of students
final filteredStudentsProvider = Provider<AsyncValue<List<Student>>>((ref) {
  final studentsAsync = ref.watch(studentsStreamProvider);
  final classFilter = ref.watch(studentClassFilterProvider);
  final searchQuery = ref.watch(debouncedStudentSearchQueryProvider).value ?? '';

  return studentsAsync.whenData((allStudents) {
    var filtered = allStudents;
    
    if (classFilter != null && classFilter.isNotEmpty) {
      filtered = filtered.where((s) => s.className == classFilter).toList();
    }
    
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(q) || 
               s.studentId.toLowerCase().contains(q) ||
               s.rollNo.contains(q) ||
               (s.parentPhone?.contains(q) ?? false) ||
               (s.parentName?.toLowerCase().contains(q) ?? false) ||
               s.className.toLowerCase().contains(q);
      }).toList();
    }
    
    return filtered;
  });
});

class StudentListNotifier extends Notifier<void> {
  @override
  void build() {}

  void updateSearchQuery(String query) {
    ref.read(studentSearchQueryProvider.notifier).state = query;
  }

  void updateClassFilter(String? className) {
    final effectiveClass = className == 'All Classes' ? null : className;
    ref.read(studentClassFilterProvider.notifier).state = effectiveClass;
  }

  void clearFilters() {
    ref.read(studentSearchQueryProvider.notifier).state = '';
    ref.read(studentClassFilterProvider.notifier).state = null;
  }
}

final studentListNotifierProvider = NotifierProvider<StudentListNotifier, void>(() {
  return StudentListNotifier();
});
