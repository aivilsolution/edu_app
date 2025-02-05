import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static List<NavigationDestination> get _destinations => [
        NavigationDestination(
          icon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.home_outlined),
          ),
          selectedIcon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.home_rounded),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.calendar_month_outlined),
          ),
          selectedIcon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.calendar_month_rounded),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.smart_toy_outlined),
          ),
          selectedIcon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.smart_toy_rounded),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.person_outline_rounded),
          ),
          selectedIcon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.person_rounded),
          ),
          label: '',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      backgroundColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      indicatorShape: CircleBorder(),
      destinations: _destinations,
    );
  }
}
