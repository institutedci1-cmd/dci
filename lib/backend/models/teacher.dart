import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String role;
  final String designation;
  final String phoneNumber;
  final String? employeeId;
  final String? subjectExpertise;
  final String? qualification;
  final String? experience;
  final DateTime? createdTime;
  final bool notificationsEnabled;

  Teacher({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.role,
    required this.designation,
    required this.phoneNumber,
    this.employeeId,
    this.subjectExpertise,
    this.qualification,
    this.experience,
    this.createdTime,
    this.notificationsEnabled = true,
  });

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Teacher(
      uid: doc.id,
      email: data['email']?.toString() ?? '',
      displayName: data['display_name']?.toString() ?? '',
      photoUrl: data['photo_url']?.toString() ?? '',
      role: data['role']?.toString() ?? 'Teacher',
      designation: data['designation']?.toString() ?? '',
      phoneNumber: data['phone_number']?.toString() ?? '',
      employeeId: data['employee_id']?.toString(),
      subjectExpertise: data['subject_expertise']?.toString(),
      qualification: data['qualification']?.toString(),
      experience: data['experience']?.toString(),
      createdTime: (data['created_time'] as Timestamp?)?.toDate(),
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'role': role,
      'designation': designation,
      'phone_number': phoneNumber,
      'employee_id': employeeId,
      'subject_expertise': subjectExpertise,
      'qualification': qualification,
      'experience': experience,
      'created_time': createdTime != null ? Timestamp.fromDate(createdTime!) : FieldValue.serverTimestamp(),
      'notifications_enabled': notificationsEnabled,
    };
  }

  Teacher copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    String? designation,
    String? phoneNumber,
    String? employeeId,
    String? subjectExpertise,
    String? qualification,
    String? experience,
    DateTime? createdTime,
    bool? notificationsEnabled,
  }) {
    return Teacher(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      employeeId: employeeId ?? this.employeeId,
      subjectExpertise: subjectExpertise ?? this.subjectExpertise,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      createdTime: createdTime ?? this.createdTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
