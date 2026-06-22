// PrepAI - Firestore Seed Data Script
//
// Run this script to populate the 'questions' collection with
// curated interview questions across Flutter, HR, DSA, and Firebase.
//
// Usage (from project root):
//   dart run lib/seed_data.dart
//
// Prerequisites:
//   - Firebase project configured with `flutterfire configure`
//   - Firestore database created in the Firebase console

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// TODO: Import firebase_options.dart after running `flutterfire configure`
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final questionsRef = firestore.collection('questions');

  print('🌱 Seeding interview questions...\n');

  for (final question in _seedQuestions) {
    final docRef = questionsRef.doc();
    batch.set(docRef, question);
  }

  await batch.commit();
  print('✅ Successfully seeded ${_seedQuestions.length} questions!');
}

/// Curated interview questions across 4 categories.
final List<Map<String, dynamic>> _seedQuestions = [
  // ═══════════════════════════════════════════════════════════
  // FLUTTER QUESTIONS
  // ═══════════════════════════════════════════════════════════
  {
    'title': 'What is the difference between StatelessWidget and StatefulWidget?',
    'category': 'flutter',
    'difficulty': 'easy',
    'shortAnswer':
        'StatelessWidget is immutable and does not maintain state. StatefulWidget maintains a State object that can change over time and trigger rebuilds.',
    'detailedAnswer':
        'StatelessWidget is used when the UI does not change after it is built. It has no mutable state and its build method is called only when the widget is first inserted or when its parent rebuilds with new configuration.\n\nStatefulWidget maintains a separate State object that persists across rebuilds. When setState() is called, Flutter marks the widget as dirty and schedules a rebuild. Use StatefulWidget when you need to manage user interaction, animations, or data that changes over time.\n\nBest practice: Start with StatelessWidget and convert to StatefulWidget only when needed. Consider using state management solutions like Provider for app-wide state.',
  },
  {
    'title': 'Explain the Widget Lifecycle in Flutter',
    'category': 'flutter',
    'difficulty': 'medium',
    'shortAnswer':
        'The lifecycle includes createState(), initState(), didChangeDependencies(), build(), didUpdateWidget(), setState(), deactivate(), and dispose().',
    'detailedAnswer':
        'A StatefulWidget goes through several lifecycle stages:\n\n1. createState() — Called once when the framework creates the StatefulWidget.\n2. initState() — Called once after State is created. Initialize controllers, subscriptions, and fetch initial data here.\n3. didChangeDependencies() — Called after initState and whenever InheritedWidget dependencies change.\n4. build() — Called whenever the widget needs to render. Must be pure and fast — no side effects.\n5. didUpdateWidget() — Called when the parent rebuilds with new configuration for this widget.\n6. setState() — Triggers a rebuild by marking the widget as dirty.\n7. deactivate() — Called when the widget is temporarily removed from the tree.\n8. dispose() — Called when permanently removed. Clean up controllers, timers, and subscriptions here.\n\nCommon mistakes: Forgetting to dispose controllers (memory leaks), calling setState after dispose, or doing expensive operations in build().',
  },
  {
    'title': 'What is State Management and why is it important?',
    'category': 'flutter',
    'difficulty': 'medium',
    'shortAnswer':
        'State management is how data is stored, accessed, and updated across widgets. It prevents prop drilling and ensures consistent UI updates.',
    'detailedAnswer':
        'State management in Flutter refers to the approach used to handle data that changes over time and affects the UI. There are two types:\n\n1. Ephemeral State — Local to a single widget (e.g., current tab index, form input). Managed with setState().\n\n2. App State — Shared across multiple widgets or persisted across sessions (e.g., user authentication, cart items). Requires dedicated solutions.\n\nPopular solutions:\n• Provider — Official recommendation, uses InheritedWidget under the hood\n• Riverpod — Compile-safe, doesn\'t depend on BuildContext\n• Bloc/Cubit — Event-driven, great for complex business logic\n• GetX — Simple syntax but less structured\n\nWhy it matters: Without proper state management, apps face issues like unnecessary rebuilds, inconsistent UI, prop drilling (passing data through many widget layers), and difficulty testing.',
  },
  {
    'title': 'What is the difference between hot reload and hot restart?',
    'category': 'flutter',
    'difficulty': 'easy',
    'shortAnswer':
        'Hot reload injects updated code into the running VM and preserves app state. Hot restart recompiles and restarts the app, resetting all state.',
    'detailedAnswer':
        'Hot Reload is Flutter\'s signature productivity feature. It works by injecting updated source code into the running Dart Virtual Machine. The framework rebuilds the widget tree with the new code while preserving the current app state. This typically takes less than a second.\n\nHot Restart fully recompiles the app and restarts it from scratch. All state is lost. You need hot restart when:\n• You change initState() logic\n• You modify global variables or static fields\n• You add/remove enum values\n• You change the app\'s main() function\n\nUnder the hood, hot reload works because Dart supports incremental compilation. The VM loads updated kernel files and re-executes only affected code. Existing State objects remain in memory, which is why state is preserved.',
  },
  {
    'title': 'Explain the BuildContext in Flutter',
    'category': 'flutter',
    'difficulty': 'medium',
    'shortAnswer':
        'BuildContext is a handle to the location of a widget in the widget tree. It\'s used to find ancestor widgets, access inherited data, and navigate.',
    'detailedAnswer':
        'BuildContext is an abstract class that represents the location of a widget within the widget tree. Every widget has its own BuildContext, which is passed to the build() method.\n\nKey uses:\n• Finding ancestors: Theme.of(context), MediaQuery.of(context)\n• Navigation: Navigator.of(context), GoRouter.of(context)\n• Showing dialogs: showDialog(context: context)\n• Accessing Provider: context.watch<T>(), context.read<T>()\n\nImportant: BuildContext is only valid within the scope where it\'s created. Never store a BuildContext or use it after a widget has been disposed. In async operations, check if the widget is still mounted before using context.\n\nCommon mistake: Using context before the widget is fully built (e.g., in initState). Use WidgetsBinding.instance.addPostFrameCallback for operations that need context in initState.',
  },
  {
    'title': 'What are Keys in Flutter and when should you use them?',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'Keys help Flutter identify widgets uniquely during rebuilds. Use them in lists, when reordering widgets, or when preserving state across moves.',
    'detailedAnswer':
        'Keys control how Flutter matches widgets between the old and new widget trees during rebuilds. Without keys, Flutter matches by widget type and position.\n\nTypes of keys:\n• ValueKey — Uses a value (like an ID) for identity\n• ObjectKey — Uses an object reference\n• UniqueKey — Creates a new identity every time (forces rebuild)\n• GlobalKey — Unique across the entire app, provides access to State\n\nWhen to use:\n1. Lists with Dismissible widgets (required to prevent wrong item removal)\n2. Reorderable lists\n3. Widgets that maintain state and can change position\n4. When you need to access a widget\'s State from outside (GlobalKey)\n\nWhen NOT to use:\n• Static lists that don\'t change order\n• Stateless widgets in fixed positions\n\nPerformance note: Don\'t use keys unnecessarily — they add overhead. Only add them when you need to preserve identity or state during reorders.',
  },
  {
    'title': 'What is the difference between Navigator 1.0 and 2.0?',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'Navigator 1.0 is imperative (push/pop). Navigator 2.0 is declarative, URL-based, and better suited for web and deep linking. go_router simplifies 2.0.',
    'detailedAnswer':
        'Navigator 1.0 uses an imperative API:\n• Navigator.push(), Navigator.pop()\n• Simple stack-based navigation\n• Difficult to handle deep links and web URLs\n• No way to declaratively define the navigation state\n\nNavigator 2.0 (Router API) is declarative:\n• Navigation state is a function of app state\n• Supports deep linking and web URLs natively\n• Uses Router, RouteInformationParser, and RouterDelegate\n• Very verbose and complex to implement directly\n\ngo_router simplifies Navigator 2.0:\n• Declarative route definitions\n• URL-based navigation with context.go()\n• Support for redirects, guards, and nested navigation\n• Path parameters and query parameters\n• Much simpler API than raw Navigator 2.0\n\nIn PrepAI, I use go_router with auth-based redirects. The router listens to auth state changes and automatically redirects users to login or home.',
  },
  {
    'title': 'What is the Provider pattern and how does it work?',
    'category': 'flutter',
    'difficulty': 'medium',
    'shortAnswer':
        'Provider is a wrapper around InheritedWidget for dependency injection and state management. It makes data available to descendants without prop drilling.',
    'detailedAnswer':
        'Provider is the officially recommended state management solution for Flutter. It builds on InheritedWidget to provide a clean way to:\n\n1. Inject dependencies — Services, repositories, and ViewModels are created at the top of the widget tree and accessed anywhere below.\n\n2. Listen to changes — When a ChangeNotifier calls notifyListeners(), only widgets that are watching it rebuild.\n\nKey classes:\n• Provider — Injects a value without listening to changes\n• ChangeNotifierProvider — Creates and disposes a ChangeNotifier\n• MultiProvider — Combines multiple providers\n• Consumer — Rebuilds when the provided value changes\n• Selector — Rebuilds only when a specific property changes\n\nUsage patterns:\n• context.watch<T>() — Listens and rebuilds on changes (in build())\n• context.read<T>() — Reads without listening (in callbacks)\n• context.select<T, R>() — Listens to specific property only\n\nBest practices: Use read() for event handlers, watch() for building UI, and never call watch() inside callbacks.',
  },
  {
    'title': 'What is a Future and a Stream in Dart?',
    'category': 'flutter',
    'difficulty': 'easy',
    'shortAnswer':
        'A Future represents a single async value that will be available later. A Stream represents a sequence of async events over time.',
    'detailedAnswer':
        'Future — Represents a computation that will complete with a value or error in the future. Used for one-time async operations:\n• API calls: Future<Response> fetchData()\n• File I/O: Future<String> readFile()\n• Use async/await or .then()/.catchError()\n• FutureBuilder widget displays UI based on Future state\n\nStream — A sequence of asynchronous events that arrive over time. Used for continuous data:\n• Firestore real-time listeners\n• WebSocket connections\n• User input events\n• Use await for loops or StreamBuilder widget\n\nKey differences:\n• Future: one value, completes once\n• Stream: multiple values, can emit indefinitely\n• Future: async/await\n• Stream: listen(), await for, StreamBuilder\n\nIn Flutter, StreamBuilder and FutureBuilder are the primary widgets for consuming async data. Always handle loading, error, and data states.',
  },
  {
    'title': 'How does Flutter rendering work under the hood?',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'Flutter uses three trees: Widget tree (configuration), Element tree (lifecycle), and RenderObject tree (layout/painting). The framework reconciles changes efficiently.',
    'detailedAnswer':
        'Flutter\'s rendering pipeline uses three parallel trees:\n\n1. Widget Tree — Immutable configuration objects. Cheap to create and destroy. Describes what the UI should look like.\n\n2. Element Tree — Mutable objects that manage the lifecycle. Each Element holds a reference to a Widget and a RenderObject. Elements are reused across rebuilds when possible (this is where Keys matter).\n\n3. RenderObject Tree — Handles layout (size and position) and painting (drawing to canvas). This is where the actual pixels are computed.\n\nWhen setState() is called:\n1. Widget tree is rebuilt (new Widget objects created)\n2. Element tree reconciles — compares old and new widgets\n3. If widget type and key match, Element updates its widget reference\n4. If they don\'t match, old Element is unmounted and new one created\n5. Dirty RenderObjects are re-laid-out and repainted\n6. The composited layers are sent to the Skia engine for rasterization\n\nThis architecture is what makes Flutter fast — only dirty parts of the tree are processed, and the three-tree structure enables efficient reconciliation.',
  },

  // ═══════════════════════════════════════════════════════════
  // HR QUESTIONS
  // ═══════════════════════════════════════════════════════════
  {
    'title': 'Tell me about yourself',
    'category': 'hr',
    'difficulty': 'easy',
    'shortAnswer':
        'Structure your answer: Present (current role/studies), Past (relevant experience), Future (why this role). Keep it under 2 minutes.',
    'detailedAnswer':
        'This is the most common opening question. Use the Present-Past-Future framework:\n\nPresent: "I\'m a Computer Science student at [University], specializing in mobile development with Flutter. I\'ve been actively building apps for the past year."\n\nPast: "I\'ve completed 3 projects using Flutter and Firebase, including an interview preparation app that demonstrates MVVM architecture, Provider state management, and clean code practices. I\'ve also contributed to open-source Flutter packages."\n\nFuture: "I\'m excited about this Flutter internship because I want to work on production-scale applications, learn industry best practices, and contribute to real products that impact users."\n\nTips:\n• Keep it under 2 minutes\n• Focus on professional background, not personal\n• Quantify achievements (3 projects, 500+ users, etc.)\n• Always end with why you\'re interested in THIS role\n• Practice but don\'t memorize — sound natural',
  },
  {
    'title': 'What are your strengths and weaknesses?',
    'category': 'hr',
    'difficulty': 'easy',
    'shortAnswer':
        'For strengths: specific examples with impact. For weaknesses: genuine but non-critical, show active improvement.',
    'detailedAnswer':
        'Strengths — Pick 2-3 directly relevant to the role:\n"One of my key strengths is systematic problem-solving. When building PrepAI, I designed the architecture using MVVM pattern, separating concerns into Models, Services, Repositories, and ViewModels. This made the codebase maintainable and testable."\n\nAnother: "I\'m a fast learner. I taught myself Flutter in 3 months and built 3 production-quality projects. I actively follow Flutter\'s release notes and adapt to new features."\n\nWeaknesses — Be authentic + show growth:\n"I sometimes over-engineer solutions on the first pass. I\'ve learned to follow the principle of \'make it work, make it right, make it fast\' — shipping a working version first, then iterating. This improved my delivery speed significantly."\n\nRules:\n• Never say \"I\'m a perfectionist\" or \"I work too hard\"\n• Choose a real weakness that\'s not critical to the role\n• Always describe what you\'re doing to improve\n• Back strengths with specific project examples',
  },
  {
    'title': 'Why do you want to work at this company?',
    'category': 'hr',
    'difficulty': 'medium',
    'shortAnswer':
        'Research the company. Connect their mission, tech stack, and culture to your goals. Show genuine interest beyond just getting a job.',
    'detailedAnswer':
        'Structure your answer around three pillars:\n\n1. Company Mission/Product:\n"I\'m drawn to [Company] because of [specific product/mission]. I\'ve used your app and noticed [specific feature]. The focus on [value] resonates with me."\n\n2. Technology & Growth:\n"Your engineering blog about [topic] showed me that your team values [technical excellence/innovation]. Working with Flutter at scale here would accelerate my learning significantly."\n\n3. Culture & Team:\n"I appreciate that [Company] invests in intern development through [mentorship/projects/talks]. I want to be in an environment where I can contribute meaningfully while learning from experienced engineers."\n\nPreparation tips:\n• Read their engineering blog and tech talks\n• Try their product and note specific features\n• Check their GitHub for open-source contributions\n• Look at recent news or funding rounds\n• Connect their values to your personal goals\n\nAvoid: Generic answers like \"I want to learn\" or \"It\'s a great company\"',
  },
  {
    'title': 'Where do you see yourself in 5 years?',
    'category': 'hr',
    'difficulty': 'medium',
    'shortAnswer':
        'Show ambition aligned with the company\'s growth path. Focus on skills you want to develop and impact you want to make.',
    'detailedAnswer':
        'Good framework: Skills → Impact → Growth\n\n"In 5 years, I see myself as a senior mobile developer who can architect and lead the development of complex Flutter applications. I want to:\n\n1. Technical Depth: Master advanced Flutter concepts — custom render objects, platform channels, performance optimization. Understand mobile development deeply enough to make architectural decisions.\n\n2. Leadership: Mentor junior developers and contribute to engineering best practices. I believe growing technically also means helping others grow.\n\n3. Product Impact: Work on features that directly impact users. I want to understand the product side deeply enough to propose solutions, not just implement them.\n\n4. Community: Contribute to the Flutter open-source community through packages, articles, or conference talks."\n\nKey principles:\n• Show growth trajectory, not specific titles\n• Align with company\'s possible evolution\n• Demonstrate long-term commitment\n• Mix technical and soft skill development\n• Be ambitious but realistic',
  },
  {
    'title': 'Tell me about a challenging project and how you handled it',
    'category': 'hr',
    'difficulty': 'medium',
    'shortAnswer':
        'Use the STAR method: Situation, Task, Action, Result. Focus on the challenge, your specific contribution, and what you learned.',
    'detailedAnswer':
        'Use the STAR framework:\n\nSituation: "While building PrepAI, I needed to implement a bookmark system that syncs across devices using Firestore while providing instant UI feedback."\n\nTask: "The challenge was handling the optimistic UI update pattern — showing the bookmark immediately while syncing with the server in the background, and gracefully handling failures."\n\nAction: "I implemented a three-layer approach:\n1. Optimistic UI — Update the local Set<String> of bookmarked IDs immediately\n2. Firestore sync — Toggle the bookmark in the database asynchronously\n3. Error recovery — If the Firestore operation fails, revert the optimistic update by reloading from the server\n\nI also used a Set for O(1) bookmark lookups instead of querying Firestore on every card render."\n\nResult: "The bookmark toggle feels instant to users while maintaining data consistency. I learned the importance of designing for offline-first and handling edge cases in async operations."\n\nTips:\n• Choose a technical challenge, not a people problem\n• Quantify the result if possible\n• Show what you learned\n• Be specific about YOUR contribution',
  },
  {
    'title': 'How do you handle feedback and criticism?',
    'category': 'hr',
    'difficulty': 'easy',
    'shortAnswer':
        'Welcome constructive feedback as a growth tool. Listen actively, ask clarifying questions, and apply improvements. Give a specific example.',
    'detailedAnswer':
        'Framework: Mindset → Process → Example\n\nMindset: "I view feedback as one of the fastest ways to grow. In code reviews especially, I\'ve learned that different perspectives lead to better solutions."\n\nProcess: "When I receive feedback, I:\n1. Listen fully without getting defensive\n2. Ask clarifying questions to understand the concern\n3. Take notes and identify actionable items\n4. Implement changes and follow up\n\nExample: "During a project review, a mentor pointed out that my ViewModel was doing too much — fetching data, formatting strings, and handling navigation. It was becoming a \'God class.\' I restructured the code by moving data formatting to helper utilities and keeping the ViewModel focused on state management. This made the code more testable and maintainable."\n\nKey points:\n• Show emotional maturity\n• Demonstrate growth from feedback\n• Never badmouth previous reviewers\n• Frame feedback as opportunity, not criticism\n• Show you actively seek feedback, not just receive it',
  },

  // ═══════════════════════════════════════════════════════════
  // DSA QUESTIONS
  // ═══════════════════════════════════════════════════════════
  {
    'title': 'What is Time Complexity and Big O notation?',
    'category': 'dsa',
    'difficulty': 'easy',
    'shortAnswer':
        'Time complexity describes algorithm efficiency relative to input size. Big O notation represents the upper bound growth rate: O(1), O(log n), O(n), O(n²).',
    'detailedAnswer':
        'Time complexity measures how the running time of an algorithm grows with input size (n).\n\nBig O notation represents the worst-case upper bound:\n\n• O(1) — Constant: Array access, HashMap get/put\n• O(log n) — Logarithmic: Binary search, balanced BST operations\n• O(n) — Linear: Single loop, linear search\n• O(n log n) — Linearithmic: Merge sort, quicksort (average)\n• O(n²) — Quadratic: Nested loops, bubble/selection/insertion sort\n• O(2ⁿ) — Exponential: Recursive Fibonacci, power set\n• O(n!) — Factorial: Permutations, traveling salesman brute force\n\nRules for calculation:\n1. Drop constants: O(2n) → O(n)\n2. Drop lower-order terms: O(n² + n) → O(n²)\n3. Different inputs use different variables: O(a + b), not O(n)\n4. Sequential operations add: O(a + b)\n5. Nested operations multiply: O(a × b)\n\nAlways analyze both TIME and SPACE complexity. Sometimes you can trade space for time (e.g., HashSet for O(1) lookups vs O(n) linear search).',
  },
  {
    'title': 'Explain Arrays vs Linked Lists',
    'category': 'dsa',
    'difficulty': 'easy',
    'shortAnswer':
        'Arrays provide O(1) random access but O(n) insertion/deletion. Linked Lists provide O(1) insertion/deletion at known positions but O(n) access.',
    'detailedAnswer':
        'Arrays:\n• Stored in contiguous memory blocks\n• O(1) random access by index\n• O(n) insertion/deletion (need to shift elements)\n• Fixed size (or dynamic with amortized O(1) append)\n• Better cache performance (spatial locality)\n• In Dart: List<T>\n\nLinked Lists:\n• Nodes stored in scattered memory locations\n• O(n) access (must traverse from head)\n• O(1) insertion/deletion at a known node\n• Dynamic size, no wasted memory\n• Types: Singly, Doubly, Circular\n\nWhen to use what:\n• Array: Random access needed, mostly reads, known size\n• Linked List: Frequent insertions/deletions, unknown size\n\nIn practice, arrays (dynamic arrays / List) are preferred in most cases because:\n1. CPU cache locality makes arrays faster in practice\n2. Modern dynamic arrays have amortized O(1) append\n3. Linked lists have higher memory overhead (pointers)\n4. Most languages optimize array operations heavily\n\nIn Dart, List<T> is a dynamic array. There\'s no built-in LinkedList in the core library.',
  },
  {
    'title': 'What is a HashMap and how does it work?',
    'category': 'dsa',
    'difficulty': 'medium',
    'shortAnswer':
        'A HashMap stores key-value pairs using a hash function for O(1) average access. Collisions are handled via chaining or open addressing.',
    'detailedAnswer':
        'HashMap (Map<K,V> in Dart) provides O(1) average-case access, insertion, and deletion.\n\nHow it works:\n1. Hash Function: Converts the key into an integer (hash code)\n2. Index Mapping: hash_code % array_size = bucket index\n3. Storage: Store key-value pair at that bucket\n4. Retrieval: Same hash → same bucket → find the value\n\nCollision Handling:\n• Chaining: Each bucket holds a linked list of entries\n• Open Addressing: If bucket is occupied, probe next bucket\n  - Linear probing: check next slot\n  - Quadratic probing: check i² slots ahead\n  - Double hashing: use second hash function\n\nPerformance:\n• Average: O(1) for get, put, remove\n• Worst case: O(n) if all keys hash to same bucket\n• Load factor = entries / capacity (usually resize at 0.75)\n\nIn Dart:\n• Map<K, V> — Default implementation is LinkedHashMap (insertion order)\n• HashMap<K, V> — Unordered, from dart:collection\n• SplayTreeMap — Sorted by key, O(log n) operations\n\nCommon interview patterns:\n• Two Sum: Use HashMap for O(1) complement lookup\n• Frequency counting: Map<element, count>\n• Caching/memoization\n• Grouping elements by property',
  },
  {
    'title': 'Explain Binary Search and its applications',
    'category': 'dsa',
    'difficulty': 'medium',
    'shortAnswer':
        'Binary Search finds a target in a sorted array in O(log n) time by repeatedly halving the search space. Requires the array to be sorted.',
    'detailedAnswer':
        'Binary Search is a divide-and-conquer algorithm:\n\n1. Start with the entire sorted array\n2. Compare target with middle element\n3. If equal: found it\n4. If target < middle: search left half\n5. If target > middle: search right half\n6. Repeat until found or search space is empty\n\nImplementation:\n```\nint binarySearch(List<int> arr, int target) {\n  int left = 0, right = arr.length - 1;\n  while (left <= right) {\n    int mid = left + (right - left) ~/ 2; // Prevents overflow\n    if (arr[mid] == target) return mid;\n    else if (arr[mid] < target) left = mid + 1;\n    else right = mid - 1;\n  }\n  return -1; // Not found\n}\n```\n\nComplexity: O(log n) time, O(1) space\n\nVariations:\n• Lower bound: First occurrence of target\n• Upper bound: Last occurrence of target\n• Search in rotated sorted array\n• Finding peak element\n• Search in 2D sorted matrix\n\nApplications:\n• Database indexing (B-trees use similar principle)\n• Finding elements in sorted collections\n• Optimization problems (binary search on answer)\n• Git bisect (finding the commit that introduced a bug)',
  },
  {
    'title': 'What are the common sorting algorithms and their complexities?',
    'category': 'dsa',
    'difficulty': 'hard',
    'shortAnswer':
        'Key sorts: Bubble O(n²), Selection O(n²), Insertion O(n²), Merge O(n log n), Quick O(n log n avg), Heap O(n log n). Merge and Quick are most practical.',
    'detailedAnswer':
        'Sorting algorithms comparison:\n\n1. Bubble Sort — O(n²)\n   Repeatedly swap adjacent elements if out of order.\n   Simple but inefficient. Only useful for small/nearly-sorted data.\n\n2. Selection Sort — O(n²)\n   Find minimum, place at beginning, repeat.\n   Minimal swaps but still O(n²) comparisons.\n\n3. Insertion Sort — O(n²) worst, O(n) best\n   Insert each element into its correct position.\n   Excellent for nearly sorted data and small arrays.\n\n4. Merge Sort — O(n log n) guaranteed\n   Divide array in half, sort each half, merge.\n   Stable sort, predictable performance.\n   Requires O(n) extra space.\n\n5. Quick Sort — O(n log n) average, O(n²) worst\n   Pick pivot, partition around it, recurse.\n   In-place (O(log n) stack space). Fastest in practice.\n   Worst case with bad pivot selection.\n\n6. Heap Sort — O(n log n) guaranteed\n   Build max heap, repeatedly extract max.\n   In-place but not stable. Rarely used in practice.\n\nIn Dart, List.sort() uses a dual-pivot quicksort (for large arrays) and insertion sort (for small arrays). This hybrid approach combines the best of both.',
  },

  // ═══════════════════════════════════════════════════════════
  // FIREBASE QUESTIONS
  // ═══════════════════════════════════════════════════════════
  {
    'title': 'What is Firebase and what services does it provide?',
    'category': 'firebase',
    'difficulty': 'easy',
    'shortAnswer':
        'Firebase is Google\'s mobile development platform providing authentication, databases (Firestore, Realtime DB), storage, hosting, cloud functions, and analytics.',
    'detailedAnswer':
        'Firebase is a Backend-as-a-Service (BaaS) platform by Google that provides ready-made backend services:\n\nCore Services:\n• Authentication — Email, Google, Apple, phone sign-in\n• Cloud Firestore — NoSQL document database with real-time sync\n• Realtime Database — JSON-based real-time database (legacy)\n• Cloud Storage — File storage for user-generated content\n• Cloud Functions — Serverless backend logic\n• Hosting — Static web hosting with CDN\n\nGrowth & Analytics:\n• Analytics — User behavior tracking\n• Crashlytics — Crash reporting and analysis\n• Performance Monitoring — App performance metrics\n• Remote Config — A/B testing and feature flags\n• Cloud Messaging — Push notifications\n\nWhy Firebase for mobile:\n1. No server management needed\n2. Real-time data synchronization\n3. Built-in offline support\n4. Scales automatically\n5. Free tier generous enough for MVPs\n6. Excellent Flutter SDK (FlutterFire)\n\nIn PrepAI, I use three Firebase services:\n• Authentication — Email/password sign-up and login\n• Cloud Firestore — Storing users, questions, and bookmarks\n• (Architecture ready for Cloud Functions for real AI integration)',
  },
  {
    'title': 'Explain Cloud Firestore data model and best practices',
    'category': 'firebase',
    'difficulty': 'medium',
    'shortAnswer':
        'Firestore uses collections of documents. Documents contain fields and subcollections. Design data based on query patterns, not relationships.',
    'detailedAnswer':
        'Firestore Data Model:\n\n• Database → Collections → Documents → Fields + Subcollections\n• Collections are groups of documents (like SQL tables)\n• Documents are individual records (like SQL rows)\n• Documents can contain subcollections (nested data)\n• No fixed schema — each document can have different fields\n\nData Types: string, number, boolean, map, array, timestamp, geopoint, reference, null\n\nBest Practices:\n\n1. Design for queries: Structure data based on how you\'ll read it, not logical relationships. If you always fetch user + their bookmarks, consider embedding.\n\n2. Denormalize: Duplicate data across documents to avoid expensive joins. Update duplicates with Cloud Functions or batch writes.\n\n3. Keep documents small: Max 1MB per document. Store large data in subcollections.\n\n4. Use composite indexes: Firestore requires indexes for complex queries. Define them in firestore.indexes.json.\n\n5. Batch writes: Use batched writes for atomic multi-document updates (max 500 operations).\n\n6. Security rules: Always validate data structure and user ownership. Never rely on client-side validation alone.\n\nIn PrepAI:\n• users/{uid} — User profiles\n• questions/{id} — Interview questions (read-only for users)\n• bookmarks/{id} — User-question relationships',
  },
  {
    'title': 'What are Firestore Security Rules and why are they important?',
    'category': 'firebase',
    'difficulty': 'medium',
    'shortAnswer':
        'Security Rules are server-side access control that determine who can read/write data. They validate authentication, authorization, and data structure.',
    'detailedAnswer':
        'Firestore Security Rules run on Google\'s servers and evaluate every read/write request. They are the ONLY real security layer — client-side validation can be bypassed.\n\nStructure:\n```\nrules_version = \'2\';\nservice cloud.firestore {\n  match /databases/{database}/documents {\n    match /collection/{docId} {\n      allow read, write: if <condition>;\n    }\n  }\n}\n```\n\nKey concepts:\n\n1. Authentication check:\n   `request.auth != null` — Is the user logged in?\n   `request.auth.uid` — The authenticated user\'s ID\n\n2. Ownership validation:\n   `resource.data.userId == request.auth.uid` — Does this document belong to the user?\n\n3. Data validation:\n   `request.resource.data.name is string` — Validate field types\n   `request.resource.data.name.size() <= 100` — Validate field length\n\n4. Custom claims:\n   `request.auth.token.role == \'admin\'` — Role-based access\n\nBest practices:\n• Always start with default-deny\n• Validate every field in create/update rules\n• Use helper functions for repeated logic\n• Test with the Firebase Emulator Suite\n• Keep rules as simple as possible\n• Never allow unrestricted write access\n\nCommon mistake: Using test mode rules (allow read, write: if true) in production — this exposes ALL data to anyone.',
  },
  {
    'title': 'What is Firebase Authentication and how does it work?',
    'category': 'firebase',
    'difficulty': 'easy',
    'shortAnswer':
        'Firebase Auth provides backend services for user authentication. Supports email/password, Google, Apple, phone, and anonymous sign-in with secure token management.',
    'detailedAnswer':
        'Firebase Authentication manages the complete auth lifecycle:\n\n1. Sign Up: Creates a user account and stores credentials securely\n2. Sign In: Verifies credentials and issues an ID token\n3. Token Management: Automatically refreshes tokens (valid for 1 hour)\n4. Sign Out: Invalidates the session\n\nSupported providers:\n• Email/Password — Most common for MVPs\n• Google Sign-In — One-tap authentication\n• Apple Sign-In — Required for iOS apps with third-party auth\n• Phone — SMS verification codes\n• Anonymous — Temporary accounts for try-before-sign-up\n\nFlutter integration:\n```dart\n// Sign up\nawait FirebaseAuth.instance.createUserWithEmailAndPassword(\n  email: email, password: password\n);\n\n// Sign in\nawait FirebaseAuth.instance.signInWithEmailAndPassword(\n  email: email, password: password\n);\n\n// Listen to auth state\nFirebaseAuth.instance.authStateChanges().listen((user) {\n  if (user != null) { /* logged in */ }\n});\n```\n\nBest practices:\n• Always listen to authStateChanges() for reactive auth state\n• Handle all FirebaseAuthException codes with user-friendly messages\n• Use Custom Claims for role-based access (admin, premium)\n• Implement password reset and email verification\n• Combine with Firestore to store additional user data (name, profile)',
  },
  {
    'title': 'Explain the difference between Firestore and Realtime Database',
    'category': 'firebase',
    'difficulty': 'medium',
    'shortAnswer':
        'Firestore is the modern choice with rich queries, collections/documents, better scaling, and offline support. Realtime Database is a single JSON tree with simpler pricing.',
    'detailedAnswer':
        'Cloud Firestore vs Realtime Database:\n\nData Model:\n• Firestore: Collections → Documents → Fields + Subcollections\n• RTDB: Single JSON tree (deeply nested)\n\nQuerying:\n• Firestore: Rich queries with compound filters, ordering, pagination\n• RTDB: Limited queries, can only filter/sort on one property\n\nScaling:\n• Firestore: Scales automatically to millions of concurrent users\n• RTDB: Scales to ~200,000 concurrent connections per database\n\nOffline Support:\n• Firestore: Full offline support on mobile (built-in)\n• RTDB: Limited offline (single listener, not full query support)\n\nPricing:\n• Firestore: Per document read/write/delete + storage\n• RTDB: Per data downloaded + storage (can be cheaper for frequent small reads)\n\nWhen to use Firestore:\n• New projects (recommended default)\n• Complex data models\n• Advanced querying needs\n• Global scalability requirements\n\nWhen to use RTDB:\n• Simple data structure (chat messages)\n• Very frequent small updates\n• Cost-sensitive with high read volume\n• Existing projects already using it\n\nFor PrepAI, Firestore is the clear choice: structured data (users, questions, bookmarks), compound queries (filter by category + difficulty), and automatic offline support.',
  },
  {
    'title': 'How do you handle offline data in Firebase?',
    'category': 'firebase',
    'difficulty': 'hard',
    'shortAnswer':
        'Firestore has built-in offline persistence on mobile. Data is cached locally, reads work offline, and writes queue up and sync when reconnected.',
    'detailedAnswer':
        'Firestore Offline Persistence:\n\nOn mobile (iOS/Android), offline persistence is enabled by default. On web, you need to explicitly enable it.\n\nHow it works:\n1. Reads: Firestore caches all documents the app has read. If offline, reads are served from cache.\n2. Writes: If offline, writes are queued locally and synced when the device reconnects. They appear in local snapshots immediately.\n3. Listeners: Snapshot listeners work offline and fire with cached data.\n\nConfiguration:\n```dart\n// Already enabled by default on mobile\nFirebaseFirestore.instance.settings = const Settings(\n  persistenceEnabled: true, // default: true on mobile\n  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,\n);\n```\n\nHandling offline scenarios:\n1. Optimistic updates — UI reflects changes immediately\n2. Pending writes indicator — Show sync status to users\n3. Conflict resolution — Last-write-wins by default\n4. Server timestamps — Use FieldValue.serverTimestamp() for consistent ordering\n\nBest practices:\n• Design for offline-first on mobile\n• Use snapshot listeners instead of one-time reads for real-time updates\n• Handle the case where cache is empty (first launch)\n• Set reasonable cache sizes to manage disk usage\n• Test with airplane mode during development\n\nLimitation: Complex compound queries may not work offline if the required index isn\'t cached. Simple queries on cached data work reliably.',
  },

  // ═══════════════════════════════════════════════════════════
  // ADDITIONAL MIXED QUESTIONS
  // ═══════════════════════════════════════════════════════════
  {
    'title': 'What is MVVM Architecture in Flutter?',
    'category': 'flutter',
    'difficulty': 'medium',
    'shortAnswer':
        'MVVM separates UI (View) from business logic (ViewModel) and data (Model). ViewModels use ChangeNotifier to update Views reactively.',
    'detailedAnswer':
        'MVVM (Model-View-ViewModel) in Flutter:\n\nModel: Pure Dart classes representing data entities. Handle serialization (fromJson/toJson). No Flutter dependencies.\n\nView: Flutter widgets that render UI. They are "dumb" — only display data from ViewModels and forward user actions. No business logic.\n\nViewModel: ChangeNotifier classes that:\n• Hold UI state (loading, error, data)\n• Call repositories for data operations\n• Expose data via getters\n• Notify listeners when state changes\n\nAdditional layers I use:\n• Services: Direct API/database interaction (AuthService, FirestoreService)\n• Repositories: Coordinate between services, handle caching and business rules\n\nData flow: View → ViewModel → Repository → Service → Firebase\n\nBenefits:\n1. Testability: Each layer can be tested independently with mocks\n2. Maintainability: Changes in one layer don\'t affect others\n3. Separation of concerns: UI developers focus on views, logic developers on viewmodels\n4. Reusability: ViewModels can be shared across different views\n\nIn PrepAI, each screen has its own ViewModel, and ViewModels receive Repositories through constructor injection.',
  },
  {
    'title': 'How do you handle errors in a production Flutter app?',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'Use try-catch in ViewModels, expose error state to Views, show user-friendly messages, and log errors for debugging. Handle both sync and async errors.',
    'detailedAnswer':
        'Error handling strategy for production Flutter apps:\n\n1. ViewModel Layer — Try-catch around all async operations:\n```dart\nFuture<void> loadData() async {\n  _isLoading = true;\n  _errorMessage = null;\n  notifyListeners();\n  try {\n    _data = await repository.getData();\n  } catch (e) {\n    _errorMessage = _getErrorMessage(e);\n  } finally {\n    _isLoading = false;\n    notifyListeners();\n  }\n}\n```\n\n2. User-Friendly Messages — Map technical errors to human-readable text. Never show stack traces to users.\n\n3. View Layer — Three states for every data display:\n• Loading: Show shimmer or spinner\n• Error: Show error message with retry button\n• Data: Show the content\n• Empty: Show empty state with call-to-action\n\n4. Global Error Handling:\n```dart\nFlutterError.onError = (details) {\n  // Log to Crashlytics\n  FirebaseCrashlytics.instance.recordFlutterFatalError(details);\n};\n\nPlatformDispatcher.instance.onError = (error, stack) {\n  // Handle platform errors\n  return true;\n};\n```\n\n5. Network Errors — Check connectivity, show offline banners, retry logic with exponential backoff.\n\n6. Firebase-Specific — Map FirebaseException codes to user messages. Handle token expiration, permission denied, and quota exceeded.\n\nKey principle: Users should always know what happened and what they can do about it.',
  },
  {
    'title': 'Explain Dependency Injection in Flutter',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'DI is providing dependencies from outside rather than creating them internally. In Flutter, use Provider or get_it for constructor injection.',
    'detailedAnswer':
        'Dependency Injection (DI) is a design pattern where objects receive their dependencies from external sources rather than creating them internally.\n\nWithout DI (tightly coupled):\n```dart\nclass AuthViewModel {\n  final authService = AuthService(); // Creates its own dependency\n}\n```\n\nWith DI (loosely coupled):\n```dart\nclass AuthViewModel {\n  final AuthRepository _authRepo;\n  AuthViewModel({required AuthRepository authRepository})\n    : _authRepo = authRepository; // Receives dependency\n}\n```\n\nBenefits:\n1. Testability: Pass mock repositories in tests\n2. Flexibility: Swap implementations without changing consumers\n3. Single instance: Services shared across ViewModels\n4. Clear dependencies: Constructor shows what a class needs\n\nDI in Flutter with Provider:\n```dart\nMultiProvider(\n  providers: [\n    ChangeNotifierProvider(\n      create: (_) => AuthViewModel(\n        authRepository: AuthRepository(\n          authService: AuthService(),\n          firestoreService: FirestoreService(),\n        ),\n      ),\n    ),\n  ],\n)\n```\n\nAlternatives:\n• get_it — Service locator pattern, doesn\'t need BuildContext\n• injectable — Code generation for get_it\n• riverpod — Built-in dependency management\n\nIn PrepAI, I use constructor injection with Provider: Services are created in main.dart, injected into Repositories, which are injected into ViewModels.',
  },
  {
    'title': 'What is a Stack and when do you use it?',
    'category': 'dsa',
    'difficulty': 'easy',
    'shortAnswer':
        'A Stack is a LIFO data structure. Operations: push (add to top), pop (remove from top), peek (view top). Used in undo, backtracking, and expression parsing.',
    'detailedAnswer':
        'Stack — Last In, First Out (LIFO) data structure.\n\nOperations (all O(1)):\n• push(item) — Add to top\n• pop() — Remove and return top\n• peek/top() — View top without removing\n• isEmpty() — Check if empty\n\nIn Dart, use List<T> as a stack:\n```dart\nfinal stack = <int>[];\nstack.add(1);        // push\nstack.removeLast();  // pop\nstack.last;          // peek\n```\n\nApplications:\n1. Function call stack — How recursion works internally\n2. Undo/Redo — Each action pushed, undo pops\n3. Browser history — Back button pops from stack\n4. Expression evaluation — Infix to postfix conversion\n5. Balanced parentheses — Push open, pop on close\n6. DFS traversal — Iterative depth-first search\n7. Flutter Navigator — Route stack management\n\nInterview patterns:\n• Valid Parentheses: Use stack to match brackets\n• Min Stack: O(1) getMin by maintaining parallel min stack\n• Next Greater Element: Monotonic stack pattern\n• Evaluate Reverse Polish Notation: Operands on stack\n\nIn Flutter, Navigator.push/pop is literally a stack of routes. Understanding stacks helps understand Flutter navigation deeply.',
  },
  {
    'title': 'What is a Queue and how does it differ from a Stack?',
    'category': 'dsa',
    'difficulty': 'easy',
    'shortAnswer':
        'A Queue is a FIFO data structure. Elements are added at the rear and removed from the front. Used in BFS, task scheduling, and message processing.',
    'detailedAnswer':
        'Queue — First In, First Out (FIFO) data structure.\n\nOperations:\n• enqueue(item) — Add to rear — O(1)\n• dequeue() — Remove from front — O(1)\n• peek/front() — View front without removing — O(1)\n• isEmpty() — Check if empty — O(1)\n\nIn Dart:\n```dart\nimport \'dart:collection\';\nfinal queue = Queue<int>();\nqueue.add(1);         // enqueue\nqueue.removeFirst();  // dequeue\nqueue.first;          // peek\n```\n\nStack vs Queue:\n• Stack: LIFO (plates) — push/pop from same end\n• Queue: FIFO (line at store) — add at back, remove from front\n\nTypes of Queues:\n1. Simple Queue — Basic FIFO\n2. Circular Queue — Front and rear wrap around\n3. Priority Queue — Elements have priority, highest served first\n4. Deque (Double-ended Queue) — Add/remove from both ends\n\nApplications:\n1. BFS traversal — Level-by-level graph exploration\n2. Task scheduling — OS process scheduling\n3. Message queues — Async communication between services\n4. Print queue — Documents printed in order\n5. Rate limiting — Process requests at controlled rate\n\nInterview patterns:\n• BFS: Level-order tree traversal\n• Sliding Window Maximum: Monotonic deque\n• Implement Queue using Stacks (and vice versa)\n• Design Hit Counter',
  },
  {
    'title': 'How do you handle app state persistence in Flutter?',
    'category': 'flutter',
    'difficulty': 'medium',
    'shortAnswer':
        'Use SharedPreferences for simple key-value data, Hive/SQLite for complex local data, and Firebase Firestore for cloud-synced data.',
    'detailedAnswer':
        'State persistence options in Flutter:\n\n1. SharedPreferences — Key-value storage for simple data\n   • Login state, user preferences, feature flags\n   • Supports: bool, int, double, String, List<String>\n   • Async read/write\n   • Platform: NSUserDefaults (iOS), SharedPreferences (Android)\n\n2. Hive — NoSQL local database\n   • Fast, encrypted, type-safe\n   • Good for structured data that doesn\'t need cloud sync\n   • Custom TypeAdapters for model serialization\n\n3. SQLite (sqflite package) — Relational local database\n   • Complex queries, joins, transactions\n   • Good for offline-first apps with complex data relationships\n\n4. Cloud Firestore — Cloud database with local caching\n   • Automatic offline persistence on mobile\n   • Real-time sync across devices\n   • Best for data that needs to be shared or backed up\n\nIn PrepAI, I use a combination:\n• SharedPreferences: Login state persistence (\"keep me logged in\")\n• Firestore: User profiles, questions, bookmarks (cloud-synced)\n• In-memory cache: Question list cached in repository for fast filtering\n\nBest practice: Choose the simplest storage that meets your requirements. Don\'t use SQLite when SharedPreferences suffices. Don\'t sync everything to the cloud when local storage is enough.',
  },
  {
    'title': 'How would you optimize a Flutter app for performance?',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'Use const constructors, minimize rebuilds with Selector/Consumer, lazy-load data, compress images, use ListView.builder, and profile with DevTools.',
    'detailedAnswer':
        'Flutter Performance Optimization Checklist:\n\n1. Widget Rebuilds:\n   • Use const constructors wherever possible\n   • Use Selector instead of Consumer to rebuild only on specific changes\n   • Extract constant subtrees into separate const widgets\n   • Never create widgets inside build methods unnecessarily\n\n2. Lists:\n   • Use ListView.builder instead of ListView (lazy rendering)\n   • Use itemExtent for fixed-height items (skip layout calculation)\n   • Use const item widgets where possible\n   • Implement pagination for large lists\n\n3. Images:\n   • Resize images to display size before loading\n   • Use cached_network_image for network images\n   • Use WebP format for smaller file sizes\n   • Set cacheWidth/cacheHeight on Image widgets\n\n4. State Management:\n   • Avoid unnecessary notifyListeners() calls\n   • Use read() instead of watch() in callbacks\n   • Batch multiple state changes into single notifyListeners()\n\n5. Async Operations:\n   • Use Future.wait() for parallel async operations\n   • Implement caching in repositories\n   • Debounce search input\n\n6. Build-time Optimizations:\n   • Use --release flag for performance testing\n   • Enable tree-shaking\n   • Use deferred loading for large features\n\n7. Profiling Tools:\n   • Flutter DevTools — Performance overlay, timeline\n   • Widget Inspector — Rebuild tracking\n   • Memory profiler — Find memory leaks\n\nIn PrepAI, I use: const constructors, ListView.builder, Future.wait for parallel loading, in-memory caching in QuestionRepository, and Selector in critical paths.',
  },
  {
    'title': 'What is a Tree data structure? Explain Binary Trees',
    'category': 'dsa',
    'difficulty': 'medium',
    'shortAnswer':
        'A Tree is a hierarchical data structure with a root node and children. A Binary Tree has at most 2 children per node. BST enables O(log n) search.',
    'detailedAnswer':
        'Tree — Hierarchical data structure with nodes connected by edges.\n\nTerminology:\n• Root: Top node (no parent)\n• Leaf: Node with no children\n• Height: Longest path from root to leaf\n• Depth: Distance from root to a node\n• Degree: Number of children\n\nBinary Tree — Each node has at most 2 children (left and right).\n\nBinary Search Tree (BST):\n• Left subtree values < node value\n• Right subtree values > node value\n• Enables O(log n) search, insert, delete\n• Degenerates to O(n) if unbalanced (like a linked list)\n\nBalanced BSTs:\n• AVL Tree — Strictly balanced, O(log n) guaranteed\n• Red-Black Tree — Relaxed balance, used in most standard libraries\n• Dart\'s SplayTreeMap uses a splay tree internally\n\nTraversals:\n1. In-order (Left, Root, Right) — Produces sorted output for BST\n2. Pre-order (Root, Left, Right) — Used for serialization\n3. Post-order (Left, Right, Root) — Used for deletion\n4. Level-order (BFS) — Level by level, uses queue\n\nCommon Interview Problems:\n• Maximum depth of binary tree\n• Check if tree is balanced\n• Lowest common ancestor\n• Serialize/deserialize binary tree\n• Path sum problems\n\nIn Flutter\'s widget tree, the rendering system is essentially a tree — understanding tree traversal helps understand how Flutter walks the widget tree during builds.',
  },
  {
    'title': 'How do you structure a Flutter project for scalability?',
    'category': 'flutter',
    'difficulty': 'hard',
    'shortAnswer':
        'Use feature-based folder structure with clear separation of layers (data, domain, presentation). Follow SOLID principles and use dependency injection.',
    'detailedAnswer':
        'Scalable Flutter Project Structure:\n\n1. Layer-Based (suitable for small-medium apps):\n```\nlib/\n  core/        → Shared utilities, constants, theme\n  models/      → Data models\n  services/    → API/database interaction\n  repositories/→ Business logic, caching\n  viewmodels/  → UI state management\n  views/       → Screens\n  widgets/     → Reusable components\n```\n\n2. Feature-Based (better for larger apps):\n```\nlib/\n  core/\n  features/\n    auth/\n      data/\n      presentation/\n    home/\n      data/\n      presentation/\n```\n\nKey Principles:\n\n1. Separation of Concerns: Each layer has one responsibility\n2. Dependency Rule: Inner layers don\'t depend on outer layers\n3. Single Responsibility: One class, one purpose\n4. Interface Segregation: Small, focused interfaces\n5. Dependency Injection: Classes receive dependencies, don\'t create them\n\nScaling Tips:\n• Start simple (layer-based), refactor to feature-based when needed\n• Use barrel files for clean imports\n• Create reusable widget libraries\n• Document architecture decisions\n• Write tests for repositories and viewmodels first\n• Use code generation for boilerplate (freezed, json_serializable)\n\nIn PrepAI, I chose layer-based structure because it\'s appropriate for the project size. For a team of 5+ developers, I\'d switch to feature-based with shared core modules.',
  },
  {
    'title': 'Explain the concept of Recursion with examples',
    'category': 'dsa',
    'difficulty': 'medium',
    'shortAnswer':
        'Recursion is when a function calls itself with a smaller input until reaching a base case. Examples: factorial, Fibonacci, tree traversals, binary search.',
    'detailedAnswer':
        'Recursion — A function that solves a problem by calling itself with a smaller subproblem.\n\nTwo requirements:\n1. Base case — Stopping condition to prevent infinite recursion\n2. Recursive case — Breaks the problem into smaller subproblems\n\nExample — Factorial:\n```dart\nint factorial(int n) {\n  if (n <= 1) return 1;         // Base case\n  return n * factorial(n - 1);  // Recursive case\n}\n// factorial(5) = 5 * 4 * 3 * 2 * 1 = 120\n```\n\nHow it works:\n• Each call adds a frame to the call stack\n• Base case triggers the stack to unwind\n• Results propagate back up\n\nCommon Recursive Patterns:\n1. Linear recursion: factorial, linked list traversal\n2. Binary recursion: Fibonacci, merge sort\n3. Tree recursion: Tree traversals, combinatorics\n4. Backtracking: N-Queens, Sudoku solver, maze paths\n\nOptimization:\n• Memoization: Cache results to avoid recomputation\n• Tail recursion: Some languages optimize tail calls (not Dart)\n• Convert to iterative: Use explicit stack to avoid stack overflow\n\nRecursion vs Iteration:\n• Recursion: Cleaner for tree/graph problems\n• Iteration: Better performance, no stack overflow risk\n• Rule: Use recursion when the problem has a natural recursive structure\n\nDart has a default stack size limit. For deep recursion (>1000 levels), convert to iterative or increase stack size.',
  },
];
