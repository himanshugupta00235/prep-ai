# PrepAI — Interview Documentation

> Technical documentation explaining every feature's purpose, business value, implementation, and future roadmap. Written to demonstrate product thinking and engineering maturity.

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Dashboard](#2-dashboard)
3. [Interview Questions](#3-interview-questions)
4. [Bookmark System](#4-bookmark-system)
5. [AI Answer Feature](#5-ai-answer-feature)
6. [User Profile](#6-user-profile)
7. [Architecture Decisions](#architecture-decisions)
8. [Code Quality Practices](#code-quality-practices)
9. [What I Would Do Differently](#what-i-would-do-differently-with-more-time)

---

## 1. Authentication

### Why It Exists
Authentication is the foundation of any personalized application. Without user identity, we cannot save bookmarks, track progress, or provide personalized recommendations. It's also the first screen the user sees — it sets the tone for the entire product experience.

### Business Value
- **User Retention**: Persistent login (via SharedPreferences + Firebase Auth state) means users don't re-enter credentials on every launch — reducing friction and improving daily active usage.
- **Data Ownership**: Each user's data (bookmarks, progress) is tied to their account, enabling cross-device sync and data portability.
- **Security**: Firebase Auth handles password hashing, token management, and brute-force protection — enterprise-grade security without custom infrastructure.

### Technical Implementation
- **Service Layer**: `AuthService` wraps Firebase Auth, exposing `signInWithEmail()`, `signUpWithEmail()`, `signOut()`, and `resetPassword()`.
- **Repository Layer**: `AuthRepository` coordinates three concerns:
  1. Firebase Auth for credential management
  2. Firestore for creating the user profile document on sign-up
  3. SharedPreferences for persisting login state locally
- **ViewModel**: `AuthViewModel` manages form state (loading, errors) and delegates to the repository. Uses `FirebaseAuthException` codes mapped to user-friendly messages via `Helpers.getFirebaseAuthErrorMessage()`.
- **Router Guards**: `go_router` uses `refreshListenable` tied to Firebase Auth state changes. Unauthenticated users are redirected to `/login`; authenticated users bypass auth screens.

### Future Improvements
- Google Sign-In and Apple Sign-In for one-tap authentication
- Email verification requirement before accessing the app
- Account deletion (GDPR compliance)
- Rate limiting on the UI side for login attempts
- Biometric authentication (FaceID/Fingerprint)

---

## 2. Dashboard

### Why It Exists
The dashboard serves as the user's "home base" — a single screen that answers the question "Where am I in my preparation?" It reduces cognitive load by surfacing the most relevant information upfront, rather than requiring users to navigate to multiple screens.

### Business Value
- **Engagement**: The progress indicator creates a "completion motivation" — users are psychologically driven to increase their percentage.
- **Retention**: The greeting and recent questions make the app feel personalized, not generic.
- **Discovery**: Showing recent questions encourages users to continue where they left off, reducing the effort to re-engage.

### Technical Implementation
- **ViewModel**: `DashboardViewModel` aggregates data from four sources using `Future.wait()` for parallel loading:
  1. `UserRepository.getUser()` — User profile for greeting
  2. `QuestionRepository.getQuestions()` — Recent questions (first 5)
  3. `BookmarkRepository.getBookmarkCount()` — Saved questions count
  4. `QuestionRepository.getTotalCount()` — Total for progress calculation
- **Progress Calculation**: `bookmarkCount / totalQuestions` — a simple but meaningful metric that correlates with engagement.
- **Greeting**: `Helpers.getGreeting()` returns time-based greeting (morning/afternoon/evening) with the user's first name.
- **Bottom Navigation**: Uses `go_router` for navigation between Home, Questions, Bookmarks, and Profile tabs.

### Future Improvements
- Preparation streak tracking (consecutive days of activity)
- Category-wise progress breakdown (radar chart)
- Recommended questions based on weak areas
- Daily question notification
- Study time tracking

---

## 3. Interview Questions

### Why It Exists
This is the core content of the application. Students need a structured, searchable collection of interview questions organized by category and difficulty. The search and filter functionality lets users focus on their weakest areas efficiently.

### Business Value
- **Content is King**: Curated, high-quality questions are the primary reason users download and return to the app.
- **Efficiency**: Filtering by category (Flutter, HR, DSA, Firebase) and difficulty (Easy, Medium, Hard) helps users study strategically — focusing on their target areas.
- **Discovery**: Text search enables users to quickly find questions on specific topics.

### Technical Implementation
- **Repository Pattern**: `QuestionRepository` caches the full question list in memory after the first Firestore fetch. Subsequent filter/search operations are instant (no network calls).
- **Client-Side Filtering**: All filtering happens on the cached `List<QuestionModel>`:
  ```
  _applyFilters():
    1. Start with all cached questions
    2. Filter by category (if selected)
    3. Filter by difficulty (if selected)
    4. Filter by search text (case-insensitive title match)
  ```
- **ViewModel**: `QuestionsViewModel` exposes `filterByCategory()`, `filterByDifficulty()`, and `search()` methods. Each calls `_applyFilters()` and `notifyListeners()`.
- **Why Not Firestore Queries?**: Firestore doesn't support full-text search. Client-side filtering on cached data provides instant results and reduces Firestore read costs.

### Future Improvements
- Server-side full-text search using Algolia or Typesense
- User-submitted questions with moderation
- Question difficulty voting (crowd-sourced difficulty ratings)
- Spaced repetition algorithm for review scheduling
- Code syntax highlighting in question answers

---

## 4. Bookmark System

### Why It Exists
When studying for interviews, users find certain questions they want to revisit. The bookmark system lets them curate a personal list of important questions — similar to how developers star GitHub repositories for later reference.

### Business Value
- **Personalization**: Each user builds their own study list, making the app more valuable over time.
- **Engagement Metric**: Bookmark count serves as a progress indicator (more bookmarks = more engagement).
- **Retention**: Users return to review their bookmarked questions before interviews.

### Technical Implementation
- **Optimistic UI Updates**: When a user taps the bookmark icon:
  1. The local `Set<String>` of bookmarked IDs is updated immediately
  2. `notifyListeners()` triggers an instant UI update
  3. The Firestore operation runs asynchronously in the background
  4. If the Firestore operation fails, the optimistic update is reverted by reloading from the server
- **O(1) Lookups**: `BookmarkViewModel` maintains a `Set<String>` of bookmarked question IDs for instant `isBookmarked()` checks — critical for rendering bookmark icons in list views without per-card Firestore queries.
- **Toggle Logic**: `BookmarkRepository.toggleBookmark()` checks if a bookmark exists, then adds or removes accordingly.

### Future Improvements
- Bookmark folders/tags for organization
- Export bookmarked questions as PDF
- Share bookmark collections with friends
- Offline bookmark sync queue
- Swipe-to-unbookmark gesture

---

## 5. AI Answer Feature

### Why It Exists
Students often know the question but struggle to articulate interview-ready answers. The AI answer feature provides both a concise summary (for quick review) and a detailed interview answer (for practice). This bridges the gap between "knowing the concept" and "explaining it confidently in an interview."

### Business Value
- **Differentiation**: Most interview prep apps provide static Q&A. AI-generated answers feel dynamic and personalized.
- **Learning**: Two answer formats serve different study modes — quick review vs. deep preparation.
- **Scalability**: An AI backend can generate answers for unlimited questions without manual content creation.

### Technical Implementation
- **Service Architecture**: `AIService` is designed as a pluggable interface:
  ```
  Future<Map<String, String>> generateAnswer(String questionTitle)
  → Returns { 'shortAnswer': '...', 'interviewAnswer': '...' }
  ```
  Currently uses a mock implementation with keyword-based response matching. The interface is identical to what a real API integration would use.
- **Mock Strategy**: Rather than a trivial "Lorem ipsum" mock, the service returns realistic, high-quality interview answers based on keyword matching. This:
  1. Demonstrates the feature's value without API complexity
  2. Provides actual useful content for the user
  3. Makes the demo impressive without requiring API keys
- **ViewModel**: `AIAnswerViewModel` manages loading/error/success states. Calls `clear()` when navigating to a new question to reset the previous answer.

### Future Improvements
- Integration with Gemini API for dynamic answer generation
- Context-aware answers based on the user's target company
- Answer comparison — user's answer vs. AI ideal answer
- Voice-based answer practice with speech-to-text
- Multiple answer styles (concise, technical, behavioral)

---

## 6. User Profile

### Why It Exists
The profile screen gives users ownership over their preparation journey. The target company field helps users focus their preparation, and the stats provide a sense of achievement and progress.

### Business Value
- **Goal Setting**: The target company field encourages users to define their goal, which research shows increases follow-through.
- **Progress Visibility**: Seeing total questions and bookmarked count motivates continued engagement.
- **Account Management**: Logout functionality is essential for multi-device and shared device scenarios.

### Technical Implementation
- **ViewModel**: `ProfileViewModel` loads user data, question stats, and bookmark count in parallel using `Future.wait()`.
- **Editable Field**: Target company uses `updateTargetCompany()` which writes to Firestore and updates the local `UserModel` via `copyWith()`.
- **Logout Flow**: Confirmation dialog → `AuthViewModel.signOut()` → `context.go('/login')`. Sign out clears both Firebase Auth state and SharedPreferences.

### Future Improvements
- Profile picture upload (Firebase Storage)
- Resume/CV upload for AI-powered feedback
- Interview calendar integration
- Achievement badges/gamification
- Dark mode toggle in profile settings

---

## Architecture Decisions

### Why MVVM?
MVVM was chosen over MVC and Clean Architecture for these reasons:
1. **Clear separation**: Views are "dumb" — they only render state from ViewModels. This makes UI changes safe and predictable.
2. **Testability**: ViewModels can be unit-tested without any Flutter dependencies.
3. **Provider compatibility**: Provider's `ChangeNotifier` maps perfectly to MVVM's ViewModel concept.
4. **Right-sized**: Clean Architecture adds layers (UseCases, Entities) that would be over-engineering for an MVP. MVVM provides sufficient separation without unnecessary abstraction.

### Why Provider?
1. **Official recommendation**: Provider is recommended by the Flutter team.
2. **Simplicity**: Less boilerplate than Bloc/Cubit. Faster to develop with.
3. **InheritedWidget pattern**: Uses Flutter's built-in mechanism, not a third-party state system.
4. **Interview readiness**: Most Flutter teams know Provider — it's the de facto standard for state management.

### Why go_router?
1. **Declarative routing**: Routes are defined as data, not imperative push/pop calls.
2. **Auth guards**: `refreshListenable` + `redirect` provides reactive auth-based navigation.
3. **Web-ready**: URL-based routing supports deep linking and web deployment.
4. **Type-safe parameters**: Path parameters (`/questions/:id`) are cleaner than passing objects through Navigator.

### Why Repositories?
The Repository pattern sits between ViewModels and Services:
- **Caching**: `QuestionRepository` caches questions in memory to avoid repeated Firestore reads.
- **Coordination**: `AuthRepository` coordinates three services (Auth, Firestore, Storage) for the sign-up flow.
- **Abstraction**: ViewModels don't know (or care) where data comes from — Firestore, local cache, or mock data.
- **Testability**: Repositories can be mocked to test ViewModels in isolation.

---

## Code Quality Practices

1. **Consistent Naming**: Classes use PascalCase, methods use camelCase, files use snake_case. Enums have descriptive `displayName` getters.
2. **Null Safety**: All code uses Dart's sound null safety. No `!` force-unwraps without guard checks.
3. **Documentation**: Every public class and complex method has `///` doc comments explaining purpose and usage.
4. **Error Handling**: Try-catch in all async ViewModel methods with user-friendly error messages. No raw exceptions shown to users.
5. **Loading States**: Every data-fetching operation has `isLoading`, enabling the UI to show appropriate indicators.
6. **Empty States**: Every list view handles the empty case with a descriptive message and optional CTA.
7. **Reusable Widgets**: `CustomButton`, `CustomTextField`, `QuestionCard`, `CategoryChip`, `LoadingIndicator`, `AppErrorWidget`, `EmptyStateWidget` — used consistently across all screens.
8. **Constants Centralized**: Colors in `AppColors`, strings in `AppStrings`, theme in `AppTheme`. No magic values in widget code.
9. **Separation of Concerns**: UI code never calls Firebase directly. All data access goes through ViewModel → Repository → Service.
10. **Immutable Models**: Model classes use `final` fields and `copyWith()` for safe state updates.

---

## What I Would Do Differently with More Time

### Testing
- Unit tests for all ViewModels and Repositories
- Widget tests for critical user flows (login, bookmark toggle)
- Integration tests for end-to-end scenarios
- Use the Firebase Emulator Suite for offline testing

### Features
- Spaced repetition algorithm for optimal question review scheduling
- Real Gemini API integration for dynamic AI answers
- Offline-first architecture with local database (Hive/SQLite)
- Push notifications for daily practice reminders
- Social features — share progress, compete with friends

### DevOps
- CI/CD with GitHub Actions (build, test, deploy)
- Automated code quality checks (linting, formatting)
- Firebase App Distribution for beta testing
- Crashlytics integration for production error tracking
- Performance monitoring dashboard

### Design
- Onboarding flow for first-time users
- Dark mode support
- Micro-animations for bookmark toggle, progress updates
- Skeleton loading screens instead of spinners
- Haptic feedback on key interactions

---

*This document demonstrates that every feature was built with intentional product thinking — understanding the "why" behind each decision, not just the "how." In a startup environment, this kind of thinking is what separates a developer who writes code from one who builds products.*
