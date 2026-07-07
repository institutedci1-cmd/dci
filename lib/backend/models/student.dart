import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String studentId;
  final String rollNo;
  final String className;
  final String? gender;
  final String? dob;
  final String? parentName;
  final String? parentPhone;
  final String? address;
  final String? photoUrl;
  final String? section;
  final String? altPhone;
  final String? email;
  final String? admissionDate;
  final String? batch;
  final String? feesStatus;
  final String? notes;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.rollNo,
    required this.className,
    this.gender,
    this.dob,
    this.parentName,
    this.parentPhone,
    this.address,
    this.photoUrl,
    this.section,
    this.altPhone,
    this.email,
    this.admissionDate,
    this.batch,
    this.feesStatus,
    this.notes,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Student(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      studentId: data['student_id']?.toString() ?? '',
      rollNo: data['roll_no']?.toString() ?? '',
      className: data['class']?.toString() ?? '',
      gender: data['gender']?.toString(),
      dob: data['dob']?.toString(),
      parentName: data['parent_name']?.toString(),
      parentPhone: data['parent_phone']?.toString(),
      address: data['address']?.toString(),
      photoUrl: data['photo_url']?.toString(),
      section: data['section']?.toString(),
      altPhone: data['alt_phone']?.toString(),
      email: data['email']?.toString(),
      admissionDate: data['admission_date']?.toString(),
      batch: data['batch']?.toString(),
      feesStatus: data['fees_status']?.toString(),
      notes: data['notes']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'student_id': studentId,
      'roll_no': rollNo,
      'class': className,
      'gender': gender,
      'dob': dob,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'address': address,
      'photo_url': photoUrl,
      'section': section,
      'alt_phone': altPhone,
      'email': email,
      'admission_date': admissionDate,
      'batch': batch,
      'fees_status': feesStatus,
      'notes': notes,
    };
  }
}
