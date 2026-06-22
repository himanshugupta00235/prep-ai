import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:prep_ai/core/utils/helpers.dart';
import 'package:prep_ai/repositories/auth_repository.dart';

/// ViewModel for authentication screens (Login, Register, Forgot Password).
///
/// Manages form state, validation, loading indicators, and error messages.
/// Delegates actual auth operations to [AuthRepository].
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ─── State ──────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Auth Operations ────────────────────────────────────────

  /// Registers a new user. Returns true on success.
  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signUp(name, email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(Helpers.getFirebaseAuthErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Signs in an existing user. Returns true on success.
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signIn(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(Helpers.getFirebaseAuthErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Sends a password reset email. Returns true on success.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.resetPassword(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(Helpers.getFirebaseAuthErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────

  /// Clears the current error message.
  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
