import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _googleServerClientId =
    '185309718906-63gicrep1c71b79fercl1acvkqkepivp.apps.googleusercontent.com';

final _googleSignIn = GoogleSignIn(
  scopes: ['profile', 'email'],
  serverClientId: kIsWeb ? null : _googleServerClientId,
);

Future<UserCredential?> googleSignInFunc() async {
  if (kIsWeb) {
    return FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }

  try {
    await signOutWithGoogle().catchError((_) => null);
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    final accessToken = auth.accessToken;

    if (idToken == null || accessToken == null) {
      throw FirebaseAuthException(
        code: 'google-signin-missing-token',
        message:
            'Google sign-in did not return the required authentication tokens.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  } on FirebaseAuthException {
    rethrow;
  } catch (e) {
    throw FirebaseAuthException(
      code: 'google-signin-failed',
      message: e.toString(),
    );
  }
}

Future signOutWithGoogle() => _googleSignIn.signOut();
