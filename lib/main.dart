import 'package:edu_app/features/ai/data/repository/media_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/firebase/firebase_options.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'core/config/env_config.dart';
import 'features/ai/data/repository/chat_repository.dart';
import 'features/auth/login_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EduApp());
}

class EduApp extends StatefulWidget {
  const EduApp({super.key});

  @override
  State<EduApp> createState() => _EduAppState();
}

class _EduAppState extends State<EduApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListeners();
  }

  void _setupAuthListeners() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      LoginInfo.instance.user = user;
      ChatRepository.user = user;
      MediaRepository.user = user;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Edu App',
    theme: AppTheme.darkTheme,
    routerConfig: AppRouter.router,
    debugShowCheckedModeBanner: false,
  );
}
