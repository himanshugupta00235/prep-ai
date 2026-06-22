import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:prep_ai/core/constants/app_colors.dart';
import 'package:prep_ai/core/constants/app_strings.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/viewmodels/bookmark_viewmodel.dart';
import 'package:prep_ai/viewmodels/questions_viewmodel.dart';
import 'package:prep_ai/widgets/category_chip.dart';
import 'package:prep_ai/widgets/empty_state_widget.dart';
import 'package:prep_ai/widgets/error_widget.dart';
import 'package:prep_ai/widgets/loading_indicator.dart';
import 'package:prep_ai/widgets/question_card.dart';

/// Main questions listing screen with search and filtering.
///
/// Displays all available interview questions with category and difficulty
/// filters. Each question card shows bookmark status and navigates to the
/// detail view on tap.
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load questions and bookmarks on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionsViewModel>().loadQuestions();
      context.read<BookmarkViewModel>().loadBookmarks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsVM = context.watch<QuestionsViewModel>();
    final bookmarkVM = context.watch<BookmarkViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.questions),
      ),
      body: Column(
        children: [
          // ─── Search Bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<QuestionsViewModel>().search(value),
              decoration: InputDecoration(
                hintText: AppStrings.searchQuestions,
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context.read<QuestionsViewModel>().search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ─── Category Filter Chips ─────────────────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  category: null,
                  label: AppStrings.allCategories,
                  isSelected: questionsVM.selectedCategory == null,
                  onTap: () => context
                      .read<QuestionsViewModel>()
                      .filterByCategory(null),
                ),
                const SizedBox(width: 8),
                ...QuestionCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      category: category,
                      label: category.displayName,
                      isSelected: questionsVM.selectedCategory == category,
                      onTap: () => context
                          .read<QuestionsViewModel>()
                          .filterByCategory(category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ─── Difficulty Filter Chips ───────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _DifficultyChip(
                  label: AppStrings.allCategories,
                  isSelected: questionsVM.selectedDifficulty == null,
                  onTap: () => context
                      .read<QuestionsViewModel>()
                      .filterByDifficulty(null),
                ),
                const SizedBox(width: 8),
                ...DifficultyLevel.values.map(
                  (difficulty) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _DifficultyChip(
                      label: difficulty.displayName,
                      color: difficulty.color,
                      isSelected: questionsVM.selectedDifficulty == difficulty,
                      onTap: () => context
                          .read<QuestionsViewModel>()
                          .filterByDifficulty(difficulty),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ─── Question List ─────────────────────────────────────
          Expanded(
            child: _buildBody(questionsVM, bookmarkVM),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// Builds the main body based on the current ViewModel state.
  Widget _buildBody(
    QuestionsViewModel questionsVM,
    BookmarkViewModel bookmarkVM,
  ) {
    // Loading state
    if (questionsVM.isLoading) {
      return const LoadingIndicator();
    }

    // Error state
    if (questionsVM.errorMessage != null) {
      return AppErrorWidget(
        message: questionsVM.errorMessage!,
        onRetry: () => context.read<QuestionsViewModel>().loadQuestions(),
      );
    }

    // Empty state
    if (questionsVM.questions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.quiz_outlined,
        title: AppStrings.noQuestionsFound,
        message: AppStrings.tryDifferentFilter,
      );
    }

    // Question list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: questionsVM.questions.length,
      itemBuilder: (context, index) {
        final question = questionsVM.questions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: QuestionCard(
            question: question,
            isBookmarked: bookmarkVM.isBookmarked(question.id),
            onTap: () => context.go('/questions/${question.id}'),
            onBookmarkTap: () =>
                context.read<BookmarkViewModel>().toggleBookmark(question.id),
          ),
        );
      },
    );
  }

  /// Standard bottom navigation bar shared across main screens.
  Widget _buildBottomNavBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 1,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            break; // Already on Questions
          case 2:
            context.go('/bookmarks');
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

// ─── Private Widgets ───────────────────────────────────────────────────────

/// Chip widget for difficulty level filtering.
///
/// Displays a tappable chip with animated selection state.
class _DifficultyChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? chipColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
