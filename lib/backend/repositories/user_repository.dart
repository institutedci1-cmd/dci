import 'package:d_c_i_teacher_app/backend/repositories/interfaces/i_user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/repositories/config_repository.dart';

class UserRepository implements IUserRepository {
  UserRepository(
      {FirebaseFirestore? firestore,
      FirebaseAuth? auth,
      FirebaseStorage? storage,
      ConfigRepository? configRepository})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _configRepository = configRepository ?? ConfigRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final ConfigRepository _configRepository;

  @override
  Stream<Teacher?> getUserStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return getUserStreamById(user.uid);
  }

  @override
  Stream<Teacher?> getUserStreamById(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Teacher.fromFirestore(doc) : null);
  }

  @override
  @override
  Future<Teacher?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? Teacher.fromFirestore(doc) : null;
  }

  @override
  Future<Teacher?> getUserDataById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? Teacher.fromFirestore(doc) : null;
  }

  Future<String> getUserRole() async {
    final teacher = await getUserData();
    return teacher?.role ?? 'Teacher';
  }

  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'Admin';
  }

  Future<bool> isDirector() async {
    final role = await getUserRole();
    return role == 'Director';
  }

  Future<bool> isStaff() async {
    final role = await getUserRole();
    return ['Admin', 'Director', 'Teacher'].contains(role);
  }

  @override
  @override
  Future<void> updateProfile(Teacher user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> toggleNotifications(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'notifications_enabled': enabled});
    
    if (!enabled) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcm_token': FieldValue.delete(),
      });
    } else {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await saveFCMToken(token);
      }
    }
  }

  @override
  Future<void> saveFCMToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcm_token': token,
    });
  }

  Future<void> updatePhotoUrl(String photoUrl, {String? targetUid}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = targetUid ?? user.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .update({'photo_url': photoUrl});

    // Only update auth profile if it's the current user
    if (uid == user.uid) {
      await user.updatePhotoURL(photoUrl);
    }
  }

  @override
  Future<String> uploadProfilePicture(File imageFile, {String? targetUid}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final uid = targetUid ?? user.uid;

    final storageRef = _storage.ref().child('users/$uid/profile_photo.jpg');
    
    // Upload the file
    final uploadTask = await storageRef.putFile(imageFile);
    
    // Get the download URL
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    // Update the user profile with the new URL
    await updatePhotoUrl(downloadUrl, targetUid: targetUid);
    
    return downloadUrl;
  }

  Future<void> createNewUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String designation,
    required String phoneNumber,
    String? employeeId,
    required String subjectExpertise,
  }) async {
    final emailLower = email.trim().toLowerCase();

    // 0. Handle Employee ID generation
    String finalEmployeeId = employeeId?.trim() ?? '';
    if (finalEmployeeId.isEmpty) {
      finalEmployeeId = await _configRepository.getNextEmployeeId();
    }

    // 1. Check if user already exists in Firestore
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: emailLower)
        .get();

    DocumentSnapshot? existingDoc;
    String? existingUid;

    if (query.docs.isNotEmpty) {
      existingDoc = query.docs.first;
      final data = existingDoc.data() as Map<String, dynamic>?;
      existingUid = data?['uid'];
    }

    // 2. Handle Authentication
    String uid;
    if (existingUid != null) {
      uid = existingUid;
    } else {
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      try {
        final credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: emailLower,
          password: password,
        );
        uid = credential.user!.uid;
        await secondaryAuth.signOut();
        await secondaryApp.delete();
      } on FirebaseAuthException catch (_) {
        await secondaryApp.delete();
        rethrow;
      } catch (e) {
        await secondaryApp.delete();
        rethrow;
      }
    }

    // 3. Update or Create Firestore record
    final userData = {
      'uid': uid,
      'email': emailLower,
      'display_name': displayName,
      'role': role,
      'designation': designation,
      'phone_number': phoneNumber,
      'employee_id': finalEmployeeId,
      'subject_expertise': subjectExpertise,
      'updated_time': FieldValue.serverTimestamp(),
      'notifications_enabled': true,
      'is_pre_provisioned': false,
    };

    if (existingDoc == null) {
      userData['created_time'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).set(userData);
    } else {
      if (existingDoc.id != uid) {
        await _firestore.collection('users').doc(uid).set(userData);
        await existingDoc.reference.delete();
      } else {
        await _firestore.collection('users').doc(uid).update(userData);
      }
    }
  }

  @override
  @override
  Future<List<Teacher>> getTeachers() async {
    final query = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Teacher')
        .get();

    return query.docs.map((doc) => Teacher.fromFirestore(doc)).toList();
  }

  @override
  Stream<List<Teacher>> getAllUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('display_name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Teacher.fromFirestore(doc)).toList());
  }

  @override
  @override
  Future<List<String>> getAllUserSubjects() async {
    final query = await _firestore.collection('users').get();
    return query.docs
        .map((doc) => doc.data()['subject_expertise'] as String?)
        .where((s) => s != null && s.isNotEmpty)
        .expand((s) => s!.split(',').map((e) => e.trim()))
        .toSet()
        .toList();
  }

  Future<Teacher?> findUserByEmail(String email) async {
    final emailLower = email.trim().toLowerCase();
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: emailLower)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return Teacher.fromFirestore(query.docs.first);
  }
}
