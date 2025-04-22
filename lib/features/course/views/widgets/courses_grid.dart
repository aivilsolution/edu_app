import 'package:edu_app/features/course/models/course.dart';
import 'package:edu_app/features/course/views/widgets/course_card.dart';
import 'package:edu_app/shared/widgets/custom_app_bar.dart';
import '/features/course/views/screens/course_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/features/course/cubit/course_cubit.dart';
import '/features/course/cubit/course_state.dart';

class CoursesGrid extends StatefulWidget {
  final int crossAxisCount;
  final double spacing;

  const CoursesGrid({super.key, this.crossAxisCount = 2, this.spacing = 16.0});

  @override
  State createState() => _CoursesGridState();
}

class _CoursesGridState extends State<CoursesGrid> {
  @override
  void initState() {
    super.initState();
    context.read<CourseCubit>().fetchAllCourses();
  }

  Widget _buildGridView(List<Course> courses) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Courses"),
      body: GridView.builder(
        padding: EdgeInsets.all(widget.spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: widget.spacing,
          mainAxisSpacing: widget.spacing,
          childAspectRatio: 1,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => CoursePage(courseId: courses[index].id),
                  ),
                ),
            child: CourseCard(name: courses[index].name, index: index),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CourseError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is CourseLoaded) {
          return _buildGridView(state.courses);
        } else {
          return const Center(child: Text('No courses available.'));
        }
      },
    );
  }
}
