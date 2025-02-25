// lib/features/ai/bloc/chat_state.dart
import 'package:edu_app/features/ai/data/models/chat.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:equatable/equatable.dart';

// -------------------- States --------------------

/// Base state for chat functionality
abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial loading state
class ChatLoadingState extends ChatState {}

/// Error state with message
class ChatErrorState extends ChatState {
  final String message;
  final Object error;

  ChatErrorState(this.message, this.error);

  @override
  List<Object?> get props => [message, error];
}

/// State when chat is loaded and ready
class ChatLoadedState extends ChatState {
  final Chat currentChat;
  final LlmProvider provider;
  final List<Chat> allChats;

  ChatLoadedState({
    required this.currentChat,
    required this.provider,
    required this.allChats,
  });

  @override
  List<Object?> get props => [currentChat, provider, allChats];

  /// Create a copy with optional new values
  ChatLoadedState copyWith({
    Chat? currentChat,
    LlmProvider? provider,
    List<Chat>? allChats,
  }) {
    return ChatLoadedState(
      currentChat: currentChat ?? this.currentChat,
      provider: provider ?? this.provider,
      allChats: allChats ?? this.allChats,
    );
  }
}

/// State when no chat is selected but repository is initialized
class ChatEmptyState extends ChatState {
  final List<Chat> allChats;

  ChatEmptyState(this.allChats);

  @override
  List<Object?> get props => [allChats];
}
