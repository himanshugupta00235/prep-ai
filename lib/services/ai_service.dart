/// Mock AI service for generating interview answers.
///
/// Returns realistic interview-style answers for questions.
/// Architecture is designed so this can be swapped with a real AI API
/// (e.g., Gemini, OpenAI) by changing the implementation.
class AIService {
  /// Generates a short answer and a detailed interview answer
  /// for the given question title.
  ///
  /// Returns a map with 'shortAnswer' and 'interviewAnswer' keys.
  Future<Map<String, String>> generateAnswer(String questionTitle) async {
    // Simulate network delay for realistic UX
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock AI responses based on question patterns
    final responses = _getMockResponse(questionTitle);
    return responses;
  }

  /// Returns mock responses based on keyword matching.
  ///
  /// In production, this would call an AI API endpoint.
  Map<String, String> _getMockResponse(String questionTitle) {
    final title = questionTitle.toLowerCase();

    // ─── Flutter-related Questions ────────────────────────────
    if (title.contains('state management')) {
      return {
        'shortAnswer':
            'State management in Flutter refers to how data is stored, accessed, '
            'and updated across widgets. Popular solutions include Provider, Riverpod, '
            'Bloc, and GetX.',
        'interviewAnswer':
            'State management is one of the most critical aspects of Flutter development. '
            'In Flutter, everything is a widget, and widgets rebuild when their state changes. '
            'There are two types of state: ephemeral (local) state, which is managed within a '
            'single widget using setState(), and app state, which needs to be shared across '
            'multiple widgets.\n\n'
            'For this project, I chose Provider because it\'s officially recommended by the '
            'Flutter team, has excellent documentation, and follows the InheritedWidget pattern '
            'under the hood. Provider uses ChangeNotifier classes that notify listeners when '
            'data changes, triggering widget rebuilds only where needed.\n\n'
            'In a production app, I would evaluate the complexity requirements — for simpler '
            'apps Provider is ideal, while Bloc/Cubit suits larger teams with strict patterns, '
            'and Riverpod offers compile-time safety and better testability.',
      };
    }

    if (title.contains('widget') && title.contains('lifecycle')) {
      return {
        'shortAnswer':
            'Flutter widget lifecycle includes createState(), initState(), '
            'didChangeDependencies(), build(), didUpdateWidget(), setState(), '
            'deactivate(), and dispose().',
        'interviewAnswer':
            'Understanding the widget lifecycle is fundamental to Flutter development. '
            'A StatefulWidget goes through several stages:\n\n'
            '1. createState() — Called once to create the State object.\n'
            '2. initState() — Called once after the State is created. Initialize '
            'controllers, subscriptions here.\n'
            '3. didChangeDependencies() — Called after initState and whenever '
            'InheritedWidget dependencies change.\n'
            '4. build() — Called whenever the widget needs to render. Should be pure '
            'and fast.\n'
            '5. didUpdateWidget() — Called when the parent rebuilds with new config.\n'
            '6. setState() — Triggers a rebuild by marking the widget dirty.\n'
            '7. deactivate() — Called when removed from the tree temporarily.\n'
            '8. dispose() — Called when permanently removed. Clean up controllers, '
            'subscriptions here.\n\n'
            'Best practice: Always dispose controllers in dispose() to prevent memory '
            'leaks, and keep build() methods lightweight.',
      };
    }

    if (title.contains('mvvm') || title.contains('architecture')) {
      return {
        'shortAnswer':
            'MVVM (Model-View-ViewModel) separates UI from business logic. '
            'Models hold data, Views render UI, ViewModels manage state and '
            'communicate with repositories.',
        'interviewAnswer':
            'MVVM architecture in Flutter provides clear separation of concerns:\n\n'
            '• Models — Pure Dart classes representing data entities. They handle '
            'serialization (fromJson/toJson) and have no Flutter dependencies.\n\n'
            '• Views — Flutter widgets that render UI. They are "dumb" — they only '
            'display data from ViewModels and forward user actions. No business logic.\n\n'
            '• ViewModels — ChangeNotifier classes that hold UI state, call repositories, '
            'and expose data via getters. One ViewModel per screen is the recommended '
            'pattern.\n\n'
            'Additionally, I use a Repository layer between ViewModels and Services to '
            'abstract data sources. Services handle direct API/database calls, while '
            'Repositories coordinate between multiple services and handle caching.\n\n'
            'This architecture makes the codebase testable, maintainable, and scalable. '
            'Each layer can be tested independently with mock dependencies.',
      };
    }

    if (title.contains('hot reload') || title.contains('hot restart')) {
      return {
        'shortAnswer':
            'Hot Reload injects updated source code into the running Dart VM without '
            'losing app state. Hot Restart recompiles and restarts the entire app.',
        'interviewAnswer':
            'Hot Reload is one of Flutter\'s most productive features. It works by '
            'injecting updated source code files into the running Dart Virtual Machine. '
            'The framework then rebuilds the widget tree, allowing you to see changes '
            'instantly — typically under one second — while preserving app state.\n\n'
            'Hot Restart, on the other hand, fully restarts the app and resets all state. '
            'You need Hot Restart when you change initialization logic, modify global '
            'variables, or change enum definitions.\n\n'
            'Under the hood, Hot Reload works because Dart supports incremental '
            'compilation. The VM can load updated kernel files and re-execute only '
            'the affected code paths. This is why it preserves state — the existing '
            'State objects in memory remain unchanged.',
      };
    }

    // ─── HR Questions ────────────────────────────────────────
    if (title.contains('tell me about yourself') || title.contains('introduce')) {
      return {
        'shortAnswer':
            'Structure your answer: Present (current role/studies), Past (relevant '
            'experience), Future (why this role). Keep it under 2 minutes.',
        'interviewAnswer':
            'This is often the first question in any interview, and it sets the tone. '
            'Use the Present-Past-Future framework:\n\n'
            'Present: Start with what you\'re currently doing. "I\'m a final year '
            'Computer Science student at [University], specializing in mobile development '
            'with Flutter."\n\n'
            'Past: Highlight relevant experience. "I\'ve built 3 Flutter applications, '
            'including a production app that handles [specific feature]. I\'ve also '
            'contributed to open-source Flutter packages."\n\n'
            'Future: Connect to the role. "I\'m excited about this Flutter internship '
            'because I want to work on production-scale apps and learn from experienced '
            'developers. Your company\'s focus on [specific area] aligns perfectly with '
            'my interests."\n\n'
            'Key tips: Keep it professional (not personal), quantify achievements, '
            'and always end with why you\'re interested in THIS specific role.',
      };
    }

    if (title.contains('strength') || title.contains('weakness')) {
      return {
        'shortAnswer':
            'For strengths: Give specific examples with impact. For weaknesses: '
            'Choose a real but non-critical weakness and show how you\'re improving.',
        'interviewAnswer':
            'Strengths — Pick 2-3 relevant to the role and back each with a specific '
            'example:\n'
            '"One of my key strengths is problem decomposition. When building my '
            'interview prep app, I broke down the architecture into Models, Services, '
            'Repositories, and ViewModels. This made the codebase maintainable and '
            'allowed me to add features without breaking existing ones."\n\n'
            'Weaknesses — The key is authenticity + growth mindset:\n'
            '"I sometimes spend too much time optimizing code on the first pass. I\'ve '
            'learned to follow the principle of \'make it work, make it right, make it '
            'fast\' — shipping a working version first, then iterating on quality. This '
            'has significantly improved my delivery speed."\n\n'
            'Never say "I\'m a perfectionist" — interviewers see through it. Choose '
            'something genuine but not critical to the role.',
      };
    }

    // ─── DSA Questions ───────────────────────────────────────
    if (title.contains('time complexity') || title.contains('big o')) {
      return {
        'shortAnswer':
            'Big O notation describes how an algorithm\'s runtime grows relative to input '
            'size. Common complexities: O(1), O(log n), O(n), O(n log n), O(n²).',
        'interviewAnswer':
            'Time complexity analysis is fundamental to writing efficient code. Big O '
            'notation describes the upper bound of an algorithm\'s growth rate:\n\n'
            '• O(1) — Constant: HashMap lookup, array index access\n'
            '• O(log n) — Logarithmic: Binary search\n'
            '• O(n) — Linear: Single loop through array\n'
            '• O(n log n) — Linearithmic: Merge sort, efficient sorting\n'
            '• O(n²) — Quadratic: Nested loops, bubble sort\n'
            '• O(2ⁿ) — Exponential: Recursive Fibonacci without memoization\n\n'
            'When analyzing code, count the number of operations relative to input size. '
            'Drop constants and lower-order terms. For example, O(3n + 5) simplifies to '
            'O(n).\n\n'
            'In interviews, always discuss both time AND space complexity. Sometimes you '
            'can trade space for time (like using a HashSet for O(1) lookups instead of '
            'O(n) linear search).',
      };
    }

    // ─── Firebase Questions ──────────────────────────────────
    if (title.contains('firestore') || title.contains('firebase database')) {
      return {
        'shortAnswer':
            'Cloud Firestore is a NoSQL document database. Data is organized in '
            'collections and documents. It supports real-time listeners, offline '
            'persistence, and automatic scaling.',
        'interviewAnswer':
            'Cloud Firestore is Google\'s flagship NoSQL database for mobile and web '
            'apps. Key concepts:\n\n'
            '• Data Model: Collections contain Documents, which contain fields and '
            'subcollections. Unlike SQL, there\'s no fixed schema — each document can '
            'have different fields.\n\n'
            '• Real-time Updates: Firestore supports snapshot listeners that push '
            'changes to clients instantly. This is ideal for chat apps, dashboards, '
            'and collaborative tools.\n\n'
            '• Offline Support: Firestore caches data locally and syncs when the '
            'device comes back online. This works out of the box on mobile.\n\n'
            '• Security Rules: Server-side rules control read/write access. Always '
            'validate data structure and user ownership in rules.\n\n'
            '• Best Practices: Denormalize data for faster reads, use composite '
            'indexes for complex queries, and structure data based on your query '
            'patterns rather than relationships.\n\n'
            'In my PrepAI app, I use three collections: users (profiles), questions '
            '(content), and bookmarks (user-question relationships).',
      };
    }

    // ─── Default Response ────────────────────────────────────
    return {
      'shortAnswer':
          'This is a fundamental concept in software development. Understanding it '
          'demonstrates strong technical foundations and the ability to apply '
          'theoretical knowledge to practical problems.',
      'interviewAnswer':
          'When answering this question in an interview, I would structure my '
          'response using the STAR method:\n\n'
          '• Situation: Explain the context where this concept is relevant.\n'
          '• Task: Describe what you needed to accomplish.\n'
          '• Action: Detail the specific steps you took, referencing the concept.\n'
          '• Result: Share the outcome and what you learned.\n\n'
          'Key tips for a strong answer:\n'
          '1. Start with a clear, concise definition.\n'
          '2. Give a real-world example from your projects.\n'
          '3. Discuss trade-offs and alternatives.\n'
          '4. Mention how you\'ve applied it in practice.\n\n'
          'Remember: Interviewers care more about your thought process and '
          'practical experience than memorized definitions. Show that you '
          'understand the "why" behind the concept, not just the "what".',
    };
  }
}
