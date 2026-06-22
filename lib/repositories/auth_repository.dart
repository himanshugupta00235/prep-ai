import 'package:firebase_auth/firebase_auth.dart';
import 'package:prep_ai/models/user_model.dart';
import 'package:prep_ai/services/auth_service.dart';
import 'package:prep_ai/services/firestore_service.dart';
import 'package:prep_ai/services/storage_service.dart';

/// Coordinates authentication flow across Auth, Firestore, and local storage.
///
/// On sign-up: creates Firebase Auth account + Firestore user document.
/// On sign-in: authenticates + persists login state locally.
/// On sign-out: clears auth + local storage.
class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _storageService = storageService;

  /// Stream of auth state changes for reactive UI updates.
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// The currently signed-in user, or null.
  User? get currentUser => _authService.currentUser;

  /// Registers a new user: creates Auth account + Firestore profile.
  Future<void> signUp(String name, String email, String password) async {
    final credential = await _authService.signUpWithEmail(email, password);
    final user = credential.user;
    if (user == null) throw Exception('User creation failed');

    // Create user document in Firestore
    final userModel = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );
    await _firestoreService.createUser(userModel);

    // Persist login state
    await _storageService.setLoggedIn(true);
  }

  /// Signs in an existing user and persists login state.
  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmail(email, password);
    await _storageService.setLoggedIn(true);
  }

  /// Signs out the user and clears local storage.
  Future<void> signOut() async {
    await _authService.signOut();
    await _storageService.clear();
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
