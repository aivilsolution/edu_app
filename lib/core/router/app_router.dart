import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:edu_app/features/auth/login_info.dart';
import 'package:edu_app/features/home/views/screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
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
    ],
    redirect: (context, state) {
      final loginLocation = state.namedLocation('login');
      final homeLocation = state.namedLocation('home');
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.matchedLocation == loginLocation;

      if (!loggedIn && !loggingIn) return loginLocation;
      if (loggedIn && loggingIn) return homeLocation;
      return null;
    },
    refreshListenable: LoginInfo.instance,
  );
}
