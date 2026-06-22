import 'package:flutter/material.dart';
import 'package:prep_ai/core/constants/app_theme.dart';
import 'package:prep_ai/core/routes/app_router.dart';

/// Root widget for the PrepAI application.
///
/// Configures MaterialApp.router with the app theme and go_router instance.
class PrepAIApp extends StatelessWidget {
  final Listenable authNotifier;

  const PrepAIApp({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router(refreshListenable: authNotifier);

    return MaterialApp.router(
      title: 'PrepAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
