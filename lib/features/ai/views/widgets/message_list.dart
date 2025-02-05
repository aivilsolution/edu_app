// lib/features/ai_chat/widgets/message_list.dart
import 'package:edu_app/features/ai/bloc/ai_chat_bloc.dart';
import 'package:edu_app/features/ai/bloc/ai_chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'empty_state.dart';
import 'animated_message_wrapper.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        if (state.messages.isEmpty) {
          return const EmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: state.messages.length,
          itemBuilder: (context, index) =>
              AnimatedMessageWrapper(message: state.messages[index]),
        );
      },
    );
  }
}
