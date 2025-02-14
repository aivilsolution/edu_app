import 'package:edu_app/features/ai/bloc/ai_chat_bloc.dart';
import 'package:edu_app/features/ai/views/widgets/input_area.dart';
import 'package:edu_app/features/ai/views/widgets/message_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiChatBloc()..add(InitializeChatEvent()),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: const Column(
          children: [
            Expanded(child: MessageList()),
            SizedBox(height: 10),
            InputArea(),
          ],
        ),
      ),
    );
  }
}
