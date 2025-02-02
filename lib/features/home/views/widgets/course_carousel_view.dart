import 'package:edu_app/features/course/models/sample_data.dart';
import 'package:edu_app/features/course/views/screens/course_page.dart';
import 'package:edu_app/shared/widgets/carousel_widget.dart';
import 'package:edu_app/shared/widgets/course_card.dart';
import 'package:flutter/material.dart';

class CourseCarouselView extends StatelessWidget {
  const CourseCarouselView({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselWidget(
      items: List.generate(
        courses.length,
        (index) => CourseCard(
          name: courses[index].name,
          fontSize: 22,
        ),
      ),
      onTap: (index) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CoursePage(course: courses[index]),
          ),
        );
      },
    );
  }
}
