import 'package:edu_app/widgets/custom_app_bar.dart';
import 'package:edu_app/widgets/courses_grid_view.dart';
import 'package:edu_app/widgets/custom_bottom_navigation_bar.dart';
import 'package:edu_app/widgets/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:edu_app/widgets/course_card.dart';
import 'package:edu_app/widgets/task_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String image =
      "https://t4.ftcdn.net/jpg/02/61/49/05/360_F_261490536_nJ5LSRAVZA0CK9Nvt2E1fXJVUfpiqvhT.jpg";
  final String avatar =
      "https://www.pngplay.com/wp-content/uploads/12/User-Avatar-Profile-PNG-Pic-Clip-Art-Background.png";

  List<String> get images => List.filled(7, image);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(actions: [
        IconButton(
          icon: Icon(Icons.chat_outlined),
          onPressed: null,
        ),
      ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SearchTextField(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 18, right: 18, left: 18),
                        child: Row(
                          children: [
                            const Text(
                              "My Courses",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              iconSize: 20,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CoursesGridView(images: images),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CourseCard(images: images),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Text(
                      "Tasks",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TasksList(avatar: avatar),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
