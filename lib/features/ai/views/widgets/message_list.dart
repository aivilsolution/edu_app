import 'package:edu_app/features/ai/bloc/ai_chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'animated_message_wrapper.dart';
import 'empty_state.dart';

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
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(Duration timeStamp) {
    _scrollToBottom();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      builder: (context, state) {
        if (state.messages.isEmpty) {
          return const EmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: state.messages.length,
          itemBuilder: (context, index) => AnimatedMessageWrapper(
            message: state.messages[index],
            key: ValueKey(state.messages[index].hashCode),
          ),
        );
      },
    );
  }
}
