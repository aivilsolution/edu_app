import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


enum UserRole { student, professor, admin, staff }


class AuthUser {
  final String uid;
  final String email;
  final UserRole role;

  
  const AuthUser({required this.uid, required this.email, required this.role});

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

  
  AuthUser? get currentUser;

  
  User? get firebaseCurrentUser;

  
  Future<AuthUser> signInWithEmailAndPassword(String email, String password);

  
  Future<void> signOut();

  
  Future<UserRole> getUserRole(String uid);
}


class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap((user) async {
        if (user == null) {
          debugPrint("AuthState: User is null (logged out)");
          return null;
        }
        final role = await getUserRole(user.uid);
        debugPrint("AuthState: User logged in, UID: ${user.uid}, Role: $role");
        return AuthUser(uid: user.uid, email: user.email ?? '', role: role);
      });

  @override
  User? get firebaseCurrentUser => _firebaseAuth.currentUser;

  @override
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      role:
          UserRole.student, 
    );
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Sign-in failed: No user returned');
      }
      final role = await getUserRole(user.uid);
      return AuthUser(uid: user.uid, email: user.email ?? '', role: role);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign-in failed: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign-out failed: $e');
    }
  }

  @override
  Future<UserRole> getUserRole(String uid) async {
    try {
      final snapshot = await _firestore.collection('admins').doc(uid).get();
      if (snapshot.exists) return UserRole.admin;

      final staffsnapshot =
          await _firestore.collection('staffs').doc(uid).get();
      if (staffsnapshot.exists) return UserRole.staff;

      final professorsnapshot =
          await _firestore.collection('professors').doc(uid).get();
      if (professorsnapshot.exists) return UserRole.professor;

      final studentsnapshot =
          await _firestore.collection('students').doc(uid).get();
      if (studentsnapshot.exists) return UserRole.student;

      return UserRole.student; 
    } catch (e) {
      throw AuthException('Failed to get user role: $e');
    }
  }
}
