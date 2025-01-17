import 'package:edu_app/course_card.dart';
import 'package:edu_app/tasks.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'https://as2.ftcdn.net/jpg/04/07/37/73/1000_F_407377396_PQvbEFg8g58qQ7FWzwaSNpJUkq2yUsqk.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUC6HnJ2Awh0Boa8SjWhl7NS7XUMXSXtvKnw&s',
      'https://static.vecteezy.com/system/resources/thumbnails/007/227/554/small/mathematics-word-concepts-banner-presentation-website-isolated-lettering-typography-idea-with-linear-icons-algebra-geometry-statistics-basic-maths-outline-illustration-vector.jpg'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Educational app",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Courses",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CourseCard(
              images: images,
            ),
            SizedBox(height: 40),
            Tasks(),
          ],
        ),
      ),
    );
  }
}
