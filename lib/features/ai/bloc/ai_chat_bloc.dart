// lib/features/ai_chat/bloc/ai_chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../models/chat_message.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  late GenerativeModel _model;
  late ChatSession _chat;

  AiChatBloc() : super(const AiChatState()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onInitializeChat(
      InitializeChatEvent event, Emitter<AiChatState> emit) async {
    try {
      await Firebase.initializeApp();
      _model = FirebaseVertexAI.instance
          .generativeModel(model: 'gemini-1.5-flash-001');
      _chat = _model.startChat();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          error: 'Chat initialization failed: $e', isLoading: false));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<AiChatState> emit) async {
    if (event.message.trim().isEmpty) return;

    emit(state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: event.message, isUser: true)
    ], isLoading: true));

    try {
      final response = await _chat.sendMessage(Content.text(event.message));
      emit(state.copyWith(messages: [
        ...state.messages,
        ChatMessage(text: response.text ?? 'No response', isUser: false)
      ], isLoading: false));
    } catch (e) {
      emit(state.copyWith(messages: [
        ...state.messages,
        ChatMessage(text: 'Error: $e', isUser: false)
      ], isLoading: false, error: e.toString()));
    }
  }
}
