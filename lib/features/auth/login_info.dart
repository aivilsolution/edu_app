import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fua;
import 'package:flutter/foundation.dart';
import 'package:edu_app/features/auth/bloc/auth_cubit.dart';
import 'package:edu_app/features/auth/bloc/auth_state.dart';
import 'package:edu_app/features/auth/services/auth_service.dart';



class LoginInfo extends ChangeNotifier {
  
  LoginInfo._({required AuthCubit authCubit}) : _authCubit = authCubit {
    
    _currentAuthState = _authCubit.state;

    
    _authStateSubscription = _authCubit.stream.listen((authState) {
      if (_currentAuthState?.user?.uid != authState.user?.uid) {
        notifyListeners();
      }
      _currentAuthState = authState;
    });
  }

  final AuthCubit _authCubit;
  AuthState? _currentAuthState;
  StreamSubscription<AuthState>? _authStateSubscription;

  
  static final List<fua.AuthProvider> authProviders = [fua.EmailAuthProvider()];

  
  static final LoginInfo instance = LoginInfo._(
    authCubit: AuthCubit(authService: FirebaseAuthService()),
  );

  
  User? get user {
    if (!isAuthenticated) return null;
    return FirebaseAuth.instance.currentUser;
  }

  
  bool get isAuthenticated => _currentAuthState?.isAuthenticated ?? false;

  
  bool get isStudent => _currentAuthState?.isStudent ?? false;

  
  bool get isProfessor => _currentAuthState?.isProfessor ?? false;

  
  bool get isAdmin => _currentAuthState?.isAdmin ?? false;

  
  String? get displayName => user?.displayName ?? user?.email;

  
  String? get uid => _currentAuthState?.user?.uid;

  
  String? get errorMessage => _currentAuthState?.errorMessage;

  
  Future<void> logout() async {
    await _authCubit.signOut();
    notifyListeners();
  }

  
  Future<void> login(String email, String password) async {
    await _authCubit.signIn(email, password);
  }

  
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
