import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/course_state.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/views/widgets/modules_widget.dart';
import 'package:edu_app/features/course/views/widgets/professor_widget.dart';
import 'package:edu_app/features/course/views/widgets/quiz_widget.dart';
import 'package:edu_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/course_data.dart';

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
    context.read<CourseCubit>().fetchCourseById(widget.courseId);
  }

  @override
  void didUpdateWidget(CoursePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      context.read<CourseCubit>().fetchCourseById(widget.courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Course Details'),
      body: BlocConsumer<CourseCubit, CourseState>(
        listener: (context, state) {
          if (state is CourseDetailLoaded) {
            context.read<ProfessorCubit>().fetchProfessorById(
              state.course.professorId,
            );
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is CourseDetailLoaded) {
            final course = state.course;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  course.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  course.code,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ProfessorWidget(professorId: course.professorId),
                const SizedBox(height: 24),
                QuizWidget(quizzes: const []),
                const SizedBox(height: 24),
                ModulesWidget(courseData: const CourseData()),
              ],
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
