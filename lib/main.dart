import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prep_ai/app.dart';
import 'package:prep_ai/services/auth_service.dart';
import 'package:prep_ai/services/firestore_service.dart';
import 'package:prep_ai/services/ai_service.dart';
import 'package:prep_ai/services/storage_service.dart';
import 'package:prep_ai/repositories/auth_repository.dart';
import 'package:prep_ai/repositories/question_repository.dart';
import 'package:prep_ai/repositories/bookmark_repository.dart';
import 'package:prep_ai/repositories/user_repository.dart';
import 'package:prep_ai/viewmodels/auth_viewmodel.dart';
import 'package:prep_ai/viewmodels/dashboard_viewmodel.dart';
import 'package:prep_ai/viewmodels/questions_viewmodel.dart';
import 'package:prep_ai/viewmodels/bookmark_viewmodel.dart';
import 'package:prep_ai/viewmodels/ai_answer_viewmodel.dart';
import 'package:prep_ai/viewmodels/profile_viewmodel.dart';
// TODO: Import firebase_options.dart after running `flutterfire configure`
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local storage
  final storageService = StorageService();
  await storageService.init();

  // Create service instances
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final aiService = AIService();

  // Create repository instances (depend on services)
  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
    storageService: storageService,
  );
  final questionRepository = QuestionRepository(
    firestoreService: firestoreService,
  );
  final bookmarkRepository = BookmarkRepository(
    firestoreService: firestoreService,
  );
  final userRepository = UserRepository(
    firestoreService: firestoreService,
  );

  // Auth state notifier for go_router refresh
  final authNotifier = _AuthNotifier(FirebaseAuth.instance);

  runApp(
    /// MultiProvider sets up dependency injection for the entire widget tree.
    /// ViewModels receive their required repositories through constructors.
    MultiProvider(
      providers: [
        // ─── ViewModels ─────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            userRepository: userRepository,
            questionRepository: questionRepository,
            bookmarkRepository: bookmarkRepository,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => QuestionsViewModel(
            questionRepository: questionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarkViewModel(
            bookmarkRepository: bookmarkRepository,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AIAnswerViewModel(aiService: aiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            userRepository: userRepository,
            authRepository: authRepository,
            bookmarkRepository: bookmarkRepository,
            questionRepository: questionRepository,
          ),
        ),
      ],
      child: PrepAIApp(authNotifier: authNotifier),
    ),
  );
}

/// Listens to Firebase Auth state changes and notifies go_router
/// to re-evaluate its redirect logic.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(FirebaseAuth auth) {
    auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}
