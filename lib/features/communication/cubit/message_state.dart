import 'package:edu_app/features/communication/models/message.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<MessageModel> messages;
  final String receiverId;

  MessageLoaded(this.messages, this.receiverId);
}

class MessageError extends MessageState {
  final String message;

  MessageError(this.message);
}
