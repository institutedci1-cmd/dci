import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:d_c_i_teacher_app/auth/firebase_auth/firebase_auth_manager.dart';

export 'package:d_c_i_teacher_app/auth/firebase_auth/firebase_auth_manager.dart';

final _authManager = FirebaseAuthManager();
FirebaseAuthManager get authManager => _authManager;

String get currentUserEmail =>
    currentUser?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';

String get currentUserUid =>
    currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

String get currentUserDisplayName =>
    currentUser?.displayName ??
    FirebaseAuth.instance.currentUser?.displayName ??
    '';

String get currentUserPhoto =>
    currentUser?.photoUrl ?? FirebaseAuth.instance.currentUser?.photoURL ?? '';

String get currentPhoneNumber =>
    currentUser?.phoneNumber ??
    FirebaseAuth.instance.currentUser?.phoneNumber ??
    '';

String get currentJwtToken => _currentJwtToken ?? '';

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

/// Create a Stream that listens to the current user's JWT Token, since Firebase
/// generates a new token every hour.
String? _currentJwtToken;
final jwtTokenStream = FirebaseAuth.instance
    .idTokenChanges()
    .asyncMap((user) async => _currentJwtToken = await user?.getIdToken())
    .asBroadcastStream();

Future maybeCreateUser(BaseAuthUser user) async {
  final uid = user.uid;
  if (uid == null || uid.isEmpty) {
    return;
  }
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!userDoc.exists) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'display_name': user.displayName,
      'photo_url': user.photoUrl,
      'uid': user.uid,
      'created_time': FieldValue.serverTimestamp(),
    });
  }
}
