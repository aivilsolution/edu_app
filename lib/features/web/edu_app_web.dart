import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:edu_app/core/config/env_config.dart';
import 'package:edu_app/core/firebase/firebase_options.dart';
import 'package:edu_app/core/router/app_router.dart';
import 'package:edu_app/core/theme/theme.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/enrollment_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/student_cubit.dart';
import 'package:edu_app/shared/widgets/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_app/features/course/repositories/course_repository.dart';
import 'package:edu_app/features/course/repositories/enrollment_repository.dart';
import 'package:edu_app/features/course/repositories/professor_repository.dart';
import 'package:edu_app/features/course/repositories/student_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    if (kDebugMode) {
      print('onChange(${bloc.runtimeType}, $change)');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('onError(${bloc.runtimeType}, $error, $stackTrace)');
    }
    super.onError(bloc, error, stackTrace);
  }
}

extension AuthContextExtension on BuildContext {
  AuthBloc get authBloc => read<AuthBloc>();
  AuthState get authState => read<AuthBloc>().state;
  bool get isAuthenticated => authState.status == AuthStatus.authenticated;
  AppUser? get currentUser => authState.user;
  String? get currentUserId => currentUser?.uid;
  Future<void> signOut() async => authBloc.add(AuthSignOutRequested());
}

