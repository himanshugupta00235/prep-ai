/// Utility functions used across the app.
///
/// Includes form validators, time-based greeting generator,
/// and string formatting helpers.
class Helpers {
  Helpers._();

  // ─── Form Validators ────────────────────────────────────────

  /// Validates an email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates a password (minimum 6 characters).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates that a name is not empty.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates that a generic field is not empty.
  static String? validateRequired(String? value, [String fieldName = 'field']) {
    if (value == null || value.trim().isEmpty) {
      return 'This $fieldName is required';
    }
    return null;
  }

  // ─── Greeting ───────────────────────────────────────────────

  /// Returns a time-based greeting (Good Morning / Afternoon / Evening).
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // ─── Formatting ─────────────────────────────────────────────

  /// Returns the user's first name from a full name string.
  static String getFirstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  /// Formats a progress percentage for display (e.g., "75%").
  static String formatProgress(double progress) {
    return '${(progress * 100).toInt()}%';
  }

  /// Returns a human-readable time-ago string from a [DateTime].
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // ─── Firebase Error Messages ────────────────────────────────

  /// Converts Firebase auth error codes to user-friendly messages.
  static String getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
