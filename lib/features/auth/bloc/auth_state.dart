import 'package:edu_app/features/auth/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState extends Equatable {
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({this.user, this.errorMessage});

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isStudent => user?.role == UserRole.student;
  bool get isProfessor => user?.role == UserRole.professor;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isStaff => user?.role == UserRole.staff;

  @override
  List<Object?> get props => [user, errorMessage];
}

class AuthInitial extends AuthState {
  const AuthInitial() : super();
}

class AuthLoading extends AuthState {
  const AuthLoading() : super();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(AuthUser user) : super(user: user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.errorMessage});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message) : super(errorMessage: message);
}
