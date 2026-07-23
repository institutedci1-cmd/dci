import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReportTemplate {
  final String id;
  final String templateName;
  final String className;
  final String subject;
  final String chapter;
  final String topics;
  final String homework;
  final String remarks;
  final String createdBy;

  DailyReportTemplate({
    required this.id,
    required this.templateName,
    required this.className,
    required this.subject,
    required this.chapter,
    required this.topics,
    required this.homework,
    required this.remarks,
    required this.createdBy,
  });

  factory DailyReportTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyReportTemplate(
      id: doc.id,
      templateName: data['templateName'] ?? 'Untitled Template',
      className: data['class'] ?? '',
      subject: data['subject'] ?? '',
      chapter: data['chapter'] ?? '',
      topics: data['topics'] ?? '',
      homework: data['homework'] ?? '',
      remarks: data['remarks'] ?? '',
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'templateName': templateName,
      'class': className,
      'subject': subject,
      'chapter': chapter,
      'topics': topics,
      'homework': homework,
      'remarks': remarks,
      'createdBy': createdBy,
    };
  }
}
