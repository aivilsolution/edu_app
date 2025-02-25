import 'package:flutter/material.dart';

import 'package:edu_app/features/ai/views/screens/ai_page.dart';
import 'package:edu_app/features/calendar/views/screens/calendar_page.dart';
import 'package:edu_app/features/profile/views/screens/profile_page.dart';
import 'package:edu_app/features/home/views/screens/home_content.dart';
import 'package:edu_app/shared/widgets/custom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    CalendarPage(),
    AiPage(),
    ProfilePage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
