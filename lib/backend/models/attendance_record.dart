import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String status;
  final String remarks;
  final String createdBy;
  final String createdByEmail;
  final DateTime? createdAt;

  AttendanceRecord({
    required this.id,
    required this.status,
    required this.remarks,
    required this.createdBy,
    required this.createdByEmail,
    this.createdAt,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      status: data['status'] ?? 'Present',
      remarks: data['remarks'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdByEmail: data['createdByEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'remarks': remarks,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
