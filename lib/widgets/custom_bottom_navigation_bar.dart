import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 28,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded), label: ''),
      ],
    );
  }
}
