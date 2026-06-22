import 'package:flutter/foundation.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/repositories/auth_repository.dart';
import 'package:prep_ai/repositories/bookmark_repository.dart';

/// ViewModel for the Bookmarks screen and bookmark toggle functionality.
///
/// Manages the list of bookmarked questions and tracks which question IDs
/// are currently bookmarked for instant UI feedback.
class BookmarkViewModel extends ChangeNotifier {
  final BookmarkRepository _bookmarkRepository;
  final AuthRepository _authRepository;

  BookmarkViewModel({
    required BookmarkRepository bookmarkRepository,
    required AuthRepository authRepository,
  })  : _bookmarkRepository = bookmarkRepository,
        _authRepository = authRepository;

  // ─── State ──────────────────────────────────────────────────

  List<QuestionModel> _bookmarkedQuestions = [];
  List<QuestionModel> get bookmarkedQuestions => _bookmarkedQuestions;

  /// Set of bookmarked question IDs for O(1) lookup in the UI.
  final Set<String> _bookmarkedIds = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Data Loading ───────────────────────────────────────────

  /// Loads all bookmarked questions for the current user.
  Future<void> loadBookmarks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      _bookmarkedQuestions =
          await _bookmarkRepository.getBookmarkedQuestions(uid);

      // Build the ID set for fast lookups
      _bookmarkedIds.clear();
      for (final q in _bookmarkedQuestions) {
        _bookmarkedIds.add(q.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load bookmarks. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Bookmark Toggle ───────────────────────────────────────

  /// Toggles bookmark status for a question.
  ///
  /// Updates the local state immediately for responsive UI,
  /// then syncs with Firestore.
  Future<void> toggleBookmark(String questionId) async {
    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Optimistic UI update
      if (_bookmarkedIds.contains(questionId)) {
        _bookmarkedIds.remove(questionId);
        _bookmarkedQuestions.removeWhere((q) => q.id == questionId);
      } else {
        _bookmarkedIds.add(questionId);
      }
      notifyListeners();

      // Sync with Firestore
      await _bookmarkRepository.toggleBookmark(uid, questionId);
    } catch (e) {
      // Revert optimistic update on error
      await loadBookmarks();
    }
  }

  /// Returns whether a question is currently bookmarked.
  bool isBookmarked(String questionId) {
    return _bookmarkedIds.contains(questionId);
  }
}
