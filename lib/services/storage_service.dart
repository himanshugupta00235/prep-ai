import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service using SharedPreferences.
///
/// Manages persistent login state and other local preferences.
class StorageService {
  SharedPreferences? _prefs;

  // Storage keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Initializes SharedPreferences. Must be called before use.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Auth State ─────────────────────────────────────────────

  /// Saves the login state for persistent sessions.
  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(_isLoggedInKey, value);
  }

  /// Returns whether the user was previously logged in.
  bool isLoggedIn() {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  // ─── Onboarding ─────────────────────────────────────────────

  /// Marks onboarding as completed.
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_onboardingCompleteKey, value);
  }

  /// Returns whether the user has completed onboarding.
  bool isOnboardingComplete() {
    return _prefs?.getBool(_onboardingCompleteKey) ?? false;
  }

  // ─── Clear ──────────────────────────────────────────────────

  /// Clears all local storage data (used on logout).
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
