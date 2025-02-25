import 'package:flutter/material.dart';

import 'package:edu_app/features/home/views/screens/course_grid_view.dart';
import 'package:edu_app/features/home/views/screens/notification_page.dart';
import 'package:edu_app/features/home/views/screens/recommendation_section.dart';
import 'package:edu_app/features/home/views/widgets/course_carousel_view.dart';
import 'package:edu_app/features/communication/views/screens/chat_page.dart';
import 'package:edu_app/shared/widgets/search_widget.dart';
import 'package:edu_app/shared/widgets/section_header.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Educational App'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _navigateToNotifications(context),
        ),
        IconButton(
          icon: const Icon(Icons.chat_outlined),
          onPressed: () => _navigateToChat(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          const SearchWidget(),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'My Courses',
            onAction: () => _navigateToAllCourses(context),
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
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
  }

  void _navigateToAllCourses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CoursesGridView()),
    );
  }
}
