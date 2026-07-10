import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _announcementsCollection => _firestore.collection('announcements');

  Stream<List<Announcement>> getAnnouncementsStream() {
    return _announcementsCollection
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final announcements = snapshot.docs
              .map((doc) => Announcement.fromFirestore(doc))
              .toList();
          // Manual sort
          announcements.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          return announcements;
        });
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

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    if (id.isEmpty) return;
    await _announcementsCollection.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(String id) async {
    if (id.isEmpty) return;
    await _announcementsCollection.doc(id).delete();
  }
}
