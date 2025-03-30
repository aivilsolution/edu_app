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
  bool _isTemporaryChat = false;
  static const _maxTitleLength = 40;

  ChatCubit({ChatRepository? repository}) : super(const ChatLoadingState()) {
    repository != null ? _repository = repository : initialize();
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }

  Future<void> initialize() async {
    try {
      await _initializeRepository();
      final temporaryChat = _repository.createTemporaryChat();
      _isTemporaryChat = true;
      await _loadChatWithProvider(temporaryChat, []);
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

  LlmProvider createProvider([List<ChatMessage>? history]) {
    final provider = VertexProvider(
      history: history ?? [],
      model: FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash-lite',
        systemInstruction: Content.system('''
       Only When a user's message includes "@media", reply with a message such as:
       "Your explanation is being prepared. Please check your media shortly."
     '''),
      ),
    );
    return provider;
  }

  Future<void> _loadChatWithProvider(
    Chat chat, [
    List<ChatMessage>? history,
  ]) async {
    try {
      _currentProvider?.removeListener(_onProviderHistoryChanged);

      final provider = createProvider(history ?? []);
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

  Future<void> createNewChat() async {
    if (state is ChatLoadingState) {
      return;
    }

    emit(const ChatLoadingState());
    try {
      final temporaryChat = _repository.createTemporaryChat();
      _isTemporaryChat = true;
      await _loadChatWithProvider(temporaryChat, []);
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
      final history = await _repository.getHistory(chat);
      await _loadChatWithProvider(chat, history);
      _isTemporaryChat = false;
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to load selected chat', e, stackTrace));
    }
  }

  Future<void> updateChat(Chat updatedChat) async {
    if (state is! ChatLoadedState) {
      return;
    }

    try {
      await _repository.updateChat(updatedChat);
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
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to update chat', e, stackTrace));
    }
  }

  Future<void> deleteChat(Chat chat) async {
    try {
      await _repository.deleteChat(chat);
      if (state is! ChatLoadedState) {
        return;
      }

      final currentState = state as ChatLoadedState;
      if (currentState.currentChat.id == chat.id) {
        if (_repository.chats.isEmpty) {
          emit(ChatEmptyState(_repository.chats));
        } else {
          await loadChat(_repository.chats.last);
        }
        return;
      }
      emit(currentState.copyWith(allChats: _repository.chats));
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to delete chat', e, stackTrace));
    }
  }

  Future<void> updateChatTitle(Chat chat, String newTitle) async {
    if (state is! ChatLoadedState || newTitle.trim().isEmpty) {
      return;
    }

    try {
      final updatedChat = Chat(id: chat.id, title: newTitle.trim());
      await _repository.updateChat(updatedChat);

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
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to update chat title', e, stackTrace));
    }
  }

  void _onProviderHistoryChanged() {
    if (state is! ChatLoadedState || _currentProvider == null) {
      return;
    }

    final currentState = state as ChatLoadedState;
    emit(currentState.copyWith(provider: _currentProvider));

    if (_isTemporaryChat && _currentProvider!.history.isNotEmpty) {
      _persistTemporaryChat(currentState.currentChat);
    } else if (!_isTemporaryChat) {
      _updateChatHistory(currentState.currentChat);
    }
  }

  Future<void> _updateChatHistory(Chat chat) async {
    if (state is! ChatLoadedState || _currentProvider == null) {
      return;
    }

    final currentState = state as ChatLoadedState;

    try {
      final history = _currentProvider!.history.toList();
      if (!_isTemporaryChat) {
        await _repository.updateHistory(chat, history);
      }

      if (_shouldGenerateTitle(chat, history)) {
        await _generateChatTitle(chat, history, currentState);
      }
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to update chat history', e, stackTrace));
    }
  }

  bool _shouldGenerateTitle(Chat chat, List<ChatMessage> history) {
    if (chat.title != ChatRepository.newChatTitle) {
      return false;
    }

    if (history.isEmpty) {
      return false;
    }

    final userMessages = history.where((msg) => msg.origin.isUser).toList();
    final shouldGenerate = userMessages.isNotEmpty && history.length <= 5;
    return shouldGenerate;
  }

  Future<void> _persistTemporaryChat(Chat chat) async {
    try {
      final persistedChat = await _repository.addChat(temporaryChat: chat);
      _isTemporaryChat = false;

      final history = _currentProvider!.history.toList();
      await _repository.updateHistory(persistedChat, history);

      if (state is ChatLoadedState) {
        final currentState = state as ChatLoadedState;
        emit(
          currentState.copyWith(
            currentChat: persistedChat,
            allChats: _repository.chats,
          ),
        );

        if (_shouldGenerateTitle(persistedChat, history)) {
          await _generateChatTitle(persistedChat, history, currentState);
        }
      }
    } catch (e, stackTrace) {
      emit(ChatErrorState('Failed to persist temporary chat', e, stackTrace));
    }
  }

  Future<void> _generateChatTitle(
    Chat chat,
    List<ChatMessage> history,
    ChatLoadedState currentState,
  ) async {
    try {
      final titleProvider = createProvider();

      final userMessages = history
          .where((message) => message.origin.isUser)
          .take(3)
          .map((message) => message.text ?? '')
          .where((text) => text.isNotEmpty)
          .join("\n---\n");

      if (userMessages.isEmpty) {
        return;
      }

      final prompt = '''
    Generate a concise title (2-5 words) for a chat conversation based on the initial user messages.
    Consider up to the first 3 user messages to understand the conversation topic.

    Initial User Messages:
    """
    $userMessages
    """

    The title should be:
    - Short and to the point (2-5 words max).
    - Descriptive of the conversation topic based on user messages.
    - Clear and easy to understand.
    - Without any punctuation or special characters.
    - In lowercase if possible.

    Examples of good titles:
    - learn french verbs
    - create study plan
    - compare two novels

    Examples of bad titles:
    - help me please!!!!
    - question about homework??
    - i need assistance with this

    Return just the title, without any extra text or quotes.
    ''';

      final stream = titleProvider.sendMessageStream(prompt);
      final response = await stream.join();

      String title = response.trim();
      title = title.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();

      if (title.length > _maxTitleLength) {
        title = title.substring(0, _maxTitleLength).trim();
      }

      if (title.isEmpty || title.length < 2) {
        title = _fallbackTitle(history);
      }

      if (title.isNotEmpty && title != ChatRepository.newChatTitle) {
        final chatWithNewTitle = Chat(id: chat.id, title: title);
        await _repository.updateChat(chatWithNewTitle);

        if (state is ChatLoadedState) {
          final updatedState = state as ChatLoadedState;
          final updatedAllChats = _repository.chats;
          emit(
            updatedState.copyWith(
              currentChat:
                  currentState.currentChat.id == chat.id
                      ? chatWithNewTitle
                      : currentState.currentChat,
              allChats: updatedAllChats,
            ),
          );
        }
      }
    } catch (e) {
      // Handle title generation error if needed
    }
  }

  String _fallbackTitle(List<ChatMessage> history) {
    final userMessages = history.where((msg) => msg.origin.isUser).toList();
    if (userMessages.isEmpty || userMessages[0].text == null) {
      return ChatRepository.newChatTitle;
    }

    final firstMessage = userMessages[0].text!;

    final words = firstMessage.split(' ').take(5).join(' ');
    final title = words.substring(
      0,
      firstMessage.length > _maxTitleLength
          ? _maxTitleLength
          : firstMessage.length,
    );
    return title;
  }

  Future<void> regenerateTitle(Chat chat) async {
    if (state is! ChatLoadedState || _currentProvider == null) {
      return;
    }

    final currentState = state as ChatLoadedState;
    final history = _currentProvider!.history.toList();

    await _generateChatTitle(chat, history, currentState);
  }
}
