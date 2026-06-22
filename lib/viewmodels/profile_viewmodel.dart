import 'package:flutter/foundation.dart';
import 'package:prep_ai/models/user_model.dart';
import 'package:prep_ai/repositories/auth_repository.dart';
import 'package:prep_ai/repositories/bookmark_repository.dart';
import 'package:prep_ai/repositories/question_repository.dart';
import 'package:prep_ai/repositories/user_repository.dart';

/// ViewModel for the Profile screen.
///
/// Displays user info, preparation stats, and handles
/// profile updates like changing the target company.
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final BookmarkRepository _bookmarkRepository;
  final QuestionRepository _questionRepository;

  ProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required BookmarkRepository bookmarkRepository,
    required QuestionRepository questionRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository,
        _bookmarkRepository = bookmarkRepository,
        _questionRepository = questionRepository;

  // ─── State ──────────────────────────────────────────────────

  UserModel? _user;
  UserModel? get user => _user;

  int _totalQuestions = 0;
  int get totalQuestions => _totalQuestions;

  int _bookmarkedCount = 0;
  int get bookmarkedCount => _bookmarkedCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Data Loading ───────────────────────────────────────────

  /// Loads user profile and preparation statistics.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Load all profile data in parallel
      final results = await Future.wait([
        _userRepository.getUser(uid),
        _questionRepository.getTotalCount(),
        _bookmarkRepository.getBookmarkCount(uid),
      ]);

      _user = results[0] as UserModel?;
      _totalQuestions = results[1] as int;
      _bookmarkedCount = results[2] as int;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Profile Updates ───────────────────────────────────────

  /// Updates the user's target company.
  Future<bool> updateTargetCompany(String company) async {
    _isSaving = true;
    notifyListeners();

    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _userRepository.updateTargetCompany(uid, company.trim());
      _user = _user?.copyWith(targetCompany: company.trim());

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
