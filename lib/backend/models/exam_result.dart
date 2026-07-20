import 'package:cloud_firestore/cloud_firestore.dart';

class ExamResult {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final String className;
  final String subject;
  final double marksObtained;
  final int totalMarks;
  final int passingMarks;
  final String grade;
  final String remarks;
  final String recordedBy;
  final DateTime? createdAt;

  ExamResult({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
    required this.passingMarks,
    required this.grade,
    required this.remarks,
    required this.recordedBy,
    this.createdAt,
  });

  factory ExamResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExamResult(
      id: doc.id,
      examId: data['examId']?.toString() ?? '',
      studentId: data['studentId']?.toString() ?? '',
      studentName: data['studentName']?.toString() ?? '',
      className: data['class']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      marksObtained: (data['marksObtained'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (data['totalMarks'] as num?)?.toInt() ?? 100,
      passingMarks: (data['passingMarks'] as num?)?.toInt() ?? 35,
      grade: data['grade']?.toString() ?? '',
      remarks: data['remarks']?.toString() ?? '',
      recordedBy: data['recordedBy']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examId': examId,
      'studentId': studentId,
      'studentName': studentName,
      'class': className,
      'subject': subject,
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
      'grade': grade,
      'remarks': remarks,
      'recordedBy': recordedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  static String calculateGrade(double marks, int total) {
    double percentage = (marks / total) * 100;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    if (percentage >= 35) return 'E';
    return 'F';
  }
}
