import 'package:edu_app/core/config/env_config.dart';
import 'package:edu_app/core/di/app_dependencies.dart';
import 'package:edu_app/core/firebase/firebase_options.dart';
import 'package:edu_app/core/theme/theme.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/enrollment_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/student_cubit.dart';
import 'package:edu_app/features/web/edu_app_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await _initializeFirebase();

  if (!const bool.fromEnvironment('dart.vm.product')) {
    Bloc.observer = AppBlocObserver();
  }

  final dependencies = await AppDependencies.initialize();

  if (kIsWeb) {
    runApp(EduAppWeb(dependencies: dependencies));
  } else {
    runApp(EduApp(dependencies: dependencies));
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode('en');
}

class EduApp extends StatelessWidget {
  final AppDependencies dependencies;

  const EduApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => dependencies.authBloc),
        BlocProvider<CourseCubit>(
          create: (context) => dependencies.courseCubit,
        ),
        BlocProvider<ProfessorCubit>(
          create: (context) => dependencies.professorCubit,
        ),
        BlocProvider<StudentCubit>(
          create: (context) => dependencies.studentCubit,
        ),
        BlocProvider<EnrollmentCubit>(
          create: (context) => dependencies.enrollmentCubit,
        ),
      ],
      child: MaterialApp.router(
        title: 'Edu App',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppBlocObserver extends BlocObserver {}

extension AuthContextExtension on BuildContext {
  AuthBloc get authBloc => read<AuthBloc>();
  AuthState get authState => read<AuthBloc>().state;
  bool get isAuthenticated => authState.status == AuthStatus.authenticated;
  AppUser? get currentUser => authState.user;
  String? get currentUserId => currentUser?.uid;
  Future<void> signOut() async => authBloc.add(AuthSignOutRequested());
}
