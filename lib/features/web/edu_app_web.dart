import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:edu_app/core/di/app_dependencies.dart';
import 'package:edu_app/core/router/app_router.dart';
import 'package:edu_app/core/theme/theme.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/enrollment_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/student_cubit.dart';
import 'package:edu_app/shared/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class EduAppWeb extends StatefulWidget {
  final AppDependencies dependencies;

  const EduAppWeb({super.key, required this.dependencies});

  @override
  State<EduAppWeb> createState() => _EduAppWebState();
}

class _EduAppWebState extends State<EduAppWeb> {
  bool _showLandingPage = true;
  bool _isLoading = false;

  static const _githubUrl = 'https://github.com/aivilsolution/edu_app.git';
  static const _appLaunchDelay = Duration(milliseconds: 1200);
  static const String _videoUrl =
      'https://firebasestorage.googleapis.com/v0/b/edu-app-b4451.firebasestorage.app/o/video.mp4?alt=media&token=8695b5b6-0cee-4fc6-9276-7f316eef7ae6';

  void _launchEduApp() {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    Future.delayed(_appLaunchDelay, () {
      if (mounted) {
        setState(() {
          _showLandingPage = false;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _launchGitHub() async {
    try {
      final uri = Uri.parse(_githubUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to open GitHub repository')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showLandingPage
        ? _LandingPage(
          isLoading: _isLoading,
          onLaunchApp: _launchEduApp,
          onLaunchGitHub: _launchGitHub,
          videoUrl: _videoUrl,
        )
        : _MainApp(dependencies: widget.dependencies);
  }
}

class _MainApp extends StatelessWidget {
  final AppDependencies dependencies;

  const _MainApp({required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      isToolbarVisible: false,
      builder:
          (context) => MultiBlocProvider(
            providers: _createBlocProviders(),
            child: MaterialApp.router(
              title: 'Edu App',
              theme: AppTheme.darkTheme,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
            ),
          ),
    );
  }

  List<BlocProvider> _createBlocProviders() => [
    BlocProvider<AuthBloc>(create: (_) => dependencies.authBloc),
    BlocProvider<CourseCubit>(create: (_) => dependencies.courseCubit),
    BlocProvider<ProfessorCubit>(create: (_) => dependencies.professorCubit),
    BlocProvider<StudentCubit>(create: (_) => dependencies.studentCubit),
    BlocProvider<EnrollmentCubit>(create: (_) => dependencies.enrollmentCubit),
  ];
}

class _LandingPage extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLaunchApp;
  final VoidCallback onLaunchGitHub;
  final String videoUrl;

  const _LandingPage({
    required this.isLoading,
    required this.onLaunchApp,
    required this.onLaunchGitHub,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'edu_app',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: _LandingContent(
                onLaunchApp: onLaunchApp,
                onLaunchGitHub: onLaunchGitHub,
                videoUrl: videoUrl,
              ),
            ),
            if (isLoading) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _LandingContent extends StatelessWidget {
  final VoidCallback onLaunchApp;
  final VoidCallback onLaunchGitHub;
  final String videoUrl;

  const _LandingContent({
    required this.onLaunchApp,
    required this.onLaunchGitHub,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Header(),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideLayout = constraints.maxWidth > 768;

                    if (isWideLayout) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _VideoPlayerContainer(videoUrl: videoUrl),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                            ),
                            child: Container(
                              height: 240,
                              width: 1,
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: _ActionButtons(
                              onLaunchApp: onLaunchApp,
                              onLaunchGitHub: onLaunchGitHub,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _VideoPlayerContainer(videoUrl: videoUrl),
                          const SizedBox(height: 40),
                          _ActionButtons(
                            onLaunchApp: onLaunchApp,
                            onLaunchGitHub: onLaunchGitHub,
                            isVertical: true,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onLaunchApp;
  final VoidCallback onLaunchGitHub;
  final bool isVertical;

  const _ActionButtons({
    required this.onLaunchApp,
    required this.onLaunchGitHub,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      _AppButton(onPressed: onLaunchApp),
      SizedBox(height: 20, width: 16),
      _GitHubButton(onPressed: onLaunchGitHub),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _VideoPlayerContainer extends StatelessWidget {
  final String videoUrl;

  const _VideoPlayerContainer({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: AppVideoPlayer(
          videoUrl: videoUrl,
          autoPlay: false,
          showControls: true,
          looping: false,
          onError: (error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $error')));
          },
        ),
      ),
    );
  }
}

class _AppButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AppButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size(200, 60),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 3,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 24),
            const SizedBox(width: 12),
            Text(
              'Launch Edu App',
              style: AppTextTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
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

  const _GitHubButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        minimumSize: const Size(200, 60),
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.code, size: 24),
          const SizedBox(width: 12),
          Text(
            'Source Code',
            style: AppTextTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: Text(
            'AIVIL',
            style: AppTextTheme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              fontSize: 72,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The Team',
          style: AppTextTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Launching Edu App...',
              style: AppTextTheme.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
