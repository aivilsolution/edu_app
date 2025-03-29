import 'package:edu_app/features/ai/cubit/media_cubit.dart';
import 'package:edu_app/features/ai/cubit/media_state.dart';
import 'package:edu_app/features/ai/data/repository/media_repository.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '/features/ai/cubit/chat_cubit.dart';
import '/features/ai/cubit/chat_state.dart';
import '/features/ai/data/models/chat.dart';
import '/features/ai/views/screens/chats_archive.dart';
import '/features/ai/views/screens/media_archive.dart';

class AiPage
    extends
        StatelessWidget {
  const AiPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider(
      create:
          (
            _,
          ) =>
              ChatCubit(),
      child: const AuthProvider(
        child:
            _AiPageContent(),
      ),
    );
  }
}

class AuthProvider
    extends
        StatelessWidget {
  final Widget child;

  const AuthProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocBuilder<
      AuthBloc,
      AuthState
    >(
      builder: (
        context,
        authState,
      ) {
        switch (authState.status) {
          case AuthStatus.initial:
          case AuthStatus.authenticating:
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          case AuthStatus.authenticated:
            return _buildMediaRepositoryProvider(
              context,
              authState.user!,
            );
          case AuthStatus.unauthenticated:
            return _buildAuthenticationScreen();
          case AuthStatus.error:
            return _buildErrorWidget(
              authState.errorMessage ??
                  'Unknown authentication error',
            );
        }
      },
    );
  }

  Widget _buildMediaRepositoryProvider(
    BuildContext context,
    AppUser user,
  ) {
    return FutureBuilder<
      MediaRepository
    >(
      future:
          MediaRepository.forCurrentUser,
      builder: (
        context,
        mediaRepoSnapshot,
      ) {
        if (mediaRepoSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }
        if (mediaRepoSnapshot.hasError) {
          return _buildRetryWidget(
            'Failed to load Media Repository',
            onRetry:
                () {},
          );
        }
        if (mediaRepoSnapshot.hasData) {
          return _buildMediaCubitProvider(
            context,
            mediaRepoSnapshot.data!,
            user,
          );
        }
        return _buildErrorWidget(
          'Unexpected state in media repository',
        );
      },
    );
  }

  Widget _buildMediaCubitProvider(
    BuildContext context,
    MediaRepository mediaRepository,
    AppUser user,
  ) {
    final chatCubit =
        context
            .read<
              ChatCubit
            >();
    return BlocProvider<
      MediaCubit
    >(
      create:
          (
            _,
          ) => MediaCubit(
            repository:
                mediaRepository,
            chatCubit:
                chatCubit,
          ),
      child: BlocListener<
        MediaCubit,
        MediaState
      >(
        listener: (
          context,
          state,
        ) {
          if (state
              is MediaErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
              ),
            );
          }
        },
        child:
            child,
      ),
    );
  }

  Widget _buildAuthenticationScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Text(
              'Please Sign In',
            ),
            ElevatedButton(
              onPressed:
                  () {},
              child: const Text(
                'Sign In',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
    String message,
  ) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color:
                  Colors.red,
              size:
                  60,
            ),
            Text(
              message,
              style: const TextStyle(
                color:
                    Colors.red,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryWidget(
    String message, {
    required VoidCallback onRetry,
  }) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              message,
            ),
            const SizedBox(
              height:
                  16,
            ),
            ElevatedButton(
              onPressed:
                  onRetry,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiPageContent
    extends
        StatelessWidget {
  const _AiPageContent();

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    return Scaffold(
      appBar: _buildAppBar(
        context,
        colorScheme,
      ),
      body:
          const _ChatBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      title: const Text(
        "AI Assistant",
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.archive_outlined,
        ),
        tooltip:
            'Chat Archive',
        onPressed:
            () => _openChatArchive(
              context,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.photo_library_outlined,
          ),
          tooltip:
              'Media Archive',
          onPressed:
              () => _openMediaArchive(
                context,
              ),
        ),
        IconButton(
          icon: const Icon(
            Icons.add,
          ),
          tooltip:
              'New Chat',
          onPressed:
              () =>
                  context
                      .read<
                        ChatCubit
                      >()
                      .createNewChat(),
        ),
      ],
    );
  }

  Future<
    void
  >
  _openChatArchive(
    BuildContext context,
  ) async {
    final cubit =
        context
            .read<
              ChatCubit
            >();
    final state =
        cubit.state;

    if (state
        is ChatLoadingState) {
      return;
    }

    final List<
      Chat
    >
    chats = _getChatsFromState(
      state,
    );
    final String selectedChatId = _getSelectedChatIdFromState(
      state,
    );

    final selectedChat = await Navigator.of(
      context,
    ).push<
      Chat?
    >(
      MaterialPageRoute(
        builder:
            (
              _,
            ) => ChatsArchive(
              chats:
                  chats,
              selectedChatId:
                  selectedChatId,
              onUpdateChat:
                  cubit.updateChat,
              onDeleteChat:
                  cubit.deleteChat,
            ),
      ),
    );

    if (selectedChat !=
        null) {
      cubit.loadChat(
        selectedChat,
      );
    }
  }

  List<
    Chat
  >
  _getChatsFromState(
    ChatState state,
  ) {
    if (state
        is ChatLoadedState) {
      return state.allChats;
    }
    if (state
        is ChatEmptyState) {
      return state.allChats;
    }
    return [];
  }

  String _getSelectedChatIdFromState(
    ChatState state,
  ) {
    if (state
        is ChatLoadedState) {
      return state.currentChat.id;
    }
    return '';
  }

  Future<
    void
  >
  _openMediaArchive(
    BuildContext context,
  ) async {
    final mediaCubit =
        context
            .read<
              MediaCubit
            >();
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder:
            (
              context,
            ) => BlocProvider.value(
              value:
                  mediaCubit,
              child:
                  const MediaArchiveScreen(),
            ),
      ),
    );
  }
}

