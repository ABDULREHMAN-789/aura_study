import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/routes/route_names.dart';
import 'package:aura_study/features/dashboard/dashboard_screen.dart';
import 'package:aura_study/features/notes/notes_screen.dart';
import 'package:aura_study/features/ai/ai_screen.dart';
import 'package:aura_study/features/planner/planner_screen.dart';
import 'package:aura_study/features/profile/profile_screen.dart';
import 'package:aura_study/features/auth/presentation/screens/login_screen.dart';
import 'package:aura_study/features/auth/presentation/screens/register_screen.dart';
import 'package:aura_study/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';
import 'package:aura_study/shared/widgets/splash_screen.dart';
import 'package:aura_study/shared/widgets/onboarding_screen.dart';
import 'package:aura_study/shared/widgets/shell_scaffold.dart';
import 'package:aura_study/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:aura_study/features/pdf/presentation/screens/pdf_select_screen.dart';
import 'package:aura_study/features/pdf/presentation/screens/pdf_viewer_screen.dart';
import 'package:aura_study/features/voice/presentation/screens/voice_recorder_screen.dart';
import 'package:aura_study/features/quiz/presentation/screens/quiz_hub_screen.dart';
import 'package:aura_study/features/quiz/presentation/screens/quiz_arena_screen.dart';
import 'package:aura_study/features/quiz/presentation/screens/quiz_summary_screen.dart';
import 'package:aura_study/features/flashcards/presentation/screens/flashcard_hub_screen.dart';
import 'package:aura_study/features/flashcards/presentation/screens/flashcard_review_screen.dart';
import 'package:aura_study/features/export/export_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard_tab');
final GlobalKey<NavigatorState> _shellNotesKey = GlobalKey<NavigatorState>(debugLabel: 'notes_tab');
final GlobalKey<NavigatorState> _shellAIKey = GlobalKey<NavigatorState>(debugLabel: 'ai_tab');
final GlobalKey<NavigatorState> _shellPlannerKey = GlobalKey<NavigatorState>(debugLabel: 'planner_tab');
final GlobalKey<NavigatorState> _shellProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile_tab');

/// Custom listenable wrapper that updates GoRouter navigation triggers on Stream state emissions
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provider exposing the reactive GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isLoggedIn = user != null;

      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuthRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/forgot-password';

      if (isSplash) {
        return null;
      }

      if (!isLoggedIn) {
        // Force authentication check unless visiting onboarding or auth screens
        if (!isAuthRoute && !isOnboarding) {
          return '/login';
        }
      } else {
        // Route active auth sessions away from auth portal / onboarding to core dashboard console
        if (isAuthRoute || isOnboarding) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      // Splash Screen Route
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen Route
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Cyber Login Portal
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Scholar Registration Portal
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Cypher Key Recovery Portal
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Cyber Note Editor workspace
      GoRoute(
        path: '/notes/editor',
        name: RouteNames.noteEditor,
        builder: (context, state) => const NoteEditorScreen(),
      ),

      // PDF Study File Selector screen
      GoRoute(
        path: '/pdf',
        name: RouteNames.pdfSelect,
        builder: (context, state) => const PdfSelectScreen(),
      ),

      // PDF Study File Viewer Screen
      GoRoute(
        path: '/pdf/viewer',
        name: RouteNames.pdfViewer,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Study Document';
          final url = state.uri.queryParameters['url'] ?? '';
          return PdfViewerScreen(title: title, url: url);
        },
      ),

      // Voice Audio Capture Workspace Screen
      GoRoute(
        path: '/voice',
        name: RouteNames.voiceNotes,
        builder: (context, state) => const VoiceRecorderScreen(),
      ),

      // Quiz Feature Routes
      GoRoute(
        path: '/quiz',
        name: RouteNames.quizList,
        builder: (context, state) => const QuizHubScreen(),
      ),
      GoRoute(
        path: '/quiz/play',
        name: RouteNames.quizPlay,
        builder: (context, state) => const QuizArenaScreen(),
      ),
      GoRoute(
        path: '/quiz/summary',
        name: RouteNames.quizSummary,
        builder: (context, state) => const QuizSummaryScreen(),
      ),

      // Flashcards Feature Routes
      GoRoute(
        path: '/flashcards',
        name: RouteNames.flashcardList,
        builder: (context, state) => const FlashcardHubScreen(),
      ),
      GoRoute(
        path: '/flashcards/review',
        name: RouteNames.flashcardReview,
        builder: (context, state) => const FlashcardReviewScreen(),
      ),

      // Export Center Route
      GoRoute(
        path: '/export',
        name: RouteNames.export,
        builder: (context, state) => const ExportScreen(),
      ),

      // Stateful Shell Route for main application tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard Tab
          StatefulShellBranch(
            navigatorKey: _shellDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                name: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Notes Tab
          StatefulShellBranch(
            navigatorKey: _shellNotesKey,
            routes: [
              GoRoute(
                path: '/notes',
                name: RouteNames.notes,
                builder: (context, state) => const NotesScreen(),
              ),
            ],
          ),

          // AI Chat Tab
          StatefulShellBranch(
            navigatorKey: _shellAIKey,
            routes: [
              GoRoute(
                path: '/ai',
                name: RouteNames.ai,
                builder: (context, state) => const AIScreen(),
              ),
            ],
          ),

          // Planner Tab
          StatefulShellBranch(
            navigatorKey: _shellPlannerKey,
            routes: [
              GoRoute(
                path: '/planner',
                name: RouteNames.planner,
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),

          // Profile Tab
          StatefulShellBranch(
            navigatorKey: _shellProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
