import '/features/ai/data/models/chat.dart';
import 'package:flutter/material.dart';

class ChatListView extends StatelessWidget {
  final List<Chat> chats;
  final String selectedChatId;
  final void Function(Chat) onChatSelected;
  final void Function(Chat) onRenameChat;
  final void Function(Chat) onDeleteChat;

  const ChatListView({
    required this.chats,
    required this.selectedChatId,
    required this.onChatSelected,
    required this.onRenameChat,
    required this.onDeleteChat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[chats.length - index - 1];
        final isSelected = chat.id == selectedChatId;
        final chatTitle = chat.title.isNotEmpty ? chat.title : "Untitled";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            key: ValueKey(chat.id),
            selected: isSelected,
            selectedTileColor: Theme.of(context).highlightColor,
            leading:
                isSelected
                    ? const Icon(Icons.chevron_right)
                    : const SizedBox(width: 24),
            title: Tooltip(
              message: chatTitle,
              child: Text(chatTitle, overflow: TextOverflow.ellipsis),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Rename Chat',
                  onPressed: () => onRenameChat(chat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Chat',
                  onPressed: () => onDeleteChat(chat),
                ),
              ],
            ),
            onTap: () => onChatSelected(chat),
          ),
        );
      },
    );
  }
}