class _ChatBody
    extends
        StatelessWidget {
  const _ChatBody();

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocConsumer<
      ChatCubit,
      ChatState
    >(
      listenWhen:
          (
            _,
            current,
          ) =>
              current
                  is ChatErrorState,
      listener: (
        context,
        state,
      ) {
        if (state
            is ChatErrorState) {
          _showErrorSnackBar(
            context,
            state.message,
          );
        }
      },
      buildWhen:
          (
            previous,
            current,
          ) =>
              previous.runtimeType !=
                  current.runtimeType ||
              (previous
                      is ChatLoadedState &&
                  current
                      is ChatLoadedState &&
                  previous.currentChat.id !=
                      current.currentChat.id),
      builder: (
        context,
        state,
      ) {
        return switch (state) {
          ChatLoadingState() => const Center(
            child:
                CircularProgressIndicator(),
          ),
          ChatLoadedState() => _ChatView(
            state:
                state,
          ),
          ChatEmptyState() => const _EmptyChatView(),
          _ => const Center(
            child: Text(
              'Something went wrong. Please try again.',
            ),
          ),
        };
      },
    );
  }

  void _showErrorSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        behavior:
            SnackBarBehavior.floating,
        duration: const Duration(
          seconds:
              4,
        ),
        action: SnackBarAction(
          label:
              'Dismiss',
          onPressed:
              () =>
                  ScaffoldMessenger.of(
                    context,
                  ).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

class _ChatView
    extends
        StatelessWidget {
  final ChatLoadedState state;

  const _ChatView({
    required this.state,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    return LlmChatView(
      provider:
          state.provider,
      style: LlmChatViewStyle(
        backgroundColor:
            colorScheme.surface,
        chatInputStyle: ChatInputStyle(
          backgroundColor:
              colorScheme.surface,
          hintText:
              'Ask a question...',
        ),
        llmMessageStyle: LlmMessageStyle(
          decoration: BoxDecoration(
            color:
                colorScheme.surface,
          ),
          markdownStyle: MarkdownStyleSheet.fromTheme(
            ThemeData(
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color:
                      colorScheme.onSurface,
                  fontSize:
                      14.0,
                ),
              ),
            ),
          ),
        ),
      ),
      messageSender: (
        String prompt, {
        required Iterable<
          Attachment
        >
        attachments,
      }) {
        if (prompt.contains(
          '@media',
        )) {
          return _handleMediaPrompt(
            context,
            prompt,
          );
        }
        return state.provider.sendMessageStream(
          prompt,
        );
      },
    );
  }

  _handleMediaPrompt(
    BuildContext context,
    String prompt,
  ) {
    final mediaPrompt =
        prompt
            .replaceAll(
              '@media',
              '',
            )
            .trim();

    try {
      final mediaCubit =
          context
              .read<
                MediaCubit
              >();
      Future.microtask(
        () => mediaCubit.generateMedia(
          prompt:
              mediaPrompt,
        ),
      );
    } catch (
      e
    ) {
      rethrow;
    }
    return state.provider.sendMessageStream(
      prompt,
    );
  }
}

class _EmptyChatView
    extends
        StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size:
                48,
          ),
          const SizedBox(
            height:
                16,
          ),
          Text(
            'No active chat',
            style:
                Theme.of(
                  context,
                ).textTheme.titleLarge,
          ),
          const SizedBox(
            height:
                8,
          ),
          const Text(
            'Please create a new chat to get started',
          ),
          const SizedBox(
            height:
                16,
          ),
          FilledButton.icon(
            onPressed:
                () =>
                    context
                        .read<
                          ChatCubit
                        >()
                        .createNewChat(),
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'Start new chat',
            ),
          ),
        ],
      ),
    );
  }
}
