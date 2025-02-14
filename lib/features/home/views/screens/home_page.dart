import 'package:edu_app/shared/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:edu_app/features/communication/views/pages/chat_page.dart';
import 'package:edu_app/shared/widgets/custom_nav_bar.dart';
import 'package:edu_app/features/ai/views/pages/ai_page.dart';
import 'package:edu_app/features/calendar/views/pages/calendar_page.dart';
import 'package:edu_app/features/profile/views/pages/profile_page.dart';
import 'package:edu_app/features/home/views/screens/notification_page.dart';
import 'package:edu_app/features/home/views/screens/course_grid_view.dart';
import 'package:edu_app/features/home/views/widgets/course_carousel_view.dart';
import 'package:edu_app/old/widgets/task_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(),
    CalendarPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AiPage(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const SearchWidget(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Courses',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoursesGridView()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 250,
            child: CourseCarouselView(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tasks', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                const TasksList(
                  avatar:
                      "https://www.pngplay.com/wp-content/uploads/12/User-Avatar-Profile-PNG-Pic-Clip-Art-Background.png",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
