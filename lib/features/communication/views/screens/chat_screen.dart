import 'package:edu_app/features/auth/auth.dart';
import 'package:edu_app/features/communication/cubit/message_cubit.dart';
import 'package:edu_app/features/communication/cubit/message_state.dart';
import 'package:edu_app/features/communication/models/message.dart';
import 'package:edu_app/features/communication/models/user.dart';
import 'package:edu_app/features/communication/utils/debouncer.dart';
import 'package:edu_app/features/communication/views/widgets/date_separator.dart';
import 'package:edu_app/features/communication/views/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  late final MessageCubit _messageCubit;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageCubit = context.read<MessageCubit>();
    _messageController.addListener(_onTextChanged);

    Future.microtask(() {
      _messageCubit.loadMessages(widget.user.uid);
    });
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = _messageController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageCubit.sendMessage(receiverId: widget.user.uid, message: message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _debouncer.run(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Hero(
              tag: 'avatar-${widget.user.uid}',
              child: CircleAvatar(
                backgroundImage:
                    widget.user.photoUrl != null
                        ? NetworkImage(widget.user.photoUrl!)
                        : null,
                backgroundColor:
                    widget.user.photoUrl == null
                        ? colorScheme.primaryContainer
                        : null,
                foregroundColor: colorScheme.onPrimaryContainer,
                radius: 20,
                child:
                    widget.user.photoUrl == null
                        ? Text(
                          widget.user.initials,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.username,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildOptionsSheet(context),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color:
              isDark
                  ? colorScheme.surface
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          image:
              isDark
                  ? null
                  : DecorationImage(
                    image: const AssetImage('assets/images/chat_bg.png'),
                    opacity: 0.03,
                    fit: BoxFit.cover,
                  ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<MessageCubit, MessageState>(
                  listener: (context, state) {
                    if (state is MessageLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(),
                      );
                    } else if (state is MessageError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is MessageLoading) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading conversation...',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is MessageLoaded) {
                      return _MessageList(
                        messages: state.messages,
                        scrollController: _scrollController,
                      );
                    }
                    return _EmptyConversation(user: widget.user);
                  },
                ),
              ),
              _MessageInput(
                controller: _messageController,
                onSend: _sendMessage,
                isTyping: _isTyping,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.search, color: colorScheme.primary),
            title: Text('Search conversation', style: textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_off, color: colorScheme.primary),
            title: Text('Mute notifications', style: textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: colorScheme.error),
            title: Text(
              'Delete conversation',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<MessageModel> messages;
  final ScrollController scrollController;

  const _MessageList({required this.messages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final currentUserId = context.read<AuthBloc>().state.user?.id ?? '';
        final isCurrentUser = message.senderId == currentUserId;
        final showDate = _shouldShowDateSeparator(index);
        final isConsecutive = _isConsecutiveMessage(index, isCurrentUser);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDate) DateSeparator(date: message.timestamp.toDate()),
            Padding(
              padding: EdgeInsets.only(top: isConsecutive ? 2 : 12, bottom: 2),
              child: MessageBubble(
                message: message,
                isCurrentUser: isCurrentUser,
                isConsecutive: isConsecutive,
              ),
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;

    final currentDate = messages[index].timestamp.toDate();
    final previousDate = messages[index - 1].timestamp.toDate();

    return !_isSameDay(currentDate, previousDate);
  }

  bool _isConsecutiveMessage(int index, bool isCurrentUser) {
    if (index == 0) return false;

    final previousSenderId = messages[index - 1].senderId;
    final currentSenderId = messages[index].senderId;
    final previousDate = messages[index - 1].timestamp.toDate();
    final currentDate = messages[index].timestamp.toDate();

    return previousSenderId == currentSenderId &&
        _isSameDay(previousDate, currentDate) &&
        currentDate.difference(previousDate).inMinutes < 2;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptyConversation extends StatelessWidget {
  final UserModel user;

  const _EmptyConversation({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.chat_outlined,
              size: 36,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start chatting with ${user.username}',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Send a message to begin your conversation',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isTyping;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.isTyping,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
              onPressed: () {
                _showAttachmentOptions(context);
              },
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isTyping
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isTyping ? Icons.send : Icons.mic,
                  color:
                      isTyping
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                onPressed: isTyping ? onSend : () {},
                tooltip: isTyping ? 'Send message' : 'Record voice message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share content',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AttachmentOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.attach_file,
                      label: 'Document',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: textTheme.labelMedium),
        ],
      ),
    );
  }
}
