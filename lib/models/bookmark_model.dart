import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a bookmarked question for a user.
///
/// Stored in the `bookmarks` Firestore collection.
/// Links a user to a question they want to save for later review.
class BookmarkModel {
  final String id;
  final String userId;
  final String questionId;
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.createdAt,
  });

  /// Creates a [BookmarkModel] from a Firestore document snapshot.
  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookmarkModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      questionId: data['questionId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'questionId': questionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
