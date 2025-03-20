import 'package:edu_app/features/auth/bloc/auth_cubit.dart';
import 'package:edu_app/features/auth/bloc/auth_state.dart' as auth_state;
import 'package:edu_app/features/communication/views/screens/chat_list_screen.dart';
import 'package:edu_app/features/home/views/screens/home_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_app/features/communication/providers/communication_providers.dart';

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [ChatProvider(), MessageProvider()],
      child: BlocListener<AuthCubit, auth_state.AuthState>(
        listener: (context, state) {
          if (state is auth_state.AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is auth_state.AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          }
        },
        child: const ChatListScreen(),
      ),
    );
  }
}
