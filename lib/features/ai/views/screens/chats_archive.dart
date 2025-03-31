import '/features/ai/data/models/chat.dart';
import '/features/ai/views/widgets/chat_list_view.dart';
import 'package:flutter/material.dart';

class ChatsArchive extends StatefulWidget {
  final List<Chat> chats;
  final String selectedChatId;
  final Function(Chat) onUpdateChat;
  final Function(Chat) onDeleteChat;

  const ChatsArchive({
    super.key,
    required this.chats,
    required this.selectedChatId,
    required this.onUpdateChat,
    required this.onDeleteChat,
  });

  @override
  State<ChatsArchive> createState() => _ChatsArchiveState();
}

class _ChatsArchiveState extends State<ChatsArchive> {
  late String _selectedChatId = widget.selectedChatId;
  late List<Chat> _chats = widget.chats;

  void _onChatSelected(Chat chat) {
    setState(() => _selectedChatId = chat.id);
    Navigator.pop(context, chat);
  }

  Future<void> _onRenameChat(Chat chat) async {
    final controller = TextEditingController(text: chat.title);

    final newTitle = await showDialog<String?>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename Chat'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'New Title'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Rename'),
              ),
            ],
          ),
    );

    if (newTitle != null &&
        newTitle.trim().isNotEmpty &&
        newTitle.trim() != chat.title) {
      try {
        final updatedChat = Chat(id: chat.id, title: newTitle.trim());
        widget.onUpdateChat(updatedChat);

        setState(() {
          _chats =
              _chats.map((c) => c.id == chat.id ? updatedChat : c).toList();
        });
      } catch (e) {
        _showErrorSnackBar('Failed to rename chat', e);
      }
    }
  }

  Future<void> _onDeleteChat(Chat chat) async {
    final confirm = await showDialog<bool?>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text('Are you sure you want to delete "${chat.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        widget.onDeleteChat(chat);

        setState(() {
          _chats = _chats.where((c) => c.id != chat.id).toList();
        });
      } catch (e) {
        _showErrorSnackBar('Failed to delete chat', e);
      }
    }
  }

  void _showErrorSnackBar(String message, Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message: $error')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats Archive')),
      body:
          _chats.isEmpty
              ? const Center(child: Text('No chats available'))
              : ChatListView(
                key: const ValueKey('chat-list'),
                chats: _chats,
                selectedChatId: _selectedChatId,
                onChatSelected: _onChatSelected,
                onRenameChat: _onRenameChat,
                onDeleteChat: _onDeleteChat,
              ),
    );
  }
}
