// lib/features/ai_chat/widgets/input_area.dart
import 'package:edu_app/features/ai/bloc/ai_chat_bloc.dart';
import 'package:edu_app/features/ai/bloc/ai_chat_event.dart';
import 'package:edu_app/features/ai/bloc/ai_chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputArea extends StatefulWidget {
  const InputArea({super.key});

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                  onSubmitted: (text) => _sendMessage(context, text),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                onPressed: state.isLoading
                    ? null
                    : () => _sendMessage(context, _textController.text),
                child: Icon(
                  state.isLoading ? Icons.pending_outlined : Icons.send,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(BuildContext context, String text) {
    if (text.trim().isNotEmpty) {
      context.read<AiChatBloc>().add(SendMessageEvent(text));
      _textController.clear();
      _focusNode.requestFocus();
    }
  }
}
