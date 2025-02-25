import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_app/core/firebase/firebase_options.dart';
import 'package:edu_app/core/theme/theme.dart';
import 'package:edu_app/core/router/app_router.dart';
import 'package:edu_app/features/ai/data/repository/chat_repository.dart';
import 'package:edu_app/features/auth/login_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(EduApp());
}

class EduApp extends StatefulWidget {
  EduApp({super.key}) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      LoginInfo.instance.user = user;
      ChatRepository.user = user;
    });
  }

  @override
  State<EduApp> createState() => _EduAppState();
}

class _EduAppState extends State<EduApp> {
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Edu App',
    theme: AppTheme.darkTheme,
    routerConfig: AppRouter.router,
    debugShowCheckedModeBanner: false,
  );
}
