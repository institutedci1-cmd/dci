import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_c_i_teacher_app/backend/repositories/daily_report_repository.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late DailyReportRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-uid');
    when(() => mockUser.email).thenReturn('test@example.com');
    
    repository = DailyReportRepository(firestore: fakeFirestore, auth: mockAuth);
  });

  test('submitReport adds a report to Firestore', () async {
    final report = DailyReport(
      id: '',
      className: 'Class 10',
      subject: 'Math',
      teacher: 'Ikram Sir',
      chapter: 'Algebra',
      topics: 'Functions',
      presentCount: 20,
      absentCount: 5,
      homeworkAssigned: 'Exercise 1',
      remarks: 'Good',
      createdBy: 'test-uid',
      createdByEmail: 'test@example.com',
    );

    await repository.submitReport(report);

    final snapshot = await fakeFirestore.collection('daily_reports').get();
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['class'], 'Class 10');
  });

  test('getLastReport returns the latest report', () async {
    await fakeFirestore.collection('daily_reports').add({
      'class': 'Class 9',
      'createdBy': 'test-uid',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    });
    
    await fakeFirestore.collection('daily_reports').add({
      'class': 'Class 10',
      'createdBy': 'test-uid',
      'createdAt': DateTime.now(),
    });

    final lastReport = await repository.getLastReport();
    expect(lastReport?.className, 'Class 10');
  });
}
