import 'package:edu_app/features/auth/bloc/auth_cubit.dart';
import 'package:edu_app/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';

class AuthProvider extends StatelessWidget {
  final Widget child;
  final AuthService? authService;

  const AuthProvider({super.key, required this.child, this.authService});

  @override
  Widget build(BuildContext context) {
    final service = authService ?? FirebaseAuthService();

    return BlocProvider(
      create: (context) => AuthCubit(authService: service),
      child: child,
    );
  }
}

extension AuthContextExtension on BuildContext {
  AuthState get authState => read<AuthCubit>().state;
  AuthCubit get authCubit => read<AuthCubit>();
  bool get isAuthenticated => authState.isAuthenticated;
  bool get isStudent => authState.isStudent;
  bool get isProfessor => authState.isProfessor;
  bool get isAdmin => authState.isAdmin;
  AuthUser? get currentUser => authState.user;
}
