import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD-TJTrUG64w5dWhUbTOBTBkM2se6VcHxE",
            authDomain: "d-c-i-teacher-app-lffjyu.firebaseapp.com",
            projectId: "d-c-i-teacher-app-lffjyu",
            storageBucket: "d-c-i-teacher-app-lffjyu.firebasestorage.app",
            messagingSenderId: "185309718906",
            appId: "1:185309718906:web:0604745cd0588aa56d8ec3"));
  } else {
    await Firebase.initializeApp();
  }
}
