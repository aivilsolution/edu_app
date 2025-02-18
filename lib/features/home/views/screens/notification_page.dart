import 'package:edu_app/shared/widgets/search_widget.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const double _padding = 16;
  static const double _spacing = 20;
  static const double _cardSpacing = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          children: [
            const _NotificationTabs(),
            const SizedBox(height: _spacing),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: _cardSpacing),
                itemBuilder: (context, index) => _DetailedNotificationCard(
                  notification: Notification(
                    title: 'Important Course Update ${index + 1}',
                    description:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    time: '${index + 1}h ago',
                    icon: Icons.notification_important,
                    isRead: index > 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTabs extends StatefulWidget {
  const _NotificationTabs();

  @override
  State<_NotificationTabs> createState() => _NotificationTabsState();
}

class _NotificationTabsState extends State<_NotificationTabs> {
  int _selectedIndex = 0;
  static const List<String> _tabs = ['All', 'Unread'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildTab(index, context),
      ),
    );
  }

  Widget _buildTab(int index, BuildContext context) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Card(
        color: isSelected ? Theme.of(context).primaryColor : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              _tabs[index],
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailedNotificationCard extends StatelessWidget {
  const _DetailedNotificationCard({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(notification.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                notification.time,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark as read'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Notification {
  const Notification({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    this.isRead = false,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
  final bool isRead;
}
