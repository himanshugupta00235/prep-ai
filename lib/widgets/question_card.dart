import 'package:flutter/material.dart';
import 'package:prep_ai/core/constants/app_colors.dart';
import 'package:prep_ai/models/question_model.dart';

/// Card widget displaying a question with category, difficulty, and bookmark.
///
/// Shows the question title, a colored category chip, difficulty badge,
/// and an optional bookmark toggle icon.
class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const QuestionCard({
    super.key,
    required this.question,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: Category + Difficulty + Bookmark ───
              Row(
                children: [
                  _buildCategoryChip(),
                  const SizedBox(width: 8),
                  _buildDifficultyBadge(),
                  const Spacer(),
                  _buildBookmarkButton(),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Question Title ─────────────────────────────
              Text(
                question.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // ─── Short Answer Preview ───────────────────────
              Text(
                question.shortAnswer,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: question.category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            question.category.icon,
            size: 14,
            color: question.category.color,
          ),
          const SizedBox(width: 4),
          Text(
            question.category.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: question.category.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: question.difficulty.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        question.difficulty.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: question.difficulty.color,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: onBookmarkTap,
      child: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: isBookmarked ? AppColors.primary : AppColors.textHint,
        size: 24,
      ),
    );
  }
}
