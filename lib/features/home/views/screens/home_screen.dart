import 'package:edu_app/features/course/views/widgets/courses_carousel.dart';
import 'package:edu_app/features/course/views/widgets/courses_grid.dart';
import 'package:flutter/material.dart';
import '/features/home/views/screens/notification_page.dart';
import '/features/home/views/screens/recommendation_section.dart';
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
        title: Text(
          'Edu App',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Courses',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_rounded),
                onPressed: () => _navigate(context, const CoursesGrid()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 200, child: CoursesCarousel()),
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
