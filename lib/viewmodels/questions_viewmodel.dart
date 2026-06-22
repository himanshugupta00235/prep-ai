import 'package:flutter/foundation.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/repositories/question_repository.dart';

/// ViewModel for the Questions screen.
///
/// Manages question list, search, category filtering, and difficulty filtering.
/// All filtering is done client-side on cached data for instant UX.
class QuestionsViewModel extends ChangeNotifier {
  final QuestionRepository _questionRepository;

  QuestionsViewModel({required QuestionRepository questionRepository})
      : _questionRepository = questionRepository;

  // ─── State ──────────────────────────────────────────────────

  List<QuestionModel> _allQuestions = [];
  List<QuestionModel> _filteredQuestions = [];
  List<QuestionModel> get questions => _filteredQuestions;

  QuestionCategory? _selectedCategory;
  QuestionCategory? get selectedCategory => _selectedCategory;

  DifficultyLevel? _selectedDifficulty;
  DifficultyLevel? get selectedDifficulty => _selectedDifficulty;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Data Loading ───────────────────────────────────────────

  /// Fetches all questions from the repository and applies current filters.
  Future<void> loadQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allQuestions = await _questionRepository.getQuestions();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load questions. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches a single question by its Firestore document ID.
  Future<QuestionModel?> getQuestion(String id) async {
    return await _questionRepository.getQuestion(id);
  }

  // ─── Filtering ──────────────────────────────────────────────

  /// Filters questions by category. Pass null to show all categories.
  void filterByCategory(QuestionCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Filters questions by difficulty. Pass null to show all difficulties.
  void filterByDifficulty(DifficultyLevel? difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
    notifyListeners();
  }

  /// Filters questions by search text (title match, case-insensitive).
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Resets all filters and shows the full question list.
  void clearFilters() {
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = '';
    _filteredQuestions = List.from(_allQuestions);
    notifyListeners();
  }

  /// Applies all active filters to the full question list.
  void _applyFilters() {
    var results = List<QuestionModel>.from(_allQuestions);

    // Category filter
    if (_selectedCategory != null) {
      results = results.where((q) => q.category == _selectedCategory).toList();
    }

    // Difficulty filter
    if (_selectedDifficulty != null) {
      results =
          results.where((q) => q.difficulty == _selectedDifficulty).toList();
    }

    // Text search
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results =
          results.where((q) => q.title.toLowerCase().contains(query)).toList();
    }

    _filteredQuestions = results;
  }
}
