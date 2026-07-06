import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? link;
  final DateTime? createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.link,
    this.createdAt,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'GENERAL',
      link: data['link'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
