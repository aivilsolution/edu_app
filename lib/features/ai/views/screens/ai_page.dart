// lib/features/ai/presentation/pages/ai_page.dart
import '/features/ai/bloc/chat_cubit.dart';
import '/features/ai/bloc/chat_state.dart';
import '/features/ai/data/models/chat.dart';
import '/features/ai/views/screens/chats_archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main AI Page Widget
class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: const _AiPageView(),
    );
  }
}

/// The actual view for the AI Page
class _AiPageView extends StatelessWidget {
  const _AiPageView();

  void _handleError(BuildContext context, String message, Object error) {
    debugPrint('$message: $error');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message: $error')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI"),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final isLoading = state is ChatLoadingState;
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'New Chat',
                    onPressed:
                        isLoading
                            ? null
                            : () => context.read<ChatCubit>().createNewChat(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.archive_outlined),
                    tooltip: 'Archive',
                    onPressed: isLoading ? null : () => _openArchive(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatErrorState) {
            _handleError(context, state.message, state.error);
          }
        },
        builder: (context, state) {
          if (state is ChatLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoadedState) {
            return LlmChatView(
              provider: state.provider,
              style: LlmChatViewStyle(
                backgroundColor: colorScheme.surface,
                chatInputStyle: ChatInputStyle(
                  backgroundColor: colorScheme.surface,
                ),
              ),
            );
          } else if (state is ChatEmptyState) {
            return const Center(
              child: Text('No active chat. Please create a new chat.'),
            );
          } else {
            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          }
        },
      ),
    );
  }

  Future<void> _openArchive(BuildContext context) async {
    final cubit = context.read<ChatCubit>();
    final state = cubit.state;

    if (state is ChatLoadingState) return;

    final List<Chat> chats;
    final String selectedChatId;

    if (state is ChatLoadedState) {
      chats = state.allChats;
      selectedChatId = state.currentChat.id;
    } else if (state is ChatEmptyState) {
      chats = state.allChats;
      selectedChatId = '';
    } else {
      // Handle other states
      chats = [];
      selectedChatId = '';
    }

    final selectedChat = await Navigator.of(context).push<Chat?>(
      MaterialPageRoute(
        builder:
            (_) => ChatsArchive(
              chats: chats,
              selectedChatId: selectedChatId,
              onUpdateChat: (chat) => cubit.updateChat(chat),
              onDeleteChat: (chat) => cubit.deleteChat(chat),
            ),
      ),
    );

    if (selectedChat != null) {
      cubit.loadChat(selectedChat);
    }
  }
}
