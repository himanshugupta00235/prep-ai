import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/services/firestore_service.dart';

/// Manages interview question data with caching and filtering.
///
/// Caches questions after first fetch to reduce Firestore reads.
/// Supports filtering by category, difficulty, and text search.
class QuestionRepository {
  final FirestoreService _firestoreService;

  /// In-memory cache to avoid repeated Firestore reads.
  List<QuestionModel>? _cachedQuestions;

  QuestionRepository({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  /// Fetches questions with optional filtering.
  ///
  /// Uses cached data if available. Filters are applied client-side
  /// for simplicity (Firestore doesn't support full-text search).
  Future<List<QuestionModel>> getQuestions({
    QuestionCategory? category,
    DifficultyLevel? difficulty,
    String? searchQuery,
  }) async {
    // Fetch from Firestore if not cached
    _cachedQuestions ??= await _firestoreService.getQuestions();

    var results = List<QuestionModel>.from(_cachedQuestions!);

    // Apply category filter
    if (category != null) {
      results = results.where((q) => q.category == category).toList();
    }

    // Apply difficulty filter
    if (difficulty != null) {
      results = results.where((q) => q.difficulty == difficulty).toList();
    }

    // Apply text search (case-insensitive title match)
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      results = results
          .where((q) => q.title.toLowerCase().contains(query))
          .toList();
    }

    return results;
  }

  /// Fetches a single question by ID.
  Future<QuestionModel?> getQuestion(String id) async {
    // Check cache first
    if (_cachedQuestions != null) {
      try {
        return _cachedQuestions!.firstWhere((q) => q.id == id);
      } catch (_) {
        // Not in cache, fetch from Firestore
      }
    }
    return await _firestoreService.getQuestion(id);
  }

  /// Returns the total count of available questions.
  Future<int> getTotalCount() async {
    _cachedQuestions ??= await _firestoreService.getQuestions();
    return _cachedQuestions!.length;
  }

  /// Clears the in-memory cache to force a fresh Firestore read.
  void clearCache() {
    _cachedQuestions = null;
  }
}
