/// Centralized user-facing strings for PrepAI.
///
/// Keeping all strings here enables easy localization in the future
/// and ensures consistency across the app.
class AppStrings {
  AppStrings._();

  // ─── App ──────────────────────────────────────────────────
  static const String appName = 'PrepAI';
  static const String appTagline = 'Ace Your Next Interview';

  // ─── Auth ─────────────────────────────────────────────────
  static const String login = 'Login';
  static const String register = 'Register';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = 'Already have an account? ';
  static const String resetEmailSent = 'Password reset email sent!';
  static const String loginSubtitle = 'Welcome back! Continue your preparation.';
  static const String registerSubtitle = 'Start your interview preparation journey.';

  // ─── Dashboard ────────────────────────────────────────────
  static const String dashboard = 'Dashboard';
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String yourProgress = 'Your Progress';
  static const String recentQuestions = 'Recent Questions';
  static const String savedQuestions = 'Saved Questions';
  static const String questionsCompleted = 'questions completed';
  static const String startPracticing = 'Start Practicing';
  static const String viewAll = 'View All';

  // ─── Questions ────────────────────────────────────────────
  static const String questions = 'Questions';
  static const String searchQuestions = 'Search questions...';
  static const String allCategories = 'All';
  static const String noQuestionsFound = 'No questions found';
  static const String tryDifferentFilter = 'Try a different filter or search term.';
  static const String getAIAnswer = 'Get AI Answer';

  // ─── Categories ───────────────────────────────────────────
  static const String flutterCategory = 'Flutter';
  static const String hrCategory = 'HR';
  static const String dsaCategory = 'DSA';
  static const String firebaseCategory = 'Firebase';

  // ─── Difficulty ───────────────────────────────────────────
  static const String easyDifficulty = 'Easy';
  static const String mediumDifficulty = 'Medium';
  static const String hardDifficulty = 'Hard';

  // ─── Bookmarks ────────────────────────────────────────────
  static const String bookmarks = 'Bookmarks';
  static const String noBookmarks = 'No bookmarks yet';
  static const String noBookmarksMessage = 'Save questions to review them later.';
  static const String bookmarkAdded = 'Question bookmarked!';
  static const String bookmarkRemoved = 'Bookmark removed.';

  // ─── AI Answers ───────────────────────────────────────────
  static const String aiAnswer = 'AI Answer';
  static const String shortAnswer = 'Short Answer';
  static const String interviewAnswer = 'Interview Answer';
  static const String generating = 'Generating answer...';

  // ─── Profile ──────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String targetCompany = 'Target Company';
  static const String editProfile = 'Edit Profile';
  static const String logout = 'Logout';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String totalQuestions = 'Total Questions';
  static const String bookmarkedQuestions = 'Bookmarked';

  // ─── Errors ───────────────────────────────────────────────
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  static const String networkError = 'Please check your internet connection.';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameRequired = 'Please enter your name';
  static const String fieldRequired = 'This field is required';

  // ─── Navigation ───────────────────────────────────────────
  static const String home = 'Home';
}
