import 'package:edu_app/features/communication/cubit/chat_cubit.dart';
import 'package:edu_app/features/communication/cubit/chat_state.dart';
import 'package:edu_app/features/communication/models/user.dart';
import 'package:edu_app/features/communication/providers/communication_providers.dart';
import 'package:edu_app/features/communication/views/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ChatProvider.of(context).loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Chats', style: textTheme.titleLarge)),
      body: BlocConsumer<ChatCubit, ChatState>(
        listenWhen: (prev, curr) => curr is ChatError,
        listener: (context, state) {
          if (state is ChatError) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        },
        buildWhen: (prev, curr) => curr is! ChatError,
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatLoaded) {
            return _UserList(users: state.users);
          }
          return const Center(child: Text('No users found'));
        },
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;

  const _UserList({required this.users});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (users.isEmpty) {
      return Center(
        child: Text('No users available', style: textTheme.displayLarge),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null ? Text(user.initials) : null,
          ),
          title: Text(user.username, style: textTheme.bodyMedium),
          subtitle: Text(user.email, style: textTheme.bodyMedium),
          onTap: () => _navigateToChatScreen(context, user),
        );
      },
    );
  }

  void _navigateToChatScreen(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: MessageProvider.of(context),
              child: ChatScreen(user: user),
            ),
      ),
    );
  }
}
