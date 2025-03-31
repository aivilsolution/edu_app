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
import 'package:flutter/foundation.dart' show kIsWeb;

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
  final String uid;
  final String email;
  final UserPermissionLevel permissionLevel;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.uid,
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
      uid: doc.id,
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
    String? uid,
    String? email,
    UserPermissionLevel? permissionLevel,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) => AppUser(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    permissionLevel: permissionLevel ?? this.permissionLevel,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    lastLogin: lastLogin ?? this.lastLogin,
  );

  @override
  List<Object?> get props => [uid, email, permissionLevel];
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
    (user) async => user != null ? await _mapUserToAppUser(user) : null,
  );

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user != null ? await _mapUserToAppUser(user) : null;
  }

  Future<AppUser> _mapUserToAppUser(User firebaseUser) async {
    try {
      final doc =
          await _firestore
              .collection(_userCollection)
              .doc(firebaseUser.uid)
              .get();

      return doc.exists
          ? AppUser.fromFirestore(doc)
          : await _createUserDocument(firebaseUser);
    } catch (e) {
      throw AppAuthException('Error mapping user: ${e.toString()}');
    }
  }

  Future<AppUser> _createUserDocument(User firebaseUser) async {
    if (firebaseUser.email == null) {
      throw AppAuthException('User email is required');
    }

    final permissionLevel = await _determineUserPermissionLevel(
      firebaseUser.email!,
    );

    final userDoc = {
      'uid': firebaseUser.uid,
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
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      permissionLevel: permissionLevel,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection(_userCollection).doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Consider logging error to a more robust logging service in production
    }
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
      // Consider logging error to a more robust logging service in production
      return UserPermissionLevel.student;
    }
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AppAuthException('Failed to sign in: No user returned');
      }

      final appUser = await _mapUserToAppUser(userCredential.user!);
      await _prefs.setString(_permissionCacheKey, appUser.permissionLevel.name);
      await _updateLastLogin(userCredential.user!.uid);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapAuthError(e.code), e.stackTrace);
    } catch (e) {
      throw AppAuthException('Sign in failed: ${e.toString()}');
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(authProvider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AppAuthException('Google Sign-In Cancelled');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user == null) {
        throw AppAuthException(
          'Failed to sign in with Google: No user returned',
        );
      }

      final appUser = await _mapUserToAppUser(userCredential.user!);
      await _prefs.setString(_permissionCacheKey, appUser.permissionLevel.name);
      await _updateLastLogin(userCredential.user!.uid);
      return appUser;
    } catch (e) {
      if (kIsWeb) {
        return null;
      } else {
        throw AppAuthException('Google Sign-In Failed: ${e.toString()}');
      }
    }
  }

  Future<AppUser> createUserWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AppAuthException('Failed to create user: No user returned');
      }

      final appUser = await _mapUserToAppUser(userCredential.user!);
      await _prefs.setString(_permissionCacheKey, appUser.permissionLevel.name);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapAuthError(e.code), e.stackTrace);
    } catch (e) {
      throw AppAuthException('User creation failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _prefs.remove(_permissionCacheKey),
      ]);
    } catch (e) {
      throw AppAuthException('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapAuthError(e.code), e.stackTrace);
    } catch (e) {
      throw AppAuthException('Password reset failed: ${e.toString()}');
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
        return 'An authentication error occurred: $code';
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
    bool clearError = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  bool get hasError => status == AuthStatus.error;

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

class AuthErrorCleared extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _userSubscription;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthErrorCleared>(
      (event, emit) => emit(state.copyWith(clearError: true)),
    );

    _setupUserSubscription();
  }

  void _setupUserSubscription() {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.userStream.listen((user) {
      if (user != null) {
        add(AuthStarted());
      } else if (state.status == AuthStatus.authenticated) {
        add(AuthSignOutRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating));
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        ChatRepository.user = user;
        MediaRepository.user = user;
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      } else {
        ChatRepository.user = null;
        MediaRepository.user = null;
        emit(
          state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
        );
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

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
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

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
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

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      ChatRepository.user = null;
      MediaRepository.user = null;
      ChatRepository.clearCache();
      MediaRepository.clearCache();
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
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

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
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

  Future<void> _onPasswordResetRequested(
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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      widget.onResetRequested(_emailController.text.trim());

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isSubmitting,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }

                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }

                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'We will send instructions to reset your password to this email address.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _resetPassword,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Reset Password'),
        ),
      ],
    );
  }
}
