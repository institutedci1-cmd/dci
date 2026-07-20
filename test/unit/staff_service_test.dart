import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/core/services/staff_service.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';

void main() {
  late ProviderContainer container;
  late StaffService staffService;

  setUp(() {
    container = ProviderContainer();
    staffService = container.read(staffServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('StaffService - Role Permissions', () {
    test('canManageStudents returns true for Admin and Director', () {
      final admin = Teacher(
        uid: '1', email: 'a@dci.com', displayName: 'Admin', photoUrl: '',
        role: 'Admin', designation: '', phoneNumber: '',
      );
      final director = Teacher(
        uid: '2', email: 'd@dci.com', displayName: 'Director', photoUrl: '',
        role: 'Director', designation: '', phoneNumber: '',
      );
      final teacher = Teacher(
        uid: '3', email: 't@dci.com', displayName: 'Teacher', photoUrl: '',
        role: 'Teacher', designation: '', phoneNumber: '',
      );

      expect(staffService.canManageStudents(admin), true);
      expect(staffService.canManageStudents(director), true);
      expect(staffService.canManageStudents(teacher), false);
      expect(staffService.canManageStudents(null), false);
    });

    test('canDeleteReport returns true for Admin or Creator', () {
      final admin = Teacher(
        uid: '1', email: 'a@dci.com', displayName: 'Admin', photoUrl: '',
        role: 'Admin', designation: '', phoneNumber: '',
      );
      final creator = Teacher(
        uid: 'c1', email: 'c@dci.com', displayName: 'Creator', photoUrl: '',
        role: 'Teacher', designation: '', phoneNumber: '',
      );
      final other = Teacher(
        uid: 'o1', email: 'o@dci.com', displayName: 'Other', photoUrl: '',
        role: 'Teacher', designation: '', phoneNumber: '',
      );

      expect(staffService.canDeleteReport(admin, 'c1'), true);
      expect(staffService.canDeleteReport(creator, 'c1'), true);
      expect(staffService.canDeleteReport(other, 'c1'), false);
    });
  });

  group('StaffService - UI Helpers', () {
    test('getRoleBadgeColor returns correct colors', () {
      expect(staffService.getRoleBadgeColor('Admin'), '#EF4444');
      expect(staffService.getRoleBadgeColor('Director'), '#8B5CF6');
      expect(staffService.getRoleBadgeColor('Teacher'), '#059669');
      expect(staffService.getRoleBadgeColor('Unknown'), '#6B7280');
    });
  });
}
