import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum UserRole { student, professor, admin, staff }

class AuthUser {
  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? photoUrl;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          uid == other.uid &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => Object.hash(uid, email, role);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

abstract class AuthService {
  Stream<AuthUser?> get authStateChanges;
  Future<AuthUser?> get currentUser;
  Future<AuthUser> signInWithEmailAndPassword(String email, String password);
  Future<AuthUser> signUpWithEmailAndPassword(String email, String password);
  Future<AuthUser> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  static const String _usersCollection = 'users';
  static const UserRole _defaultRole = UserRole.student;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return null;
            return _userFromSnapshot(user, snapshot);
          });
    });
  }

  @override
  Future<AuthUser?> get currentUser async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _fetchUserData(user);
  }

  Future<AuthUser> _fetchUserData(User user) async {
    try {
      final snapshot =
          await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!snapshot.exists) throw AuthException('User document not found');
      return _userFromSnapshot(user, snapshot);
    } on FirebaseException catch (e) {
      throw AuthException('Failed to fetch user data: ${e.message}');
    }
  }

  AuthUser _userFromSnapshot(User user, DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return AuthUser(
      uid: user.uid,
      email: user.email ?? data['email'] ?? '',
      role: _parseRole(data['role']),
      displayName: user.displayName ?? data['displayName'],
      photoUrl: user.photoURL ?? data['photoUrl'],
    );
  }

  UserRole _parseRole(String? roleStr) {
    return UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => _defaultRole,
    );
  }

  Future<void> _saveUserData(User user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'role': _defaultRole.name,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw AuthException('Failed to save user data: ${e.message}');
    }
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(credential.user!);
      return _userFromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Signup failed: ${e.message}');
    }
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(credential.user!);
      return _fetchUserData(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Login failed: ${e.message}');
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Sign-in aborted by user');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      if (result.user == null) throw AuthException('Google sign-in failed');

      await _saveUserData(result.user!);
      return _fetchUserData(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Google sign-in failed: ${e.message}');
    }
  }

  AuthUser _userFromFirebaseUser(User user) => AuthUser(
    uid: user.uid,
    email: user.email ?? '',
    role: _defaultRole,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);
    } catch (e) {
      throw AuthException('Signout failed: $e');
    }
  }
}
