import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/club/screens/club_profile_screen.dart';
import '../../features/chat/screens/club_chat_screen.dart';
import '../../features/events/screens/events_feed_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/my_clubs/screens/my_clubs_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../shared/widgets/nexus_shell.dart';
import '../providers/providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Allow splash and onboarding always
      if (state.fullPath == '/' || state.fullPath == '/onboarding') return null;

      // Auth-gated routes
      final authGated = [
        '/home/my-clubs',
        '/home/profile',
      ];
      final isAuthGated = authGated.any((p) => state.fullPath?.startsWith(p) ?? false);

      if (isAuthGated && !isLoggedIn) {
        return '/auth/login';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPage(
          state,
          const SplashScreen(),
        ),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildPage(
          state,
          const OnboardingScreen(),
        ),
      ),

      // Auth
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) => _buildPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/auth/signup',
        pageBuilder: (context, state) => _buildPage(state, const SignupScreen()),
      ),

      // Shell (home with bottom nav)
      ShellRoute(
        builder: (context, state, child) => NexusShell(child: child),
        routes: [
          GoRoute(
            path: '/home/explore',
            pageBuilder: (context, state) =>
                _buildPage(state, const ExploreScreen(), noTransition: true),
          ),
          GoRoute(
            path: '/home/events',
            pageBuilder: (context, state) =>
                _buildPage(state, const EventsFeedScreen(), noTransition: true),
          ),
          GoRoute(
            path: '/home/my-clubs',
            pageBuilder: (context, state) =>
                _buildPage(state, const MyClubsScreen(), noTransition: true),
          ),
          GoRoute(
            path: '/home/profile',
            pageBuilder: (context, state) =>
                _buildPage(state, const ProfileScreen(), noTransition: true),
          ),
        ],
      ),

      // Club Profile (public)
      GoRoute(
        path: '/club/:clubId',
        pageBuilder: (context, state) {
          final clubId = state.pathParameters['clubId']!;
          return _buildPage(state, ClubProfileScreen(clubId: clubId));
        },
      ),

      // Club Chat (members only)
      GoRoute(
        path: '/club/:clubId/chat',
        pageBuilder: (context, state) {
          final clubId = state.pathParameters['clubId']!;
          return _buildPage(state, ClubChatScreen(clubId: clubId));
        },
      ),

      // Event Detail (public)
      GoRoute(
        path: '/event/:eventId',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return _buildPage(state, EventDetailScreen(eventId: eventId));
        },
      ),
    ],

    // Error page
    errorPageBuilder: (context, state) => _buildPage(
      state,
      Scaffold(
        backgroundColor: const Color(0xFF070A0F),
        body: Center(
          child: Text(
            'Page not found',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      ),
    ),
  );
});

// ── Page builder with custom transitions ──────────────────────────────────────

CustomTransitionPage<void> _buildPage(
  GoRouterState state,
  Widget child, {
  bool noTransition = false,
}) {
  if (noTransition) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, c) => c,
    );
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeOut),
      );
      final slideTween = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ),
      );
    },
  );
}
