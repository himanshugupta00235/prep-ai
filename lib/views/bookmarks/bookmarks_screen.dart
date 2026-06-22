import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:prep_ai/core/constants/app_colors.dart';
import 'package:prep_ai/core/constants/app_strings.dart';
import 'package:prep_ai/viewmodels/bookmark_viewmodel.dart';
import 'package:prep_ai/widgets/empty_state_widget.dart';
import 'package:prep_ai/widgets/error_widget.dart';
import 'package:prep_ai/widgets/loading_indicator.dart';
import 'package:prep_ai/widgets/question_card.dart';

/// Bookmarks screen displaying the user's saved questions.
///
/// Questions can be removed by swiping to dismiss or tapping the
/// bookmark icon. Navigating to a card opens the question detail view.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkViewModel>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkVM = context.watch<BookmarkViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookmarks),
      ),
      body: _buildBody(bookmarkVM),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// Builds the main body based on the current ViewModel state.
  Widget _buildBody(BookmarkViewModel bookmarkVM) {
    // Loading state
    if (bookmarkVM.isLoading) {
      return const LoadingIndicator();
    }

    // Error state
    if (bookmarkVM.errorMessage != null) {
      return AppErrorWidget(
        message: bookmarkVM.errorMessage!,
        onRetry: () => context.read<BookmarkViewModel>().loadBookmarks(),
      );
    }

    // Empty state
    if (bookmarkVM.bookmarkedQuestions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.bookmark_border,
        title: AppStrings.noBookmarks,
        message: AppStrings.noBookmarksMessage,
      );
    }

    // Bookmarked questions list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: bookmarkVM.bookmarkedQuestions.length,
      itemBuilder: (context, index) {
        final question = bookmarkVM.bookmarkedQuestions[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey(question.id),
            direction: DismissDirection.endToStart,
            background: _buildDismissBackground(),
            confirmDismiss: (_) => _confirmRemoveBookmark(context),
            onDismissed: (_) {
              context.read<BookmarkViewModel>().toggleBookmark(question.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.bookmarkRemoved),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: QuestionCard(
              question: question,
              isBookmarked: true,
              onTap: () => context.go('/questions/${question.id}'),
              onBookmarkTap: () => context
                  .read<BookmarkViewModel>()
                  .toggleBookmark(question.id),
            ),
          ),
        );
      },
    );
  }

  /// Red background shown behind a card during swipe-to-dismiss.
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: AppColors.error,
        size: 28,
      ),
    );
  }

  /// Asks the user to confirm before removing a bookmark.
  Future<bool?> _confirmRemoveBookmark(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bookmark'),
        content: const Text(
          'Are you sure you want to remove this question from your bookmarks?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Standard bottom navigation bar shared across main screens.
  Widget _buildBottomNavBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            context.go('/questions');
          case 2:
            break; // Already on Bookmarks
          case 3:
            context.go('/profile');
        }
      },
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
    );
  }
}
