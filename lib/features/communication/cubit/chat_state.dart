import 'package:edu_app/features/communication/models/user.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<UserModel> users;

  ChatLoaded(this.users);
}

class UserProfileLoaded extends ChatState {
  final UserModel user;

  UserProfileLoaded(this.user);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
