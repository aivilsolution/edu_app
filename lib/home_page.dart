import 'package:flutter/material.dart';
import 'package:edu_app/widgets/course_card.dart';
import 'package:edu_app/widgets/task.dart';
import 'package:edu_app/enums/task.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final image =
        "https://upload.wikimedia.org/wikipedia/commons/4/49/A_black_image.jpg";
    final avatar =
        "https://www.pngplay.com/wp-content/uploads/12/User-Avatar-Profile-PNG-Pic-Clip-Art-Background.png";
    final List<String> images = [
      image,
      image,
      image,
      image,
      image,
      image,
      image,
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
      body: SingleChildScrollView(
        child: Padding(
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
              Text(
                "Tasks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Task(
                        subject: TaskSubject.math,
                        priority: TaskPriority.high,
                        status: TaskStatus.todo,
                        title: 'The task',
                        description: 'Description',
                        dateTime: DateTime.now(),
                        assignorAvatarUrl: avatar,
                        assigneeAvatarUrls: [
                          avatar,
                          avatar,
                          avatar,
                          avatar,
                          avatar,
                          avatar,
                          avatar,
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
