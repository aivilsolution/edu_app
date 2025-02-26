// lib/features/ai/bloc/chat_cubit.dart
import '/features/ai/bloc/chat_state.dart';
import '/features/ai/data/models/chat.dart';
import '/features/ai/data/repository/chat_repository.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main Cubit that manages chat state
class ChatCubit extends Cubit<ChatState> {
  ChatRepository? _repository;

  ChatCubit({ChatRepository? repository})
    : _repository = repository,
      super(ChatLoadingState()) {
    initialize();
  }

  /// Initializes the chat system
  Future<void> initialize() async {
    try {
      _repository ??= await ChatRepository.forCurrentUser;

      final repository = _repository;
      if (repository == null) {
        emit(
          ChatErrorState(
            'Failed to initialize chat repository',
            Exception('Repository is null'),
          ),
        );
        return;
      }

      final chats = repository.chats;

      if (chats.isEmpty) {
        // Create a new chat if none exist
        final newChat = await repository.addChat();
        await _loadChat(newChat, repository);
      } else {
        // Load the most recent chat
        await _loadChat(chats.last, repository);
      }
    } catch (e) {
      emit(ChatErrorState('Error initializing chat', e));
    }
  }

  /// Loads a specific chat
  Future<void> _loadChat(Chat chat, ChatRepository repository) async {
    try {
      final history = await repository.getHistory(chat);
      final provider = _createProvider(history);

      emit(
        ChatLoadedState(
          currentChat: chat,
          provider: provider,
          allChats: repository.chats,
        ),
      );
    } catch (e) {
      emit(ChatErrorState('Failed to load chat', e));
    }
  }

  /// Creates a new chat
  Future<void> createNewChat() async {
    if (state is ChatLoadingState) return;

    emit(ChatLoadingState());

    try {
      _repository ??= await ChatRepository.forCurrentUser;

      final repository = _repository;
      if (repository == null) {
        emit(
          ChatErrorState(
            'Unable to access chat repository',
            Exception('Repository is null'),
          ),
        );
        return;
      }

      final newChat = await repository.addChat();
      await _loadChat(newChat, repository);
    } catch (e) {
      emit(ChatErrorState('Failed to create new chat', e));
    }
  }

  /// Loads a selected chat
  Future<void> loadChat(Chat chat) async {
    if (state is ChatLoadingState) return;

    emit(ChatLoadingState());

    try {
      _repository ??= await ChatRepository.forCurrentUser;

      final repository = _repository;
      if (repository == null) {
        emit(
          ChatErrorState(
            'Unable to access chat repository',
            Exception('Repository is null'),
          ),
        );
        return;
      }

      await _loadChat(chat, repository);
    } catch (e) {
      emit(ChatErrorState('Failed to load selected chat', e));
    }
  }

  /// Updates a chat with new information
  Future<void> updateChat(Chat updatedChat) async {
    if (state is! ChatLoadedState) return;

    try {
      _repository ??= await ChatRepository.forCurrentUser;

      final repository = _repository;
      if (repository == null) {
        emit(
          ChatErrorState(
            'Unable to access chat repository',
            Exception('Repository is null'),
          ),
        );
        return;
      }

      await repository.updateChat(updatedChat);

      // We need to cast this safely
      if (state is ChatLoadedState) {
        final currentState = state as ChatLoadedState;

        // Update state with the updated list of chats
        emit(
          currentState.copyWith(
            allChats: repository.chats,
            currentChat:
                currentState.currentChat.id == updatedChat.id
                    ? updatedChat
                    : currentState.currentChat,
          ),
        );
      }
    } catch (e) {
      emit(ChatErrorState('Failed to update chat', e));
    }
  }

  /// Deletes a chat
  Future<void> deleteChat(Chat chat) async {
    try {
      _repository ??= await ChatRepository.forCurrentUser;

      final repository = _repository;
      if (repository == null) {
        emit(
          ChatErrorState(
            'Unable to access chat repository',
            Exception('Repository is null'),
          ),
        );
        return;
      }

      await repository.deleteChat(chat);

      // If we deleted the current chat, load another one or go to empty state
      if (state is ChatLoadedState) {
        final currentState = state as ChatLoadedState;
        if (currentState.currentChat.id == chat.id) {
          if (repository.chats.isEmpty) {
            emit(ChatEmptyState([]));
          } else {
            await _loadChat(repository.chats.last, repository);
          }
          return;
        }

        // Just update the list of all chats
        emit(currentState.copyWith(allChats: repository.chats));
      }
    } catch (e) {
      emit(ChatErrorState('Failed to delete chat', e));
    }
  }

  /// Creates a provider with the given history
  LlmProvider _createProvider([List<ChatMessage>? history]) {
    return VertexProvider(
      history: history ?? [],
      model: FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash-lite-preview-02-05',
      ),
    );
  }
}