enum AppInitStep {
  notStarted,
  sharedPreferences,
  authRepository,
  authBloc,
  courseRepository,
  professorRepository,
  studentRepository,
  enrollmentRepository,
  cubits,
  completed,
}

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

  static Future<AppDependencies> initialize({
    void Function(AppInitStep, double)? onProgress,
  }) async {
    
    onProgress?.call(AppInitStep.notStarted, 0.0);

    
    onProgress?.call(AppInitStep.sharedPreferences, 0.1);
    final prefs = await SharedPreferences.getInstance();

    
    onProgress?.call(AppInitStep.authRepository, 0.2);
    final authRepository = AuthRepository(prefs: prefs);

    
    onProgress?.call(AppInitStep.authBloc, 0.3);
    final authBloc = AuthBloc(authRepository);

    
    authBloc.add(AuthStarted());

    
    onProgress?.call(AppInitStep.courseRepository, 0.4);
    final repositoryFutures = await Future.wait([
      Future(() => FirebaseCourseRepository()),
      Future(() => FirebaseProfessorRepository()),
      Future(() => FirebaseStudentRepository()),
      Future(() => FirebaseEnrollmentRepository()),
    ]);

    final courseRepository = repositoryFutures[0] as FirebaseCourseRepository;
    onProgress?.call(AppInitStep.professorRepository, 0.4);
    final professorRepository =
        repositoryFutures[1] as FirebaseProfessorRepository;
    onProgress?.call(AppInitStep.studentRepository, 0.5);
    final studentRepository = repositoryFutures[2] as FirebaseStudentRepository;
    onProgress?.call(AppInitStep.enrollmentRepository, 0.6);
    final enrollmentRepository =
        repositoryFutures[3] as FirebaseEnrollmentRepository;

    
    onProgress?.call(AppInitStep.cubits, 0.8);
    final courseCubit = CourseCubit(courseRepository);
    final professorCubit = ProfessorCubit(professorRepository);
    final studentCubit = StudentCubit(studentRepository);
    final enrollmentCubit = EnrollmentCubit(enrollmentRepository);

    
    onProgress?.call(AppInitStep.completed, 1.0);
    return AppDependencies._(
      prefs: prefs,
      authRepository: authRepository,
      authBloc: authBloc,
      courseRepository: courseRepository,
      courseCubit: courseCubit,
      professorRepository: professorRepository,
      professorCubit: professorCubit,
      studentRepository: studentRepository,
      studentCubit: studentCubit,
      enrollmentRepository: enrollmentRepository,
      enrollmentCubit: enrollmentCubit,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  if (!const bool.fromEnvironment('dart.vm.product')) {
    Bloc.observer = AppBlocObserver();
  }
  runApp(const EduAppWeb());
}

class EduAppWeb extends StatefulWidget {
  const EduAppWeb({super.key});

  @override
  State<EduAppWeb> createState() => _EduAppWebState();
}

class _EduAppWebState extends State<EduAppWeb> {
  
  static const _githubUrl = 'https:
  static const String _videoUrl =
      'https:

  static const String _apkDownloadUrl =
      'https:

  
  AppDependencies? _dependencies;
  dynamic _initializationError;
  bool _isLoadingOverlayVisible = false;
  bool _userRequestedEntry = false;
  bool _isFirebaseInitialized = false;

  
  AppInitStep _currentStep = AppInitStep.notStarted;
  double _loadingProgress = 0.0;
  String _loadingMessage = 'Preparing...';

  
  late final Future<FirebaseApp> _firebaseInitFuture = _initializeFirebase();

  @override
  void initState() {
    super.initState();
    
  }

  Future<FirebaseApp> _initializeFirebase() async {
    try {
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseAuth.instance.setLanguageCode('en');
      if (mounted) setState(() => _isFirebaseInitialized = true);
      return app;
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  void _updateProgress(AppInitStep step, double progress) {
    if (!mounted) return;

    setState(() {
      _currentStep = step;
      _loadingProgress = progress;
      _loadingMessage = _getMessageForStep(step);
    });
  }

  String _getMessageForStep(AppInitStep step) {
    switch (step) {
      case AppInitStep.notStarted:
        return 'Preparing to load...';
      case AppInitStep.sharedPreferences:
        return 'Loading preferences...';
      case AppInitStep.authRepository:
        return 'Setting up authentication...';
      case AppInitStep.authBloc:
        return 'Initializing authentication...';
      case AppInitStep.courseRepository:
        return 'Loading course data...';
      case AppInitStep.professorRepository:
        return 'Loading professor data...';
      case AppInitStep.studentRepository:
        return 'Loading student data...';
      case AppInitStep.enrollmentRepository:
        return 'Loading enrollment data...';
      case AppInitStep.cubits:
        return 'Setting up state management...';
      case AppInitStep.completed:
        return 'Almost ready!';
    }
  }

  Future<void> _initializeAppDependencies() async {
    if (_dependencies != null) return;

    setState(() => _isLoadingOverlayVisible = true);

    try {
      if (!_isFirebaseInitialized) {
        setState(() {
          _loadingMessage = 'Initializing Firebase...';
          _loadingProgress = 0.05;
        });
        await _firebaseInitFuture;
      }

      
      final dependencies = await AppDependencies.initialize(
        onProgress: _updateProgress,
      );

      if (mounted) {
        setState(() {
          _dependencies = dependencies;
          _initializationError = null;
          _isLoadingOverlayVisible = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error initializing app dependencies: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _initializationError = e;
          _isLoadingOverlayVisible = false;
        });
      }
    }
  }

  void _requestAppEntry() {
    if (_isLoadingOverlayVisible || _initializationError != null) return;

    setState(() => _userRequestedEntry = true);
    _initializeAppDependencies();
  }

  Future<void> _launchUrl(String url, String errorMessage) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error launching URL: ${e.toString()}');
    }
  }

  Future<void> _launchGitHub() async =>
      await _launchUrl(_githubUrl, 'Failed to open GitHub repository');

  Future<void> _downloadApk() async =>
      await _launchUrl(_apkDownloadUrl, 'Failed to download APK');
  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      print("Snackbar Error: $message (Context unavailable)");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canEnterApp = _dependencies != null && _userRequestedEntry;

    if (canEnterApp) {
      return _MainApp(dependencies: _dependencies!);
    } else {
      return MaterialApp(
        title: 'Edu App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        shortcuts: const <ShortcutActivator, Intent>{},
        home: Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: _LandingContent(
                  onLaunchApp: _requestAppEntry,
                  onLaunchGitHub: _launchGitHub,
                  onDownloadApk: _downloadApk,
                  videoUrl: _videoUrl,
                  initializationError: _initializationError,
                ),
              ),
              if (_isLoadingOverlayVisible)
                _LoadingOverlay(
                  progress: _loadingProgress,
                  message: _loadingMessage,
                  step: _currentStep,
                ),
            ],
          ),
        ),
      );
    }
  }
}

