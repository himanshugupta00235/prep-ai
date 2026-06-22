import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Authentication operations.
///
/// Provides a clean interface for sign-up, sign-in, sign-out,
/// and password reset. All Firebase-specific logic is contained here.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes (user logged in / out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Creates a new user account with email and password.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs in an existing user with email and password.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the specified address.
  ///
  /// Throws [FirebaseAuthException] if the email is not registered.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
