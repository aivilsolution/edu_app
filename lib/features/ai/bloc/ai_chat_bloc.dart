import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_message.dart';

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  GenerativeModel? _model;
  ChatSession? _chat;
  final String modelName;

  AiChatBloc({this.modelName = 'gemini-1.5-flash-001'})
      : super(const AiChatState()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onInitializeChat(
      InitializeChatEvent event, Emitter<AiChatState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await Firebase.initializeApp();
      _model = FirebaseVertexAI.instance.generativeModel(model: modelName);
      _chat = _model!.startChat();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          error: 'Chat initialization failed: $e', isLoading: false));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<AiChatState> emit) async {
    final message = event.message.trim();
    if (message.isEmpty) return;

    final userMessage = ChatMessage(text: message, isUser: true);
    emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isLoading: true,
        error: null));

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final aiMessage =
          ChatMessage(text: response.text ?? 'No response', isUser: false);
      emit(state.copyWith(
          messages: [...state.messages, aiMessage], isLoading: false));
    } catch (e) {
      final errorMessage = ChatMessage(text: 'Error: $e', isUser: false);
      emit(state.copyWith(
          messages: [...state.messages, errorMessage],
          isLoading: false,
          error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _model = null;
    return super.close();
  }
}
