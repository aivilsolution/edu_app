import 'package:edu_app/features/auth/bloc/auth_cubit.dart';
import 'package:edu_app/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget loginPage;
  final bool Function(AuthState)? additionalCheck;

  const AuthGuard({
    super.key,
    required this.child,
    required this.loginPage,
    this.additionalCheck,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state.isAuthenticated;
        final passesCheck = additionalCheck == null || additionalCheck!(state);

        if (!isAuthenticated || !passesCheck) {
          return loginPage;
        } else {
          return child;
        }
      },
    );
  }
}

class StudentGuard extends StatelessWidget {
  final Widget child;
  final Widget loginPage;
  final Widget unauthorizedPage;

  const StudentGuard({
    super.key,
    required this.child,
    required this.loginPage,
    required this.unauthorizedPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated) {
          return loginPage;
        }
        return state.isStudent ? child : unauthorizedPage;
      },
    );
  }
}

class ProfessorGuard extends StatelessWidget {
  final Widget child;
  final Widget loginPage;
  final Widget unauthorizedPage;

  const ProfessorGuard({
    super.key,
    required this.child,
    required this.loginPage,
    required this.unauthorizedPage,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated) {
          return loginPage;
        }
        return state.isProfessor ? child : unauthorizedPage;
      },
    );
  }
}

class StaffGuard extends StatelessWidget {
  final Widget child;
  final Widget loginPage;
  final Widget unauthorizedPage;

  const StaffGuard({
    super.key,
    required this.child,
    required this.loginPage,
    required this.unauthorizedPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated) {
          return loginPage;
        }
        return state.isStaff ? child : unauthorizedPage;
      },
    );
  }
}

class AdminGuard extends StatelessWidget {
  final Widget child;
  final Widget loginPage;
  final Widget unauthorizedPage;

  const AdminGuard({
    super.key,
    required this.child,
    required this.loginPage,
    required this.unauthorizedPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated) {
          return loginPage;
        }
        return state.isAdmin ? child : unauthorizedPage;
      },
    );
  }
}
