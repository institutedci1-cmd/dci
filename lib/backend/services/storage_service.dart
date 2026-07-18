import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadHomeworkAttachment(File file) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final extension = p.extension(file.path);
      final fileName = '${const Uuid().v4()}$extension';
      final storageRef = _storage.ref().child('homework/${user.uid}/$fileName');
      
      final uploadTask = await storageRef.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading homework attachment: $e');
      return null;
    }
  }

  Future<void> deleteAttachment(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
    }
  }
}