class _LandingContent extends StatelessWidget {
  final VoidCallback onLaunchApp;
  final VoidCallback onLaunchGitHub;
  final VoidCallback onDownloadApk;
  final String videoUrl;
  final dynamic initializationError;

  const _LandingContent({
    required this.onLaunchApp,
    required this.onLaunchGitHub,
    required this.onDownloadApk,
    required this.videoUrl,
    this.initializationError,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Header(),
              const SizedBox(height: 24),

              if (initializationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _ErrorDisplay(error: initializationError),
                ),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1000) {
                    return _buildWideLayout(context);
                  } else if (constraints.maxWidth > 650) {
                    return _buildMediumLayout(context);
                  } else {
                    return _buildNarrowLayout(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _LazyVideoPlayerContainer(videoUrl: videoUrl)),
        const Spacer(flex: 1),
        const _VerticalDivider(height: 300),
        const Spacer(flex: 1),
        _ActionButtons(
          onEnterApp: onLaunchApp,
          onLaunchGitHub: onLaunchGitHub,
          onDownloadApk: onDownloadApk,
          isEnterAppDisabled: initializationError != null,
        ),
      ],
    );
  }

  Widget _buildMediumLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: _LazyVideoPlayerContainer(videoUrl: videoUrl)),
        const SizedBox(width: 30),
        Expanded(
          flex: 4,
          child: _ActionButtons(
            onEnterApp: onLaunchApp,
            onLaunchGitHub: onLaunchGitHub,
            onDownloadApk: onDownloadApk,
            isEnterAppDisabled: initializationError != null,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LazyVideoPlayerContainer(videoUrl: videoUrl),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: _HorizontalDivider(),
        ),
        _ActionButtons(
          onEnterApp: onLaunchApp,
          onLaunchGitHub: onLaunchGitHub,
          onDownloadApk: onDownloadApk,
          isEnterAppDisabled: initializationError != null,
        ),
      ],
    );
  }
}


class _LazyVideoPlayerContainer extends StatefulWidget {
  final String videoUrl;

  const _LazyVideoPlayerContainer({required this.videoUrl});

  @override
  State<_LazyVideoPlayerContainer> createState() =>
      _LazyVideoPlayerContainerState();
}

class _LazyVideoPlayerContainerState extends State<_LazyVideoPlayerContainer> {
  bool _userInteracted = false; 
  final _visibilityKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
  }

  void _loadVideo() {
    if (!mounted) return;
    setState(() => _userInteracted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _visibilityKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child:
            _userInteracted
                ? AppVideoPlayer(
                  videoUrl: widget.videoUrl,
                  autoPlay: true,
                  showControls: true,
                  looping: false,
                  onError: (error) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text('Error playing video: $error'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )
                : GestureDetector(
                  onTap: _loadVideo,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Click to load video',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}

class _MainApp extends StatefulWidget {
  final AppDependencies dependencies;

  const _MainApp({required this.dependencies});

  @override
  State<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> {
  late final List<BlocProvider> _blocProviders;

  @override
  void initState() {
    super.initState();
    _blocProviders = _createBlocProviders(widget.dependencies);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeRouter());
  }

  void _initializeRouter() {
    if (!mounted) return;
    try {
      AppRouter.initializeRefreshListenable(context);
    } catch (e) {
      print("Error initializing router refresh listenable: $e");
    }
  }

  List<BlocProvider> _createBlocProviders(AppDependencies dependencies) => [
    BlocProvider<AuthBloc>.value(value: dependencies.authBloc),
    BlocProvider<CourseCubit>.value(value: dependencies.courseCubit),
    BlocProvider<ProfessorCubit>.value(value: dependencies.professorCubit),
    BlocProvider<StudentCubit>.value(value: dependencies.studentCubit),
    BlocProvider<EnrollmentCubit>.value(value: dependencies.enrollmentCubit),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _blocProviders,
      child: DevicePreview(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        isToolbarVisible: false,
        builder:
            (context) => MaterialApp.router(
              locale: DevicePreview.locale(context),
              builder: (context, child) {
                return DevicePreview.appBuilder(context, child);
              },
              title: 'Edu App',
              theme: AppTheme.darkTheme,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
            ),
      ),
    );
  }
}


class _ActionButtons extends StatelessWidget {
  final VoidCallback onEnterApp;
  final VoidCallback onLaunchGitHub;
  final VoidCallback onDownloadApk;
  final bool isEnterAppDisabled;

  const _ActionButtons({
    required this.onEnterApp,
    required this.onLaunchGitHub,
    required this.onDownloadApk,
    this.isEnterAppDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonWidth =
            constraints.maxWidth > 360 ? 320.0 : constraints.maxWidth - 40;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AppButton(
              onPressed: isEnterAppDisabled ? null : onEnterApp,
              width: buttonWidth,
            ),
            const SizedBox(height: 20),
            _DownloadApkButton(onPressed: onDownloadApk, width: buttonWidth),
            const SizedBox(height: 20),
            _GitHubButton(onPressed: onLaunchGitHub, width: buttonWidth),
          ],
        );
      },
    );
  }
}

