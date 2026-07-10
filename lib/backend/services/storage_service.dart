import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadHomeworkAttachment({
    required Uint8List bytes,
    required String extension,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final fileName = '${const Uuid().v4()}$extension';
      final storageRef = _storage.ref().child('homework/${user.uid}/$fileName');
      
      final uploadTask = await storageRef.putData(bytes);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAttachment(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Log error internally if needed
    }
  }
}
