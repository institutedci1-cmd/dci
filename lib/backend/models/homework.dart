import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String id;
  final String teacherId;
  final String teacherName;
  final String className;
  final String subject;
  final String chapter;
  final String homework;
  final String remarks;
  final DateTime assignedDate;
  final bool completed;
  final DateTime? createdAt;
  final List<String> attachments;

  Homework({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.className,
    required this.subject,
    required this.chapter,
    required this.homework,
    required this.remarks,
    required this.assignedDate,
    this.completed = false,
    this.createdAt,
    this.attachments = const [],
  });

  factory Homework.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Homework(
      id: doc.id,
      teacherId: data['teacherId']?.toString() ?? '',
      teacherName: data['teacherName']?.toString() ?? '',
      className: data['className']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      chapter: data['chapter']?.toString() ?? '',
      homework: data['homework']?.toString() ?? '',
      remarks: data['remarks']?.toString() ?? '',
      assignedDate: (data['assignedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completed: data['completed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      attachments: List<String>.from(data['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'className': className,
      'subject': subject,
      'chapter': chapter,
      'homework': homework,
      'remarks': remarks,
      'assignedDate': Timestamp.fromDate(assignedDate),
      'completed': completed,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'attachments': attachments,
    };
  }

  Homework copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? className,
    String? subject,
    String? chapter,
    String? homework,
    String? remarks,
    DateTime? assignedDate,
    bool? completed,
    DateTime? createdAt,
    List<String>? attachments,
  }) {
    return Homework(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      chapter: chapter ?? this.chapter,
      homework: homework ?? this.homework,
      remarks: remarks ?? this.remarks,
      assignedDate: assignedDate ?? this.assignedDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
    );
  }
}
