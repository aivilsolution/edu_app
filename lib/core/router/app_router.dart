import 'package:edu_app/features/home/views/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_app/features/ai/views/screens/ai_page.dart';
import 'package:edu_app/features/calendar/views/screens/calendar_page.dart';
import 'package:edu_app/features/profile/views/screens/profile_page.dart';
import 'package:edu_app/features/auth/login_info.dart';
import 'package:edu_app/shared/widgets/custom_nav_bar.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeNav');
  static final GlobalKey<NavigatorState> _calendarNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'calendarNav');
  static final GlobalKey<NavigatorState> _aiNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'aiNav');
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileNav');

  static final GlobalKey<StatefulNavigationShellState> _shellNavigationKey =
      GlobalKey<StatefulNavigationShellState>(debugLabel: 'shellNav');

  static String? _handleAuthRedirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final loginLocation = state.namedLocation('login');
    final homeLocation = state.namedLocation('home');
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final isOnLoginPage = state.matchedLocation == loginLocation;

    if (!loggedIn && !isOnLoginPage) return loginLocation;
    if (loggedIn && isOnLoginPage) return homeLocation;
    return null;
  }

  static Widget _buildShell(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          if (navigationShell.currentIndex != index) {
            navigationShell.goBranch(index);
          }
        },
      ),
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: LoginInfo.instance,
    redirect: _handleAuthRedirect,
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        builder:
            (context, state) => SignInScreen(
              showAuthActionSwitch: true,
              breakpoint: 600,
              providers: LoginInfo.authProviders,
              showPasswordVisibilityToggle: true,
            ),
      ),
      StatefulShellRoute.indexedStack(
        key: _shellNavigationKey,
        builder: _buildShell,
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                name: 'home',
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _calendarNavigatorKey,
            routes: [
              GoRoute(
                name: 'calendar',
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _aiNavigatorKey,
            routes: [
              GoRoute(
                name: 'ai',
                path: '/ai',
                builder: (context, state) => const AiPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                name: 'profile',
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
