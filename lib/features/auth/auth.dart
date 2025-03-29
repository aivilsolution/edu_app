import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_app/features/ai/data/repository/chat_repository.dart';
import 'package:edu_app/features/ai/data/repository/media_repository.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

enum UserPermissionLevel {
  student(1),
  professor(2),
  staff(3),
  admin(4);

  final int level;
  const UserPermissionLevel(this.level);

  bool hasPermission(UserPermissionLevel requiredLevel) {
    return level >= requiredLevel.level;
  }
}

@immutable
class AppUser extends Equatable {
  final String id;
  final String email;
  final UserPermissionLevel permissionLevel;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.id,
    required this.email,
    this.permissionLevel = UserPermissionLevel.student,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLogin,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      permissionLevel: UserPermissionLevel.values.firstWhere(
        (level) => level.name == (data['permissionLevel'] ?? 'student'),
        orElse: () => UserPermissionLevel.student,
      ),
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    UserPermissionLevel? permissionLevel,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) => AppUser(
    id: id ?? this.id,
    email: email ?? this.email,
    permissionLevel: permissionLevel ?? this.permissionLevel,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    lastLogin: lastLogin ?? this.lastLogin,
  );

  @override
  List<Object?> get props => [id, email, permissionLevel];
}

class AppAuthException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppAuthException(this.message, [this.stackTrace]);

  @override
  String toString() => 'Authentication Error: $message';
}

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;

  static const String _userCollection = 'users';
  static const String _permissionCacheKey = 'user_permission_level';

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    required SharedPreferences prefs,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _prefs = prefs;

  Stream<AppUser?> get userStream => _auth.authStateChanges().asyncMap(
    (user) => user != null ? _mapUserToAppUser(user) : null,
  );

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user != null ? await _mapUserToAppUser(user) : null;
  }

  Future<AppUser> _mapUserToAppUser(User firebaseUser) async {
    final doc =
        await _firestore
            .collection(_userCollection)
            .doc(firebaseUser.uid)
            .get();
    return doc.exists
        ? AppUser.fromFirestore(doc)
        : await _createUserDocument(firebaseUser);
  }

  Future<AppUser> _createUserDocument(User firebaseUser) async {
    final permissionLevel = await _determineUserPermissionLevel(
      firebaseUser.email!,
    );

    final userDoc = {
      'email': firebaseUser.email,
      'displayName': firebaseUser.displayName,
      'photoUrl': firebaseUser.photoURL,
      'permissionLevel': permissionLevel.name,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(_userCollection)
        .doc(firebaseUser.uid)
        .set(userDoc);
    await _prefs.setString(_permissionCacheKey, permissionLevel.name);

    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      permissionLevel: permissionLevel,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Future<UserPermissionLevel> _determineUserPermissionLevel(
    String email,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('authorized_users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return UserPermissionLevel.student;

      final roleData = snapshot.docs.first.data();
      return UserPermissionLevel.values.firstWhere(
        (level) => level.name == (roleData['role'] ?? 'student'),
        orElse: () => UserPermissionLevel.student,
      );
    } catch (e) {
      return UserPermissionLevel.student;
    }
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final appUser = await _mapUserToAppUser(userCredential.user!);
      await _prefs.setString(_permissionCacheKey, appUser.permissionLevel.name);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapAuthError(e.code), e.stackTrace);
    }
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AppAuthException('Google Sign-In Cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final appUser = await _mapUserToAppUser(userCredential.user!);
      await _prefs.setString(_permissionCacheKey, appUser.permissionLevel.name);
      return appUser;
    } catch (e) {
      throw AppAuthException('Google Sign-In Failed: ${e.toString()}');
    }
  }

  Future<AppUser> createUserWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final appUser = await _mapUserToAppUser(userCredential.user!);
      await _prefs.setString(_permissionCacheKey, appUser.permissionLevel.name);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapAuthError(e.code), e.stackTrace);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
      _prefs.remove(_permissionCacheKey),
    ]);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapAuthError(e.code), e.stackTrace);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'An unknown authentication error occurred.';
    }
  }
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, user, errorMessage];
}

sealed class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignUpRequested(this.email, this.password);
}

class AuthSignOutRequested extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  AuthPasswordResetRequested(this.email);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating));
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        ChatRepository.user = user;
        MediaRepository.user = user;
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        ChatRepository.user = null;
        MediaRepository.user = null;
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating));
      final user = await _authRepository.signInWithEmail(
        event.email,
        event.password,
      );
      ChatRepository.user = user;
      MediaRepository.user = user;
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating));
      final user = await _authRepository.createUserWithEmail(
        event.email,
        event.password,
      );
      ChatRepository.user = user;
      MediaRepository.user = user;
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      ChatRepository.user = null;
      MediaRepository.user = null;
      ChatRepository.clearCache();
      MediaRepository.clearCache();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating));
      final user = await _authRepository.signInWithGoogle();
      ChatRepository.user = user;
      MediaRepository.user = user;
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.resetPassword(event.email);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Password reset email sent successfully',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

class PasswordResetDialog extends StatefulWidget {
  final Function(String) onResetRequested;

  const PasswordResetDialog({super.key, required this.onResetRequested});

  @override
  PasswordResetDialogState createState() => PasswordResetDialogState();
}

class PasswordResetDialogState extends State<PasswordResetDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      widget.onResetRequested(_emailController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'Please enter email' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _resetPassword, child: const Text('Reset')),
      ],
    );
  }
}
