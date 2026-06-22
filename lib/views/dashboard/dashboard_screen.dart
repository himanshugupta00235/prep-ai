import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prep_ai/core/constants/app_colors.dart';
import 'package:prep_ai/core/constants/app_strings.dart';
import 'package:prep_ai/viewmodels/bookmark_viewmodel.dart';
import 'package:prep_ai/viewmodels/dashboard_viewmodel.dart';
import 'package:prep_ai/widgets/error_widget.dart';
import 'package:prep_ai/widgets/loading_indicator.dart';
import 'package:prep_ai/widgets/question_card.dart';

/// Main dashboard screen with bottom navigation.
///
/// Displays a greeting, progress card, stats summary, and recent questions.
/// Uses [DashboardViewModel] for data and [BookmarkViewModel] for bookmark
/// state on each [QuestionCard]. Bottom navigation drives GoRouter routes.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  // ─── Bottom Navigation ─────────────────────────────────────────

  /// Maps the current GoRouter location to a bottom-nav index.
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/questions':
        return 1;
      case '/bookmarks':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onNavTap(int index) {
    const routes = ['/home', '/questions', '/bookmarks', '/profile'];
    context.go(routes[index]);
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final bookmarkVm = context.watch<BookmarkViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(dashboardVm, bookmarkVm),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: AppStrings.questions,
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: AppStrings.bookmarks,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }

  // ─── Body States ───────────────────────────────────────────────

  Widget _buildBody(
    DashboardViewModel dashboardVm,
    BookmarkViewModel bookmarkVm,
  ) {
    if (dashboardVm.isLoading) {
      return const LoadingIndicator(message: 'Loading dashboard…');
    }

    if (dashboardVm.errorMessage != null) {
      return AppErrorWidget(
        message: dashboardVm.errorMessage!,
        onRetry: () => context.read<DashboardViewModel>().loadDashboard(),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<DashboardViewModel>().loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildGreeting(dashboardVm),
            const SizedBox(height: 24),
            _buildProgressCard(dashboardVm),
            const SizedBox(height: 24),
            _buildStatsRow(dashboardVm),
            const SizedBox(height: 28),
            _buildRecentQuestionsSection(dashboardVm, bookmarkVm),
          ],
        ),
      ),
    );
  }

  // ─── Sections ──────────────────────────────────────────────────

  /// Time-based greeting header.
  Widget _buildGreeting(DashboardViewModel vm) {
    return Text(
      vm.greeting,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
    );
  }

  /// Card showing a circular progress gauge and completion text.
  Widget _buildProgressCard(DashboardViewModel vm) {
    final percentage = (vm.progressPercentage * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── Progress Ring ─────────────────────────────
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: vm.progressPercentage,
                  strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  color: AppColors.textOnPrimary,
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // ─── Progress Text ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.yourProgress,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vm.bookmarkCount} ${AppStrings.questionsCompleted}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Row of stat cards: total questions and bookmark count.
  Widget _buildStatsRow(DashboardViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.quiz_outlined,
            label: AppStrings.totalQuestions,
            value: '${vm.totalQuestions}',
            iconColor: AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.bookmark_outline,
            label: AppStrings.bookmarkedQuestions,
            value: '${vm.bookmarkCount}',
            iconColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Recent questions header + list.
  Widget _buildRecentQuestionsSection(
    DashboardViewModel dashboardVm,
    BookmarkViewModel bookmarkVm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Section Header ──────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentQuestions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            TextButton(
              onPressed: () => context.go('/questions'),
              child: Text(
                AppStrings.viewAll,
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ─── Question List ───────────────────────────────
        if (dashboardVm.recentQuestions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                AppStrings.noQuestionsFound,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          )
        else
          ...dashboardVm.recentQuestions.map(
            (question) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuestionCard(
                question: question,
                isBookmarked: bookmarkVm.isBookmarked(question.id),
                onTap: () => context.go('/questions/${question.id}'),
                onBookmarkTap: () =>
                    context.read<BookmarkViewModel>().toggleBookmark(
                          question.id,
                        ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Private Stat Card Widget ──────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
