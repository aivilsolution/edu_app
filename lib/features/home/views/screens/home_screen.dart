import 'package:flutter/material.dart';

import '/features/home/views/screens/course_grid_view.dart';
import '/features/home/views/screens/notification_page.dart';
import '/features/home/views/screens/recommendation_section.dart';
import '/features/home/views/widgets/course_carousel_view.dart';
import '/features/communication/views/screens/chat_page.dart';
import '/shared/widgets/search_widget.dart';
import '/shared/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _navigate(context, const NotificationsPage()),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => _navigate(context, const ChatPage()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const SearchWidget(),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'My Courses',
              onAction: () => _navigate(context, const CoursesGridView()),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 250, child: CourseCarouselView()),
            const SizedBox(height: 24),
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const RecommendationSection(),
          ],
        ),
      ),
    );
  }
}
