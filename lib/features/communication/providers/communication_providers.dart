import 'package:edu_app/features/communication/cubit/chat_cubit.dart';
import 'package:edu_app/features/communication/cubit/message_cubit.dart';
import 'package:edu_app/features/communication/services/chat_service.dart';
import 'package:edu_app/features/communication/services/message_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';

class ChatProvider extends BlocProvider<ChatCubit> {
  ChatProvider({super.key, super.child})
    : super(create: (context) => ChatCubit(ChatService()));

  static ChatCubit of(BuildContext context) =>
      BlocProvider.of<ChatCubit>(context);
}

class MessageProvider extends BlocProvider<MessageCubit> {
  MessageProvider({super.key, super.child})
    : super(create: (context) => MessageCubit(MessageService()));

  static MessageCubit of(BuildContext context) =>
      BlocProvider.of<MessageCubit>(context);
}
