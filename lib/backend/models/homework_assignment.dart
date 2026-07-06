import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkAssignment {
  final String id;
  final String className;
  final String subject;
  final String teacher;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  final String createdBy;
  final String createdByEmail;
  final DateTime? createdAt;

  HomeworkAssignment({
    required this.id,
    required this.className,
    required this.subject,
    required this.teacher,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdBy,
    required this.createdByEmail,
    this.createdAt,
  });

  factory HomeworkAssignment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HomeworkAssignment(
      id: doc.id,
      className: data['class'] ?? '',
      subject: data['subject'] ?? '',
      teacher: data['teacher'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: data['dueDate'] ?? '',
      status: data['status'] ?? 'draft',
      createdBy: data['createdBy'] ?? '',
      createdByEmail: data['createdByEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'class': className,
      'subject': subject,
      'teacher': teacher,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
