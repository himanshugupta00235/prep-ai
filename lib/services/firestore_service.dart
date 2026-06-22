import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prep_ai/models/user_model.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/models/bookmark_model.dart';

/// Handles all Firestore database operations.
///
/// Provides CRUD operations for users, questions, and bookmarks collections.
/// This service is the single point of contact with Cloud Firestore.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Collection References ──────────────────────────────────

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _questionsCollection =>
      _firestore.collection('questions');
  CollectionReference get _bookmarksCollection =>
      _firestore.collection('bookmarks');

  // ─── User Operations ───────────────────────────────────────

  /// Creates a new user document in Firestore.
  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toFirestore());
  }

  /// Retrieves a user by their UID. Returns null if not found.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Updates specific fields on a user document.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  // ─── Question Operations ───────────────────────────────────

  /// Fetches all interview questions from Firestore.
  Future<List<QuestionModel>> getQuestions() async {
    final snapshot = await _questionsCollection.get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches a single question by its ID. Returns null if not found.
  Future<QuestionModel?> getQuestion(String id) async {
    final doc = await _questionsCollection.doc(id).get();
    if (!doc.exists) return null;
    return QuestionModel.fromFirestore(doc);
  }

  // ─── Bookmark Operations ───────────────────────────────────

  /// Adds a bookmark to Firestore.
  Future<void> addBookmark(BookmarkModel bookmark) async {
    await _bookmarksCollection.add(bookmark.toFirestore());
  }

  /// Removes a bookmark by its document ID.
  Future<void> removeBookmark(String bookmarkId) async {
    await _bookmarksCollection.doc(bookmarkId).delete();
  }

  /// Fetches all bookmarks for a specific user.
  Future<List<BookmarkModel>> getUserBookmarks(String userId) async {
    final snapshot = await _bookmarksCollection
        .where('userId', isEqualTo: userId)
        .get();
    
    final bookmarks = snapshot.docs
        .map((doc) => BookmarkModel.fromFirestore(doc))
        .toList();
        
    // Sort in-memory by createdAt descending to avoid composite index requirements
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookmarks;
  }

  /// Checks if a specific question is bookmarked by a user.
  ///
  /// Returns the bookmark document ID if found, null otherwise.
  Future<String?> getBookmarkId(String userId, String questionId) async {
    final snapshot = await _bookmarksCollection
        .where('userId', isEqualTo: userId)
        .where('questionId', isEqualTo: questionId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }
}
