import 'dart:async';
import 'package:edu_app/features/auth/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '/features/ai/data/repository/chat_repository.dart';
import '/features/ai/data/repository/media_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthCubit({required AuthService authService})
    : _authService = authService,
      super(const AuthInitial()) {
    _initAuthStateListener();
    initializeAuthState();
  }

  void _initAuthStateListener() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      debugPrint('AuthCubit: authStateChanges stream emitted user: $user');
      _handleAuthChange(user);
    }, onError: (error) => emit(AuthError(error.toString())));
  }

  Future<void> _handleAuthChange(AuthUser? user) async {
    try {
      if (user != null) {
        await _updateRepositories(user);
        emit(AuthAuthenticated(user));
      } else {
        await _clearRepositories();
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> initializeAuthState() async {
    emit(const AuthLoading());
    try {
      final authUser = await _authService.currentUser;
      if (authUser != null) {
        await _updateRepositories(authUser);
        emit(AuthAuthenticated(authUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _updateRepositories(AuthUser user) async {
    ChatRepository.user = user;
    MediaRepository.user = user;
  }

  Future<void> _clearRepositories() async {
    ChatRepository.user = null;
    MediaRepository.user = null;
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(const AuthLoading());
      await _authService.signInWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      emit(AuthUnauthenticated(errorMessage: e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      emit(const AuthLoading());
      await _authService.signUpWithEmailAndPassword(email, password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(const AuthLoading());
      await _authService.signInWithGoogle();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      emit(const AuthLoading());
      await _authService.signOut();
      await _clearRepositories();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  
  void logStateChange(AuthState newState) {
    debugPrint('''
    AuthState Change:
    Previous: ${state.runtimeType} 
    New: ${newState.runtimeType}
    User: ${newState.user?.email}
    Error: ${newState.errorMessage}
    ''');
  }
}
