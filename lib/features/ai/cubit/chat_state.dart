import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import '/features/ai/data/models/chat.dart';

@immutable
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState();
}

class ChatErrorState extends ChatState {
  final String message;
  final Object error;
  final StackTrace? stackTrace;

  const ChatErrorState(this.message, this.error, [this.stackTrace]);

  @override
  List<Object?> get props => [message, error, stackTrace];

  @override
  String toString() => 'ChatErrorState(message: $message, error: $error)';
}

class ChatLoadedState extends ChatState {
  final Chat currentChat;
  final LlmProvider provider;
  final List<Chat> allChats;

  const ChatLoadedState({
    required this.currentChat,
    required this.provider,
    required this.allChats,
  });

  @override
  List<Object?> get props => [currentChat, provider, allChats];

  ChatLoadedState copyWith({
    Chat? currentChat,
    LlmProvider? provider,
    List<Chat>? allChats,
  }) => ChatLoadedState(
    currentChat: currentChat ?? this.currentChat,
    provider: provider ?? this.provider,
    allChats: allChats ?? this.allChats,
  );

  @override
  String toString() =>
      'ChatLoadedState(currentChat: ${currentChat.id}, chatCount: ${allChats.length})';
}

class ChatEmptyState extends ChatState {
  final List<Chat> allChats;

  const ChatEmptyState(this.allChats);

  @override
  List<Object?> get props => [allChats];

  @override
  String toString() => 'ChatEmptyState(chatCount: ${allChats.length})';
}

class ChatMessageUpdateState extends ChatState {
  final List<ChatMessage> history;
  final String chatId;
  final bool isUpdating;

  const ChatMessageUpdateState({
    required this.history,
    required this.chatId,
    this.isUpdating = false,
  });

  @override
  List<Object?> get props => [history, chatId, isUpdating];

  ChatMessageUpdateState copyWith({
    List<ChatMessage>? history,
    String? chatId,
    bool? isUpdating,
  }) => ChatMessageUpdateState(
    history: history ?? this.history,
    chatId: chatId ?? this.chatId,
    isUpdating: isUpdating ?? this.isUpdating,
  );

  @override
  String toString() =>
      'ChatMessageUpdateState(chatId: $chatId, messageCount: ${history.length}, isUpdating: $isUpdating)';
}
