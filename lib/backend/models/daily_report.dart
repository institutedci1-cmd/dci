import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport {
  final String id;
  final String className;
  final String subject;
  final String teacher;
  final String chapter;
  final String topics;
  final int presentCount;
  final int absentCount;
  final String homeworkAssigned;
  final String remarks;
  final String createdBy;
  final String createdByEmail;
  final DateTime? createdAt;

  DailyReport({
    required this.id,
    required this.className,
    required this.subject,
    required this.teacher,
    required this.chapter,
    required this.topics,
    required this.presentCount,
    required this.absentCount,
    required this.homeworkAssigned,
    required this.remarks,
    required this.createdBy,
    required this.createdByEmail,
    this.createdAt,
  });

  factory DailyReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyReport(
      id: doc.id,
      className: data['class'] ?? '',
      subject: data['subject'] ?? '',
      teacher: data['teacher'] ?? '',
      chapter: data['chapter'] ?? '',
      topics: data['topics'] ?? '',
      presentCount: data['presentCount'] ?? 0,
      absentCount: data['absentCount'] ?? 0,
      homeworkAssigned: data['homeworkAssigned'] ?? '',
      remarks: data['remarks'] ?? '',
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
      'chapter': chapter,
      'topics': topics,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'homeworkAssigned': homeworkAssigned,
      'remarks': remarks,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
