import 'package:flutter/material.dart';
import '/features/home/views/screens/course_grid_view.dart';
import '/features/home/views/screens/notification_page.dart';
import '/features/home/views/screens/recommendation_section.dart';
import '/features/home/views/widgets/course_carousel_view.dart';
import '/shared/widgets/section_header.dart';
import '/features/profile/views/screens/profile_page.dart';

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
            tooltip: 'Notifications',
            onPressed: () => _navigate(context, const NotificationsPage()),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            tooltip: 'Profile',
            onPressed: () => _navigate(context, const ProfilePage()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          SectionHeader(
            title: 'My Courses',
            onAction: () => _navigate(context, const CoursesGridView()),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 240, child: CourseCarouselView()),
          const SizedBox(height: 32),
          Text(
            'Recommendations',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const RecommendationSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
