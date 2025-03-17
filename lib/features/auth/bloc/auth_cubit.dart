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
      super(const AuthState()) {
    _initAuthStateListener();
  }

  
  void _initAuthStateListener() {
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        debugPrint('AuthCubit: authStateChanges stream emitted user: $user');
        if (user != null) {
          ChatRepository.user = _authService.firebaseCurrentUser;
          MediaRepository.user = _authService.firebaseCurrentUser;
          emit(
            state.logCopy(
              status: AuthStatus.authenticated,
              user: user,
              errorMessage: null,
            ),
          );
        } else {
          ChatRepository.user = null;
          MediaRepository.user = null;
          emit(
            state.logCopy(
              status: AuthStatus.unauthenticated,
              user: null,
              errorMessage: null,
            ),
          );
        }
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  
  Future<void> initializeAuthState() async {
    
    final user =
        _authService
            .firebaseCurrentUser; 
    if (user != null) {
      final role = await _authService.getUserRole(
        user.uid,
      ); 
      emit(
        state.logCopy(
          status: AuthStatus.authenticated,
          user: AuthUser(
            uid: user.uid,
            email: user.email ?? '',
            role: role,
          ), 
          errorMessage: null,
        ),
      );
    } else {
      emit(
        state.logCopy(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: null,
        ),
      );
    }
  }

  
  Future<void> signIn(String email, String password) async {
    try {
      emit(state.copyWith(errorMessage: null));
      await _authService.signInWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  
  Future<void> signOut() async {
    try {
      ChatRepository.user = null;
      MediaRepository.user = null;
      await _authService.signOut();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  
  UserRole? get userRole => state.user?.role;

  
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
