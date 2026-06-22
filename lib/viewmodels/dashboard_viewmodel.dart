import 'package:flutter/foundation.dart';
import 'package:prep_ai/core/utils/helpers.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/models/user_model.dart';
import 'package:prep_ai/repositories/auth_repository.dart';
import 'package:prep_ai/repositories/bookmark_repository.dart';
import 'package:prep_ai/repositories/question_repository.dart';
import 'package:prep_ai/repositories/user_repository.dart';

/// ViewModel for the Dashboard screen.
///
/// Aggregates user profile, progress stats, recent questions,
/// and bookmark count into a single view state.
class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final QuestionRepository _questionRepository;
  final BookmarkRepository _bookmarkRepository;
  final AuthRepository _authRepository;

  DashboardViewModel({
    required UserRepository userRepository,
    required QuestionRepository questionRepository,
    required BookmarkRepository bookmarkRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
        _questionRepository = questionRepository,
        _bookmarkRepository = bookmarkRepository,
        _authRepository = authRepository;

  // ─── State ──────────────────────────────────────────────────

  UserModel? _user;
  UserModel? get user => _user;

  List<QuestionModel> _recentQuestions = [];
  List<QuestionModel> get recentQuestions => _recentQuestions;

  int _bookmarkCount = 0;
  int get bookmarkCount => _bookmarkCount;

  int _totalQuestions = 0;
  int get totalQuestions => _totalQuestions;

  double _progressPercentage = 0.0;
  double get progressPercentage => _progressPercentage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Computed Properties ────────────────────────────────────

  /// Time-based greeting with user's first name.
  String get greeting {
    final name = _user != null
        ? Helpers.getFirstName(_user!.name)
        : 'there';
    return '${Helpers.getGreeting()}, $name!';
  }

  // ─── Data Loading ───────────────────────────────────────────

  /// Loads all dashboard data: user profile, questions, bookmarks.
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Load data in parallel for better performance
      final results = await Future.wait([
        _userRepository.getUser(uid),
        _questionRepository.getQuestions(),
        _bookmarkRepository.getBookmarkCount(uid),
        _questionRepository.getTotalCount(),
      ]);

      _user = results[0] as UserModel?;
      _recentQuestions = (results[1] as List<QuestionModel>).take(5).toList();
      _bookmarkCount = results[2] as int;
      _totalQuestions = results[3] as int;

      // Calculate progress as percentage of bookmarked vs total questions
      _progressPercentage = _totalQuestions > 0
          ? _bookmarkCount / _totalQuestions
          : 0.0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
