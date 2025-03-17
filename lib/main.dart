import 'package:edu_app/features/auth/bloc/auth_cubit.dart';
import 'package:edu_app/features/auth/bloc/auth_state.dart';
import 'package:edu_app/features/auth/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/env_config.dart';
import 'core/firebase/firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await _initializeFirebase();
  if (!const bool.fromEnvironment('dart.vm.product')) {
    Bloc.observer = AppBlocObserver();
  }

  final authService = FirebaseAuthService();
  final authCubit = AuthCubit(authService: authService);

  await authCubit.initializeAuthState();

  runApp(EduApp(authCubit: authCubit));
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode('en');
}

class EduApp extends StatelessWidget {
  final AuthCubit authCubit;

  const EduApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>(create: (context) => authCubit)],
      child: MaterialApp.router(
        title: 'Edu App',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
}

extension AuthContextExtension on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();
  AuthState get authState => read<AuthCubit>().state;
  bool get isAuthenticated => authState.isAuthenticated;
  AuthUser? get currentUser => authState.user;
  String? get currentUserId => currentUser?.uid;
  UserRole? get userRole => currentUser?.role;
  bool get isStudent => authState.isStudent;
  bool get isProfessor => authState.isProfessor;
  bool get isAdmin => authState.isAdmin;
  bool get isStaff => authState.isStaff;
  Future<void> signOut() => authCubit.signOut();
}
