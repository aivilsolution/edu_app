import 'package:edu_app/features/auth/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isStudent => user?.role == UserRole.student;
  bool get isProfessor => user?.role == UserRole.professor;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isStaff => user?.role == UserRole.staff;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  AuthState logCopy({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    debugPrint(
      'AuthState.copyWith - Current State: $this, status: $status, user: $user, errorMessage: $errorMessage',
    );
    return copyWith(status: status, user: user, errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() =>
      'AuthState(status: $status, user: ${user?.email}, errorMessage: $errorMessage)';
}
