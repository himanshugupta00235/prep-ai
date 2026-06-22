import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prep_ai/core/constants/app_colors.dart';
import 'package:prep_ai/core/constants/app_strings.dart';
import 'package:prep_ai/models/question_model.dart';
import 'package:prep_ai/viewmodels/ai_answer_viewmodel.dart';
import 'package:prep_ai/viewmodels/bookmark_viewmodel.dart';
import 'package:prep_ai/viewmodels/questions_viewmodel.dart';
import 'package:prep_ai/widgets/custom_button.dart';
import 'package:prep_ai/widgets/error_widget.dart';
import 'package:prep_ai/widgets/loading_indicator.dart';

/// Detail screen for a single interview question.
///
/// Shows the question title, category, difficulty, short answer, and
/// detailed answer. Provides a bookmark toggle in the AppBar and an
/// AI answer generation feature.
class QuestionDetailScreen extends StatefulWidget {
  /// Firestore document ID of the question to display.
  final String questionId;

  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  QuestionModel? _question;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Clear any previous AI answer and load question data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIAnswerViewModel>().clear();
      _loadQuestion();
    });
  }

  /// Fetches the question from the repository by ID.
  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questionsVM = context.read<QuestionsViewModel>();
      final question = await questionsVM.getQuestion(widget.questionId);

      if (!mounted) return;

      if (question == null) {
        setState(() {
          _errorMessage = 'Question not found.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _question = question;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load question. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkVM = context.watch<BookmarkViewModel>();
    final aiAnswerVM = context.watch<AIAnswerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _question?.title ?? AppStrings.questions,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_question != null)
            IconButton(
              icon: Icon(
                bookmarkVM.isBookmarked(_question!.id)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: bookmarkVM.isBookmarked(_question!.id)
                    ? AppColors.primary
                    : null,
              ),
              onPressed: () =>
                  context.read<BookmarkViewModel>().toggleBookmark(
                        _question!.id,
                      ),
            ),
        ],
      ),
      body: _buildBody(bookmarkVM, aiAnswerVM),
    );
  }

  /// Builds the screen body based on loading / error / data state.
  Widget _buildBody(BookmarkViewModel bookmarkVM, AIAnswerViewModel aiAnswerVM) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadQuestion,
      );
    }

    final question = _question!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Category & Difficulty Badges ─────────────────────
          Row(
            children: [
              _buildCategoryChip(question),
              const SizedBox(width: 10),
              _buildDifficultyBadge(question),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Question Title ──────────────────────────────────
          Text(
            question.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 24),

          // ─── Short Answer Section ────────────────────────────
          _buildSectionTitle(AppStrings.shortAnswer),
          const SizedBox(height: 8),
          _buildContentCard(question.shortAnswer),
          const SizedBox(height: 20),

          // ─── Detailed Answer Section ─────────────────────────
          _buildSectionTitle('Detailed Answer'),
          const SizedBox(height: 8),
          _buildContentCard(question.detailedAnswer),
          const SizedBox(height: 24),

          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),

          // ─── Get AI Answer Button ────────────────────────────
          CustomButton(
            text: AppStrings.getAIAnswer,
            icon: Icons.auto_awesome,
            isLoading: aiAnswerVM.isLoading,
            onPressed: aiAnswerVM.isLoading
                ? null
                : () => context
                    .read<AIAnswerViewModel>()
                    .generateAnswer(question.title),
          ),
          const SizedBox(height: 16),

          // ─── AI Answer Loading ───────────────────────────────
          if (aiAnswerVM.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LoadingIndicator(message: AppStrings.generating),
            ),

          // ─── AI Answer Error ─────────────────────────────────
          if (aiAnswerVM.errorMessage != null && !aiAnswerVM.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                aiAnswerVM.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),

          // ─── AI Answer Results ───────────────────────────────
          if (aiAnswerVM.hasAnswer) ...[
            _buildSectionTitle('AI ${AppStrings.shortAnswer}'),
            const SizedBox(height: 8),
            _buildAIAnswerCard(aiAnswerVM.shortAnswer!),
            const SizedBox(height: 20),
            _buildSectionTitle('AI ${AppStrings.interviewAnswer}'),
            const SizedBox(height: 8),
            _buildAIAnswerCard(aiAnswerVM.interviewAnswer!),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  // ─── Helper Widgets ────────────────────────────────────────────────────

  /// Builds a colored category chip for the question.
  Widget _buildCategoryChip(QuestionModel question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: question.category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            question.category.icon,
            size: 16,
            color: question.category.color,
          ),
          const SizedBox(width: 6),
          Text(
            question.category.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: question.category.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a colored difficulty badge for the question.
  Widget _buildDifficultyBadge(QuestionModel question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: question.difficulty.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        question.difficulty.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: question.difficulty.color,
        ),
      ),
    );
  }

  /// Builds a bold section title.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
    );
  }

  /// Builds a content card for question answer text.
  Widget _buildContentCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }

  /// Builds a styled card for AI-generated answer content.
  Widget _buildAIAnswerCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'AI Generated',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
