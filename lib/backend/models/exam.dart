import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id;
  final String className;
  final String subject;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalMarks;
  final int passingMarks;
  final String venue;
  final String description;
  final String createdBy;
  final DateTime? createdAt;

  Exam({
    required this.id,
    required this.className,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalMarks,
    required this.passingMarks,
    required this.venue,
    required this.description,
    required this.createdBy,
    this.createdAt,
  });

  factory Exam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Exam(
      id: doc.id,
      className: data['class']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime']?.toString() ?? '',
      endTime: data['endTime']?.toString() ?? '',
      totalMarks: (data['totalMarks'] as num?)?.toInt() ?? 100,
      passingMarks: (data['passingMarks'] as num?)?.toInt() ?? 35,
      venue: data['venue']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdBy: data['createdBy']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'class': className,
      'subject': subject,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
      'venue': venue,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