class _AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;

  const _AppButton({required this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDisabled = onPressed == null;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled
                  ? colorScheme.onSurface.withOpacity(0.12)
                  : colorScheme.primary,
          foregroundColor:
              isDisabled
                  ? colorScheme.onSurface.withOpacity(0.38)
                  : colorScheme.onPrimary,
          minimumSize: const Size(0, 60),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: isDisabled ? 0 : 3,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed) && !isDisabled) {
              return colorScheme.onPrimary.withAlpha(25);
            }
            return null;
          }),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch,
              size: 24,
              color:
                  isDisabled
                      ? colorScheme.onSurface.withOpacity(0.38)
                      : colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Enter Edu App',
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isDisabled
                          ? colorScheme.onSurface.withOpacity(0.38)
                          : colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GitHubButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width;

  const _GitHubButton({required this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(77),
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(0, 60),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          side: BorderSide(
            color: colorScheme.primary.withAlpha(178),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Source Code',
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadApkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width;

  const _DownloadApkButton({required this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(77),
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(0, 60),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          side: BorderSide(
            color: colorScheme.secondary.withAlpha(178),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Download APK',
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: Hero(
            tag: '',
            child: Text(
              'AIVIL',
              style: AppTextTheme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                fontSize: isSmallScreen ? 60 : 72,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The Team',
          style: AppTextTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 2.0,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final double progress;
  final String message;
  final AppInitStep step;

  const _LoadingOverlay({
    required this.progress,
    required this.message,
    required this.step,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final totalSteps = AppInitStep.values.length - 1; 
    final currentStepIndex = step.index;

    return RepaintBoundary(
      child: Container(
        color: colorScheme.surface.withOpacity(0.9),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                          colorScheme.tertiary,
                        ],
                      ).createShader(bounds),
                  child: const Icon(
                    Icons.school,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading Edu App',
                  style: AppTextTheme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainerLow,
                  color: colorScheme.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: AppTextTheme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalSteps, (index) {
                    bool isActive = index < currentStepIndex;
                    bool isCurrent = index == currentStepIndex - 1;
                    double size = isCurrent ? 10 : 8;

                    return Container(
                      width: size,
                      height: size,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isActive || isCurrent
                                ? isCurrent
                                    ? colorScheme.primary
                                    : colorScheme.primary.withOpacity(0.6)
                                : colorScheme.surfaceContainerLow,
                        border:
                            isCurrent
                                ? Border.all(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  width: 2,
                                )
                                : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final dynamic error;

  const _ErrorDisplay({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to initialize the app. Please try refreshing the page.\nError: $error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final double height;
  final double thickness;

  const _VerticalDivider({required this.height, this.thickness = 1.5});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      width: thickness,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withAlpha(51),
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary.withAlpha(51),
          ],
        ),
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );
  }
}

class _HorizontalDivider extends StatelessWidget {
  final double thickness;

  const _HorizontalDivider({this.thickness = 1.5});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: thickness,
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary.withAlpha(51),
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary.withAlpha(51),
          ],
        ),
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );
  }
}
