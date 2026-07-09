import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCknvyWpsKdjc9pkyWJSH_6SYU_bG1WuDc", // Updated from google-services.json
            authDomain: "d-c-i-teacher-app-lffjyu.firebaseapp.com",
            projectId: "d-c-i-teacher-app-lffjyu",
            storageBucket: "d-c-i-teacher-app-lffjyu.firebasestorage.app",
            messagingSenderId: "185309718906",
            appId: "1:185309718906:web:0604745cd0588aa56d8ec3"));
  } else {
    await Firebase.initializeApp();
  }

  // Configure Firestore persistence
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  } else {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
