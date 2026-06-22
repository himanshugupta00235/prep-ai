import 'package:prep_ai/models/bookmark_model.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/services/firestore_service.dart';

/// Manages bookmark operations between users and questions.
///
/// Handles toggling bookmarks (add/remove), fetching bookmarked questions,
/// and checking bookmark status.
class BookmarkRepository {
  final FirestoreService _firestoreService;

  BookmarkRepository({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  /// Toggles a bookmark: adds if not bookmarked, removes if already bookmarked.
  ///
  /// Returns true if bookmarked, false if unbookmarked.
  Future<bool> toggleBookmark(String userId, String questionId) async {
    final existingId = await _firestoreService.getBookmarkId(
      userId,
      questionId,
    );

    if (existingId != null) {
      // Already bookmarked — remove it
      await _firestoreService.removeBookmark(existingId);
      return false;
    } else {
      // Not bookmarked — add it
      final bookmark = BookmarkModel(
        id: '', // Firestore auto-generates the ID
        userId: userId,
        questionId: questionId,
        createdAt: DateTime.now(),
      );
      await _firestoreService.addBookmark(bookmark);
      return true;
    }
  }

  /// Fetches all questions that the user has bookmarked.
  ///
  /// Joins bookmark records with their corresponding question data.
  Future<List<QuestionModel>> getBookmarkedQuestions(String userId) async {
    final bookmarks = await _firestoreService.getUserBookmarks(userId);
    final questions = <QuestionModel>[];

    for (final bookmark in bookmarks) {
      final question = await _firestoreService.getQuestion(
        bookmark.questionId,
      );
      if (question != null) {
        questions.add(question);
      }
    }

    return questions;
  }

  /// Checks whether a specific question is bookmarked by the user.
  Future<bool> isBookmarked(String userId, String questionId) async {
    final id = await _firestoreService.getBookmarkId(userId, questionId);
    return id != null;
  }

  /// Returns the total number of bookmarks for a user.
  Future<int> getBookmarkCount(String userId) async {
    final bookmarks = await _firestoreService.getUserBookmarks(userId);
    return bookmarks.length;
  }
}
