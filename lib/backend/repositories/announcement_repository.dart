import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_c_i_teacher_app/backend/models/announcement.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _announcementsCollection => _firestore.collection('announcements');

  Stream<List<Announcement>> getAnnouncementsStream() {
    return _announcementsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromFirestore(doc))
            .toList());
  }

  Future<void> createAnnouncement({
    required String title,
    required String description,
    required String category,
    String? link,
  }) async {
    await _announcementsCollection.add({
      'title': title,
      'description': description,
      'category': category,
      'link': link,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
