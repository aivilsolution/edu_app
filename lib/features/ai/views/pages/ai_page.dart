// lib/features/ai_chat/pages/ai_page.dart
import 'package:edu_app/features/ai/bloc/ai_chat_bloc.dart';
import 'package:edu_app/features/ai/bloc/ai_chat_event.dart';
import 'package:edu_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/message_list.dart';
import '../widgets/input_area.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiChatBloc()..add(InitializeChatEvent()),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "AI",
          centerTitle: true,
        ),
        body: const Column(
          children: [
            Expanded(child: MessageList()),
            InputArea(),
          ],
        ),
      ),
    );
  }
}
