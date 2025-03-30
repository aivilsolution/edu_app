import 'package:edu_app/features/communication/views/screens/communication_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_app/features/auth/login_page.dart';
import 'package:edu_app/features/auth/signup_page.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/features/home/views/screens/home_screen.dart';
import '/features/ai/views/screens/ai_page.dart';
import '/features/calendar/views/screens/calendar_page.dart';
import '/shared/widgets/custom_nav_bar.dart';

class AppRouter {
  static final _homeNavigatorKey = GlobalKey<
    NavigatorState
  >(
    debugLabel:
        'homeNav',
  );
  static final _aiNavigatorKey = GlobalKey<
    NavigatorState
  >(
    debugLabel:
        'aiNav',
  );
  static final _communicationNavigatorKey = GlobalKey<
    NavigatorState
  >(
    debugLabel:
        'CommunicationNav',
  );
  static final _calendarNavigatorKey = GlobalKey<
    NavigatorState
  >(
    debugLabel:
        'calendarNav',
  );
  static final _shellNavigationKey = GlobalKey<
    StatefulNavigationShellState
  >(
    debugLabel:
        'shellNav',
  );

  static String? _handleAuthRedirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final authState =
        context
            .read<
              AuthBloc
            >()
            .state;
    final isAuthenticated =
        authState.status ==
        AuthStatus.authenticated;
    final isLoginPage =
        state.matchedLocation ==
        '/login';
    final isSignupPage =
        state.matchedLocation ==
        '/signup';

    if (!isAuthenticated &&
        !isLoginPage &&
        !isSignupPage) {
      return '/login';
    }
    if (isAuthenticated &&
        (isLoginPage ||
            isSignupPage)) {
      return '/';
    }
    return null;
  }

  static Widget _buildShell(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return Scaffold(
      body:
          navigationShell,
      bottomNavigationBar: CustomNavBar(
        selectedIndex:
            navigationShell.currentIndex,
        onDestinationSelected:
            (
              index,
            ) => navigationShell.goBranch(
              index,
            ),
      ),
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation:
        '/',
    refreshListenable:
        _refreshListenable,
    redirect:
        _handleAuthRedirect,
    routes: [
      GoRoute(
        name:
            'login',
        path:
            '/login',
        builder:
            (
              _,
              __,
            ) =>
                const LoginPage(),
      ),
      GoRoute(
        name:
            'signup',
        path:
            '/signup',
        builder:
            (
              _,
              __,
            ) =>
                const SignupPage(),
      ),
      StatefulShellRoute.indexedStack(
        key:
            _shellNavigationKey,
        builder:
            _buildShell,
        branches: [
          StatefulShellBranch(
            navigatorKey:
                _homeNavigatorKey,
            routes: [
              GoRoute(
                name:
                    'home',
                path:
                    '/',
                builder:
                    (
                      _,
                      __,
                    ) =>
                        const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey:
                _aiNavigatorKey,
            routes: [
              GoRoute(
                name:
                    'ai',
                path:
                    '/ai',
                builder:
                    (
                      _,
                      __,
                    ) =>
                        const AiPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey:
                _communicationNavigatorKey,
            routes: [
              GoRoute(
                name:
                    'Communication',
                path:
                    '/Communication',
                builder:
                    (
                      _,
                      __,
                    ) =>
                        const CommunicationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey:
                _calendarNavigatorKey,
            routes: [
              GoRoute(
                name:
                    'calendar',
                path:
                    '/calendar',
                builder:
                    (
                      _,
                      __,
                    ) =>
                        const CalendarPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static final ValueNotifier<
    AuthState
  >
  _refreshListenable = ValueNotifier(
    const AuthState(
      status:
          AuthStatus.initial,
    ),
  );
  static void initializeRefreshListenable(
    BuildContext context,
  ) {
    context
        .read<
          AuthBloc
        >()
        .stream
        .listen(
          (
            authState,
          ) {
            _refreshListenable.value = authState;
          },
        );
  }
}
