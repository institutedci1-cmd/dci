import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String studentId;
  final String className;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.className,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      studentId: data['student_id'] ?? '',
      className: data['class'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'student_id': studentId,
      'class': className,
    };
  }
}
