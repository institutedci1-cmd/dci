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

  Future<String> getNextEmployeeId() async {
    final counterRef = _firestore.collection('config').doc('user_counters');
    
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      
      int nextIndex = 1;
      if (snapshot.exists) {
        nextIndex = (snapshot.data()?['last_index'] as int? ?? 0) + 1;
      }
      
      transaction.set(counterRef, {'last_index': nextIndex}, SetOptions(merge: true));
      
      final year = DateTime.now().year;
      final formattedIndex = nextIndex.toString().padLeft(3, '0');
      return 'DESHMUKH-$year-$formattedIndex';
    });
  }

  Future<void> updateInstituteInfo(Map<String, dynamic> data) async {
    await _firestore.collection('config').doc('institute_info').set(data, SetOptions(merge: true));
  }

  Future<void> addSubject(String name) async {
    await _firestore.collection('subjects').add({'name': name, 'created_at': FieldValue.serverTimestamp()});
  }

  Future<void> deleteSubject(String name) async {
    final snapshot = await _firestore.collection('subjects').where('name', isEqualTo: name).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
