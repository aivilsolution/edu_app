part of 'ai_chat_bloc.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object> get props => [];
}

class InitializeChatEvent extends AiChatEvent {
  const InitializeChatEvent();
}

class SendMessageEvent extends AiChatEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}
