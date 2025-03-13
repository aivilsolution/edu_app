import 'package:edu_app/features/ai/bloc/media_cubit.dart';
import 'package:edu_app/features/ai/data/repository/media_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '/features/ai/bloc/chat_cubit.dart';
import '/features/ai/bloc/chat_state.dart';
import '/features/ai/data/models/chat.dart';
import '/features/ai/views/screens/chats_archive.dart';
import '/features/ai/views/screens/media_archive.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(),
      child: const _AuthProvider(child: _AiPageView()),
    );
  }
}

class _AuthProvider extends StatelessWidget {
  final Widget child;
  const _AuthProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        return FutureBuilder<MediaRepository>(
          future: MediaRepository.forCurrentUser,
          builder: (context, mediaRepoSnapshot) {
            if (mediaRepoSnapshot.hasData) {
              final mediaRepository = mediaRepoSnapshot.data!;

              final chatCubit = BlocProvider.of<ChatCubit>(context);

              return BlocProvider<MediaCubit>(
                create:
                    (context) => MediaCubit(
                      repository: mediaRepository,

                      chatCubit: chatCubit,
                    ),
                child: child,
              );
            } else if (mediaRepoSnapshot.hasError) {
              return Center(child: Text('Failed to load Media Repository'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}

class _AiPageView extends StatefulWidget {
  const _AiPageView();

  @override
  State<_AiPageView> createState() => _AiPageViewState();
}

class _AiPageViewState extends State<_AiPageView> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, String message, Object? error) {
    debugPrint('$message: ${error ?? 'No error details.'}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message: ${error ?? 'No error details.'}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _buildAppBar(context, colorScheme),
      body: const _ChatBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      title: const Text("AI Assistant"),
      leading: _buildArchiveIconButton(context),
      actions: [
        _buildMediaArchiveIconButton(context),
        _buildNewChatIconButton(context),
      ],
    );
  }

  Widget _buildArchiveIconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.archive_outlined),
      tooltip: 'Chat Archive',
      onPressed: () => _openChatArchive(context),
    );
  }

  Widget _buildMediaArchiveIconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.photo_library_outlined),
      tooltip: 'Media Archive',
      onPressed: () => _openMediaArchive(context),
    );
  }

  Widget _buildNewChatIconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      tooltip: 'New Chat',
      onPressed: () => _createNewChat(context),
    );
  }

  void _createNewChat(BuildContext context) {
    context.read<ChatCubit>().createNewChat();
  }

  Future<void> _openChatArchive(BuildContext context) async {
    final cubit = context.read<ChatCubit>();
    final state = cubit.state;

    if (state is ChatLoadingState) return;

    final List<Chat> chats =
        state is ChatLoadedState
            ? state.allChats
            : state is ChatEmptyState
            ? state.allChats
            : [];
    final String selectedChatId =
        state is ChatLoadedState
            ? state.currentChat.id
            : state is ChatEmptyState
            ? ''
            : '';

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

  Future<void> _openMediaArchive(BuildContext context) async {
    final mediaCubit = context.read<MediaCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider.value(
              value: mediaCubit,
              child: const MediaArchiveScreen(),
            ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) => current is ChatErrorState,
      listener: (context, state) {
        if (state is ChatErrorState) {
          _getContextViewState(
            context,
          )?._showErrorSnackBar(context, state.message, null);
        }
      },
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is ChatLoadedState && current is ChatLoadedState) {
          return previous.currentChat.id != current.currentChat.id;
        }
        return false;
      },
      builder: (context, state) {
        if (state is ChatLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatLoadedState) {
          return _ChatView(state: state);
        } else if (state is ChatEmptyState) {
          return const _EmptyChatView();
        } else {
          return const Center(
            child: Text('Something went wrong. Please try again.'),
          );
        }
      },
    );
  }

  _AiPageViewState? _getContextViewState(BuildContext context) {
    return context.findAncestorStateOfType<_AiPageViewState>();
  }
}

class _ChatView extends StatelessWidget {
  final ChatLoadedState state;
  const _ChatView({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LlmChatView(
      provider: state.provider,
      style: LlmChatViewStyle(
        backgroundColor: colorScheme.surface,
        chatInputStyle: ChatInputStyle(
          backgroundColor: colorScheme.surface,
          hintText: 'Ask a question...',
        ),
        llmMessageStyle: LlmMessageStyle(
          decoration: BoxDecoration(color: colorScheme.surface),
          markdownStyle: MarkdownStyleSheet.fromTheme(
            ThemeData(
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
      messageSender: (
        String prompt, {
        required Iterable<Attachment> attachments,
      }) {
        if (prompt.contains('@media')) {
          String mediaPrompt = prompt.replaceAll('@media', '').trim();
          try {
            final mediaCubit = BlocProvider.of<MediaCubit>(context);
            Future.delayed(Duration(milliseconds: 100), () {
              mediaCubit.generateMedia(prompt: mediaPrompt);
            });
          } catch (e) {
            debugPrint('Error handling @media prompt: $e');
            return state.provider.sendMessageStream(mediaPrompt);
          }
        }
        return state.provider.sendMessageStream(prompt);
      },
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48),
          const SizedBox(height: 16),
          const Text(
            'No active chat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Please create a new chat to get started'),
        ],
      ),
    );
  }
}
