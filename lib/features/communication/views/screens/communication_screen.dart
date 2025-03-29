import 'package:edu_app/features/auth/auth.dart' as auth;
import 'package:edu_app/features/auth/login_page.dart';
import 'package:edu_app/features/communication/views/screens/chat_list_screen.dart';
import 'package:edu_app/features/home/views/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_app/features/communication/providers/communication_providers.dart';

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [ChatProvider(), MessageProvider()],
      child: BlocListener<auth.AuthBloc, auth.AuthState>(
        listener: (context, state) {
          if (state.status == auth.AuthStatus.authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state.status == auth.AuthStatus.unauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: const ChatListScreen(),
      ),
    );
  }
}
