import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigRepository {
  ConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getDashboardConfig() async {
    final doc = await _firestore.collection('config').doc('dashboard_config').get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> getInstituteInfo() async {
    final doc = await _firestore.collection('config').doc('institute_info').get();
    return doc.data();
  }

  Stream<Map<String, dynamic>?> getInstituteInfoStream() {
    return _firestore
        .collection('config')
        .doc('institute_info')
        .snapshots()
        .map((doc) => doc.data());
  }

  Stream<List<String>> getSubjectsStream() {
    return _firestore
        .collection('subjects')
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => doc.data()['name'] as String? ?? '')
                .where((name) => name.isNotEmpty)
                .toList()..sort();
          } catch (e) {
            return [];
          }
        });
  }
}
