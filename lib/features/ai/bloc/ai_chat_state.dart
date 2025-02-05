// lib/features/ai_chat/bloc/ai_chat_state.dart
import 'package:equatable/equatable.dart';
import '../models/chat_message.dart';

class AiChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [messages, isLoading, error];
}
