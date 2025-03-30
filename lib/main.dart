import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/enrollment_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/student_cubit.dart';
import 'package:edu_app/features/course/repositories/enrollment_repository.dart';
import 'package:edu_app/features/course/repositories/course_repository.dart';
import 'package:edu_app/features/course/repositories/professor_repository.dart';
import 'package:edu_app/features/course/repositories/student_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/env_config.dart';
import 'core/firebase/firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

class AppDependencies {
  final SharedPreferences prefs;
  final AuthRepository authRepository;
  final AuthBloc authBloc;
  final FirebaseCourseRepository courseRepository;
  final CourseCubit courseCubit;
  final FirebaseProfessorRepository professorRepository;
  final ProfessorCubit professorCubit;
  final FirebaseStudentRepository studentRepository;
  final StudentCubit studentCubit;
  final FirebaseEnrollmentRepository enrollmentRepository;
  final EnrollmentCubit enrollmentCubit;

  AppDependencies._({
    required this.prefs,
    required this.authRepository,
    required this.authBloc,
    required this.courseRepository,
    required this.courseCubit,
    required this.professorRepository,
    required this.professorCubit,
    required this.studentRepository,
    required this.studentCubit,
    required this.enrollmentRepository,
    required this.enrollmentCubit,
  });

  static Future<
    AppDependencies
  >
  initialize() async {
    final prefs =
        await SharedPreferences.getInstance();
    final authRepository = AuthRepository(
      prefs:
          prefs,
    );
    final authBloc = AuthBloc(
      authRepository,
    );
    final courseRepository =
        FirebaseCourseRepository();
    final courseCubit = CourseCubit(
      courseRepository,
    );
    final professorRepository =
        FirebaseProfessorRepository();
    final professorCubit = ProfessorCubit(
      professorRepository,
    );
    final studentRepository =
        FirebaseStudentRepository();
    final studentCubit = StudentCubit(
      studentRepository,
    );
    final enrollmentRepository =
        FirebaseEnrollmentRepository();
    final enrollmentCubit = EnrollmentCubit(
      enrollmentRepository,
    );

    authBloc.add(
      AuthStarted(),
    );

    return AppDependencies._(
      prefs:
          prefs,
      authRepository:
          authRepository,
      authBloc:
          authBloc,
      courseRepository:
          courseRepository,
      courseCubit:
          courseCubit,
      professorRepository:
          professorRepository,
      professorCubit:
          professorCubit,
      studentRepository:
          studentRepository,
      studentCubit:
          studentCubit,
      enrollmentRepository:
          enrollmentRepository,
      enrollmentCubit:
          enrollmentCubit,
    );
  }
}

Future<
  void
>
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await _initializeFirebase();
  if (!const bool.fromEnvironment(
    'dart.vm.product',
  )) {
    Bloc.observer = AppBlocObserver();
  }
  final dependencies =
      await AppDependencies.initialize();
  runApp(
    DevicePreview(
      enabled:
          kIsWeb,
      isToolbarVisible:
          false,
      backgroundColor:
          AppTheme.darkTheme.colorScheme.surface,
      builder:
          (
            context,
          ) => EduApp(
            dependencies:
                dependencies,
          ),
    ),
  );
}

Future<
  void
>
_initializeFirebase() async {
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.setLanguageCode(
    'en',
  );
}

class EduApp
    extends
        StatelessWidget {
  final AppDependencies dependencies;

  const EduApp({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<
          AuthBloc
        >(
          create:
              (
                context,
              ) =>
                  dependencies.authBloc,
        ),
        BlocProvider<
          CourseCubit
        >(
          create:
              (
                context,
              ) =>
                  dependencies.courseCubit,
        ),
        BlocProvider<
          ProfessorCubit
        >(
          create:
              (
                context,
              ) =>
                  dependencies.professorCubit,
        ),
        BlocProvider<
          StudentCubit
        >(
          create:
              (
                context,
              ) =>
                  dependencies.studentCubit,
        ),
        BlocProvider<
          EnrollmentCubit
        >(
          create:
              (
                context,
              ) =>
                  dependencies.enrollmentCubit,
        ),
      ],
      child: MaterialApp.router(
        title:
            'Edu App',
        theme:
            AppTheme.darkTheme,
        routerConfig:
            AppRouter.router,
        debugShowCheckedModeBanner:
            false,
        locale: DevicePreview.locale(
          context,
        ),
        builder:
            DevicePreview.appBuilder,
      ),
    );
  }
}

class AppBlocObserver
    extends
        BlocObserver {
  @override
  void onChange(
    BlocBase bloc,
    Change change,
  ) {
    super.onChange(
      bloc,
      change,
    );
  }

  @override
  void onError(
    BlocBase bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    super.onError(
      bloc,
      error,
      stackTrace,
    );
  }
}

extension AuthContextExtension
    on
        BuildContext {
  AuthBloc get authBloc =>
      read<
        AuthBloc
      >();
  AuthState
  get authState =>
      read<
            AuthBloc
          >()
          .state;
  bool get isAuthenticated =>
      authState.status ==
      AuthStatus.authenticated;
  AppUser? get currentUser =>
      authState.user;
  String? get currentUserId =>
      currentUser?.id;
  Future<
    void
  >
  signOut() async => authBloc.add(
    AuthSignOutRequested(),
  );
}
