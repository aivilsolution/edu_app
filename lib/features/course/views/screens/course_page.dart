import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/course_state.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/models/course.dart';
import 'package:edu_app/features/course/views/widgets/analytics_widget.dart';
import 'package:edu_app/features/course/views/widgets/modules_widget.dart';
import 'package:edu_app/features/course/views/widgets/professor_widget.dart';
import 'package:edu_app/features/course/views/widgets/quiz_widget.dart';
import 'package:edu_app/shared/widgets/error_view.dart';
import 'package:edu_app/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursePage extends StatefulWidget {
  final String courseId;

  const CoursePage({super.key, required this.courseId});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CourseCubit>().fetchCourseById(widget.courseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<CourseCubit, CourseState>(
        listener: (context, state) {
          if (state is CourseDetailLoaded) {
            context.read<ProfessorCubit>().fetchProfessorById(
              state.course.professorId,
            );
          }
        },
        child: BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const LoadingView(
                message: 'Loading course information...',
              );
            } else if (state is CourseError) {
              return ErrorView(
                message: state.message,
                onRetry:
                    () => context.read<CourseCubit>().fetchCourseById(
                      widget.courseId,
                    ),
              );
            } else if (state is CourseDetailLoaded) {
              return _CourseContent(course: state.course);
            } else {
              return const Center(child: Text('No course data available'));
            }
          },
        ),
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  final Course course;

  const _CourseContent({required this.course});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _CourseHeader(course: course),
          ProfessorWidget(professorId: course.professorId),
          const QuizWidget(quizzesCompleted: 17, averageScore: 93.5, rank: 4),
          AnalyticsWidget(),
          const ModulesWidget(),
        ],
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  final Course course;

  const _CourseHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(course.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        _CourseCodeBadge(code: course.code),
      ],
    );
  }
}

class _CourseCodeBadge extends StatelessWidget {
  final String code;

  const _CourseCodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
