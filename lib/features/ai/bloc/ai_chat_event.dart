// lib/features/ai_chat/bloc/ai_chat_event.dart
import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends AiChatEvent {
  final String message;
  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class InitializeChatEvent extends AiChatEvent {}
