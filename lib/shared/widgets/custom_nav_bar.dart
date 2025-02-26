import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) ;

  static const double _iconPadding = 8.0;

  // Helper function to create an icon with consistent padding.
  static Widget _buildPaddedIcon(IconData iconData) {
    return Padding(
      padding: const EdgeInsets.all(_iconPadding),
      child: Icon(iconData),
    );
  }

  // Define your navigation destinations in one place.
  static List<NavigationDestination> get _destinations => [
    NavigationDestination(
      icon: _buildPaddedIcon(Icons.home_outlined),
      selectedIcon: _buildPaddedIcon(Icons.home_rounded),
      label: '',
    ),
    NavigationDestination(
      icon: _buildPaddedIcon(Icons.calendar_month_outlined),
      selectedIcon: _buildPaddedIcon(Icons.calendar_month_rounded),
      label: '',
    ),
    NavigationDestination(
      icon: _buildPaddedIcon(Icons.smart_toy_outlined),
      selectedIcon: _buildPaddedIcon(Icons.smart_toy_rounded),
      label: '',
    ),
    NavigationDestination(
      icon: _buildPaddedIcon(Icons.person_outline_rounded),
      selectedIcon: _buildPaddedIcon(Icons.person_rounded),
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
      indicatorShape: const CircleBorder(),
      destinations: _destinations,
    );
  }
}
