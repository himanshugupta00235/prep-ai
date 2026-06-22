import 'package:flutter/foundation.dart';
import 'package:prep_ai/services/ai_service.dart';

/// ViewModel for the AI Answer feature.
///
/// Manages the generation of AI-powered short and detailed
/// interview answers for a given question.
class AIAnswerViewModel extends ChangeNotifier {
  final AIService _aiService;

  AIAnswerViewModel({required AIService aiService})
      : _aiService = aiService;

  // ─── State ──────────────────────────────────────────────────

  String? _shortAnswer;
  String? get shortAnswer => _shortAnswer;

  String? _interviewAnswer;
  String? get interviewAnswer => _interviewAnswer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Whether an AI answer has been generated for the current question.
  bool get hasAnswer => _shortAnswer != null && _interviewAnswer != null;

  // ─── AI Generation ─────────────────────────────────────────

  /// Generates AI answers for the given question title.
  ///
  /// Produces both a short summary and a detailed interview-ready answer.
  Future<void> generateAnswer(String questionTitle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _aiService.generateAnswer(questionTitle);
      _shortAnswer = result['shortAnswer'];
      _interviewAnswer = result['interviewAnswer'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to generate AI answer. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current AI answer state (used when navigating to a new question).
  void clear() {
    _shortAnswer = null;
    _interviewAnswer = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
