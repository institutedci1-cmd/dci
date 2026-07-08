import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_util.dart';

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
  final String? villageCity;
  final String? pinCode;
  final List<String>? subjects;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.rollNo,
    required String className,
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
    this.villageCity,
    this.pinCode,
    this.subjects,
  }) : className = normalizeClassName(className);

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
      villageCity: data['village_city']?.toString(),
      pinCode: data['pin_code']?.toString(),
      subjects: data['subjects'] is List
          ? List<String>.from(data['subjects'])
          : (data['subjects']?.toString().split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()),
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
      'village_city': villageCity,
      'pin_code': pinCode,
      'subjects': subjects,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? studentId,
    String? rollNo,
    String? className,
    String? gender,
    String? dob,
    String? parentName,
    String? parentPhone,
    String? address,
    String? photoUrl,
    String? section,
    String? altPhone,
    String? email,
    String? admissionDate,
    String? batch,
    String? feesStatus,
    String? notes,
    String? villageCity,
    String? pinCode,
    List<String>? subjects,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      section: section ?? this.section,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      admissionDate: admissionDate ?? this.admissionDate,
      batch: batch ?? this.batch,
      feesStatus: feesStatus ?? this.feesStatus,
      notes: notes ?? this.notes,
      villageCity: villageCity ?? this.villageCity,
      pinCode: pinCode ?? this.pinCode,
      subjects: subjects ?? this.subjects,
    );
  }
}
