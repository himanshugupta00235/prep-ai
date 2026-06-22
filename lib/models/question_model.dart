import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prep_ai/core/constants/app_colors.dart';

/// Categories of interview questions.
enum QuestionCategory {
  flutter,
  hr,
  dsa,
  firebase;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case QuestionCategory.flutter:
        return 'Flutter';
      case QuestionCategory.hr:
        return 'HR';
      case QuestionCategory.dsa:
        return 'DSA';
      case QuestionCategory.firebase:
        return 'Firebase';
    }
  }

  /// Color associated with this category.
  Color get color {
    switch (this) {
      case QuestionCategory.flutter:
        return AppColors.flutter;
      case QuestionCategory.hr:
        return AppColors.hr;
      case QuestionCategory.dsa:
        return AppColors.dsa;
      case QuestionCategory.firebase:
        return AppColors.firebase;
    }
  }

  /// Icon associated with this category.
  IconData get icon {
    switch (this) {
      case QuestionCategory.flutter:
        return Icons.flutter_dash;
      case QuestionCategory.hr:
        return Icons.people_outline;
      case QuestionCategory.dsa:
        return Icons.code;
      case QuestionCategory.firebase:
        return Icons.cloud_outlined;
    }
  }

  /// Parses a string to a [QuestionCategory].
  static QuestionCategory fromString(String value) {
    return QuestionCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => QuestionCategory.flutter,
    );
  }
}

/// Difficulty levels for interview questions.
enum DifficultyLevel {
  easy,
  medium,
  hard;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  /// Color associated with this difficulty.
  Color get color {
    switch (this) {
      case DifficultyLevel.easy:
        return AppColors.easy;
      case DifficultyLevel.medium:
        return AppColors.medium;
      case DifficultyLevel.hard:
        return AppColors.hard;
    }
  }

  /// Parses a string to a [DifficultyLevel].
  static DifficultyLevel fromString(String value) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => DifficultyLevel.easy,
    );
  }
}

/// Represents an interview question.
///
/// Stored in the `questions` Firestore collection.
class QuestionModel {
  final String id;
  final String title;
  final QuestionCategory category;
  final DifficultyLevel difficulty;
  final String shortAnswer;
  final String detailedAnswer;

  const QuestionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.shortAnswer,
    required this.detailedAnswer,
  });

  /// Creates a [QuestionModel] from a Firestore document snapshot.
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: QuestionCategory.fromString(data['category'] ?? 'flutter'),
      difficulty: DifficultyLevel.fromString(data['difficulty'] ?? 'easy'),
      shortAnswer: data['shortAnswer'] ?? '',
      detailedAnswer: data['detailedAnswer'] ?? '',
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category.name,
      'difficulty': difficulty.name,
      'shortAnswer': shortAnswer,
      'detailedAnswer': detailedAnswer,
    };
  }
}
