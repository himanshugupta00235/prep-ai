import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prep_ai/views/auth/login_screen.dart';
import 'package:prep_ai/views/auth/register_screen.dart';
import 'package:prep_ai/views/bookmarks/bookmarks_screen.dart';
import 'package:prep_ai/views/dashboard/dashboard_screen.dart';
import 'package:prep_ai/views/profile/profile_screen.dart';
import 'package:prep_ai/views/questions/question_detail_screen.dart';
import 'package:prep_ai/views/questions/questions_screen.dart';
import 'package:prep_ai/views/splash/splash_screen.dart';

/// Centralized router configuration using go_router.
///
/// Handles auth-based redirects: unauthenticated users are sent to login,
/// authenticated users bypass the auth screens.
class AppRouter {
  AppRouter._();

  // Route path constants for type-safe navigation.
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String questions = '/questions';
  static const String questionDetail = '/questions/:id';
  static const String bookmarks = '/bookmarks';
  static const String profile = '/profile';

  /// Creates the [GoRouter] instance with auth redirects.
  ///
  /// [refreshListenable] triggers route re-evaluation on auth state changes.
  static GoRouter router({required Listenable refreshListenable}) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: refreshListenable,
      redirect: _globalRedirect,
      routes: [
        // ─── Splash ────────────────────────────────────────
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),

        // ─── Auth Routes ──────────────────────────────────
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),

        // ─── Main App Routes ──────────────────────────────
        GoRoute(
          path: home,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: questions,
          builder: (context, state) => const QuestionsScreen(),
        ),
        GoRoute(
          path: questionDetail,
          builder: (context, state) {
            final questionId = state.pathParameters['id'] ?? '';
            return QuestionDetailScreen(questionId: questionId);
          },
        ),
        GoRoute(
          path: bookmarks,
          builder: (context, state) => const BookmarksScreen(),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }

  /// Global redirect logic for auth-based navigation.
  ///
  /// - Splash screen is always accessible (handles initial routing).
  /// - Unauthenticated users are redirected to login.
  /// - Authenticated users trying to access login/register go to home.
  static String? _globalRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final currentPath = state.matchedLocation;

    // Allow splash screen to handle its own routing
    if (currentPath == splash) return null;

    // Auth pages — redirect logged-in users to home
    final isAuthPage = currentPath == login || currentPath == register;
    if (isLoggedIn && isAuthPage) return home;

    // Protected pages — redirect unauthenticated users to login
    if (!isLoggedIn && !isAuthPage) return login;

    return null; // No redirect needed
  }
}
