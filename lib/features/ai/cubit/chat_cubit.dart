import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '/features/ai/cubit/chat_state.dart';
import '/features/ai/data/models/chat.dart';
import '/features/ai/data/repository/chat_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  late ChatRepository _repository;
  LlmProvider? _currentProvider;

  ChatCubit({ChatRepository? repository}) : super(const ChatLoadingState()) {
    if (repository != null) {
      _repository = repository;
    } else {
      initialize();
    }
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }

  Future<void> initialize() async {
    try {
      await _initializeRepository();
      final newChat = await _repository.addChat();
      await _loadChat(newChat);
    } catch (e, stackTrace) {
      emit(ChatErrorState('Error initializing chat', e, stackTrace));
    }
  }

  Future<void> _initializeRepository() async {
    _repository = await ChatRepository.forCurrentUser;
  }

  Future<void> _cleanup() async {
    _currentProvider?.removeListener(_onProviderHistoryChanged);
  }

  Future<void> createNewChat() async {
    if (state is ChatLoadingState) {
      return;
    }

    emit(const ChatLoadingState());

    try {
      final newChat = await _repository.addChat();
      await _loadChat(newChat);
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to create new chat', e, stackTrace));
    }
  }

  Future<void> loadChat(Chat chat) async {
    if (state is ChatLoadingState) {
      return;
    }

    emit(const ChatLoadingState());

    try {
      await _loadChat(chat);
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to load selected chat', e, stackTrace));
    }
  }

  Future<void> _loadChat(Chat chat) async {
    try {
      _currentProvider?.removeListener(_onProviderHistoryChanged);

      final history = await _repository.getHistory(chat);
      final provider = createProvider(history);

      _currentProvider = provider;
      provider.addListener(_onProviderHistoryChanged);

      emit(
        ChatLoadedState(
          currentChat: chat,
          provider: provider,
          allChats: _repository.chats,
        ),
      );
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to load chat', e, stackTrace));
    }
  }

  Future<void> updateChat(Chat updatedChat) async {
    if (state is! ChatLoadedState) {
      return;
    }

    try {
      await _repository.updateChat(updatedChat);

      if (state is ChatLoadedState) {
        final currentState = state as ChatLoadedState;
        emit(
          currentState.copyWith(
            allChats: _repository.chats,
            currentChat:
                currentState.currentChat.id == updatedChat.id
                    ? updatedChat
                    : currentState.currentChat,
          ),
        );
      }
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to update chat', e, stackTrace));
    }
  }

  Future<void> deleteChat(Chat chat) async {
    try {
      await _repository.deleteChat(chat);

      if (state is ChatLoadedState) {
        final currentState = state as ChatLoadedState;
        if (currentState.currentChat.id == chat.id) {
          if (_repository.chats.isEmpty) {
            emit(ChatEmptyState([]));
          } else {
            await _loadChat(_repository.chats.last);
          }
          return;
        }

        emit(currentState.copyWith(allChats: _repository.chats));
      }
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to delete chat', e, stackTrace));
    }
  }

  Future<void> updateMessage(Chat chat) async {
    if (state is! ChatLoadedState) {
      return;
    }

    final currentState = state as ChatLoadedState;
    final provider = currentState.provider;

    try {
      final history = provider.history.toList();
      await _repository.updateHistory(chat, history);

      if (_shouldGenerateTitle(chat, history)) {
        await _generateChatTitle(chat, history, currentState);
      }
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to update message', e, stackTrace));
    }
  }

  bool _shouldGenerateTitle(Chat chat, List<ChatMessage> history) {
    final shouldGenerate =
        history.length >= 2 &&
        chat.title == ChatRepository.newChatTitle &&
        history[0].origin.isUser &&
        history[1].origin.isLlm;
    return shouldGenerate;
  }

  Future<void> _generateChatTitle(
    Chat chat,
    List<ChatMessage> history,
    ChatLoadedState currentState,
  ) async {
    final stream = createProvider().sendMessageStream(
      'Please give me a short title for this chat. It should be a single, '
      'short phrase with no markdown or punctuation, maximum 5 words.',
    );

    final title = await stream.join();
    final trimmedTitle = title.trim();

    if (trimmedTitle.isNotEmpty) {
      final chatWithNewTitle = Chat(id: chat.id, title: trimmedTitle);
      await _repository.updateChat(chatWithNewTitle);

      emit(
        currentState.copyWith(
          currentChat: chatWithNewTitle,
          allChats: _repository.chats,
        ),
      );
    }
  }

  Future<void> updateChatTitle(Chat chat, String newTitle) async {
    if (state is! ChatLoadedState) {
      return;
    }

    try {
      final updatedChat = Chat(id: chat.id, title: newTitle.trim());
      await _repository.updateChat(updatedChat);

      if (state is ChatLoadedState) {
        final currentState = state as ChatLoadedState;
        emit(
          currentState.copyWith(
            allChats: _repository.chats,
            currentChat:
                currentState.currentChat.id == updatedChat.id
                    ? updatedChat
                    : currentState.currentChat,
          ),
        );
      }
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to update chat title', e, stackTrace));
    }
  }

  LlmProvider createProvider([List<ChatMessage>? history]) {
    final provider = VertexProvider(
      history: history ?? [],
      model: FirebaseVertexAI.instance.generativeModel(
        systemInstruction: Content.system('''
       Only When a user's message includes "@media", reply with a message such as:
       "Your explanation is being prepared. Please check your media shortly."
     '''),
        model: 'gemini-2.0-flash-lite-preview-02-05',
      ),
    );
    return provider;
  }

  void _onProviderHistoryChanged() {
    if (state is ChatLoadedState) {
      final currentState = state as ChatLoadedState;
      emit(currentState.copyWith(provider: _currentProvider));
      updateMessage(currentState.currentChat);
    }
  }
}
