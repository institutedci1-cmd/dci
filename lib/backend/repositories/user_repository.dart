import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class UserRepository {
  UserRepository(
      {FirebaseFirestore? firestore,
      FirebaseAuth? auth,
      FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Stream<Map<String, dynamic>?> getUserStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateProfile({
    required String displayName,
    required String designation,
    required String phoneNumber,
    required String qualification,
    required String subjectExpertise,
    String? experience,
    String? employeeId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = {
      'display_name': displayName,
      'designation': designation,
      'phone_number': phoneNumber,
      'qualification': qualification,
      'subject_expertise': subjectExpertise,
    };

    if (experience != null) data['experience'] = experience;
    if (employeeId != null) data['employee_id'] = employeeId;

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'notifications_enabled': enabled});
    
    if (!enabled) {
      // If disabled, we might want to remove the FCM token from the record
      // to stop sending notifications.
      await _firestore.collection('users').doc(user.uid).update({
        'fcm_token': FieldValue.delete(),
      });
    } else {
      // If re-enabled, we should re-trigger token fetch
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcm_token': token,
        });
      }
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'photo_url': photoUrl});
    await user.updatePhotoURL(photoUrl);
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final storageRef = _storage.ref().child('users/${user.uid}/profile_photo.jpg');
      
      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);
      
      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      // Update the user profile with the new URL
      await updatePhotoUrl(downloadUrl);
      
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
