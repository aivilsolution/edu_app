import 'package:flutter/material.dart';

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  // Modern black theme colors
  static const _colors = {
    'background': Color(0xFF000000),
    'surface': Color(0xFF121212),
    'primary': Color(0xFF2D2D2D),
    'secondary': Color(0xFF404040),
    'accent': Color(0xFFE0E0E0),
    'text': Colors.white,
    'textSecondary': Color(0xFF94A3B8),
    'border': Color(0xFF1E293B),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors['background'],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Physics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InstructorCard(),
          SizedBox(height: 24),
          _AnnouncementsSection(),
          SizedBox(height: 24),
          _LearningPathSection(),
          SizedBox(height: 24),
          _QuizSection(),
          SizedBox(height: 24),
          _FeaturesGrid(),
        ],
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CoursePage._colors['surface'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoursePage._colors['border']!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: CoursePage._colors['primary'],
            child:
                Icon(Icons.person_outline, color: CoursePage._colors['accent']),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prof. Sarah Johnson',
                style: TextStyle(
                  color: CoursePage._colors['text'],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Course Instructor',
                style: TextStyle(
                  color: CoursePage._colors['textSecondary'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CoursePage._colors['surface'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoursePage._colors['border']!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CoursePage._colors['primary'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: CoursePage._colors['accent'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quiz',
                    style: TextStyle(
                      color: CoursePage._colors['text'],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward,
                  color: CoursePage._colors['accent'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuizStat('Score', '1687', Icons.stars_outlined),
                _buildQuizStat('Rank', '2', Icons.leaderboard_outlined),
                _buildQuizStat(
                    'Streak', '12', Icons.local_fire_department_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStat(String label, String value, IconData icon) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CoursePage._colors['primary'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: CoursePage._colors['accent'],
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 24, // Fixed height for value
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: CoursePage._colors['text'],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 32, // Fixed height for label
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CoursePage._colors['textSecondary'],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsSection extends StatelessWidget {
  const _AnnouncementsSection();

  @override
  Widget build(BuildContext context) {
    final announcements = [
      Announcement(
        title: 'Virtual Lab Session',
        description: 'Virtual lab session scheduled for tomorrow at 2 PM.',
        time: 'Tomorrow, 2:00 PM',
        icon: Icons.computer_outlined,
      ),
      Announcement(
        title: 'Chapter 3 Quiz',
        description: 'Quiz will be available from Monday.',
        time: 'Monday, 10:00 AM',
        icon: Icons.quiz_outlined,
      ),
      Announcement(
        title: 'Group Discussion',
        description: 'Join the discussion on Newton\'s Laws.',
        time: 'Wed, 3:30 PM',
        icon: Icons.groups_outlined,
      ),
      Announcement(
        title: 'Course Materials Updated',
        description: 'New resources added for Chapter 3.',
        time: 'Fri, 9:00 AM',
        icon: Icons.book_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CoursePage._colors['text'],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: CoursePage._colors['accent'],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _AnnouncementCard(
            announcement: announcements[index],
          ),
        ),
      ],
    );
  }
}

class Announcement {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const Announcement({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CoursePage._colors['surface'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoursePage._colors['border']!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CoursePage._colors['primary'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              announcement.icon,
              color: CoursePage._colors['accent'],
              size: 20,
            ),
          ),
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
                        announcement.title,
                        style: TextStyle(
                          color: CoursePage._colors['text'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      announcement.time,
                      style: TextStyle(
                        color: CoursePage._colors['textSecondary'],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.description,
                  style: TextStyle(
                    color: CoursePage._colors['textSecondary'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CoursePage._colors['surface'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoursePage._colors['border']!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CoursePage._colors['primary'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: CoursePage._colors['accent'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recommendations',
                style: TextStyle(
                  color: CoursePage._colors['text'],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(
            'Focus Area',
            'Mechanics & Dynamics',
            'Based on your quiz performance, focusing on these topics will improve your overall score.',
            Icons.flag_rounded,
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            'Next Steps',
            'Practice Problems',
            'Complete the problem set in Chapter 3 to reinforce your understanding.',
            Icons.directions_walk,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    String label,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CoursePage._colors['primary'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: CoursePage._colors['accent'],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: CoursePage._colors['textSecondary'],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: CoursePage._colors['text'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: CoursePage._colors['textSecondary'],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      ('Resources', 'Study Materials', Icons.library_books_outlined),
      ('Analytics', 'Track Progress', Icons.analytics_outlined),
      ('Assignments', '2 Due Soon', Icons.assignment_outlined),
      ('Discussions', '12 New Topics', Icons.forum_outlined),
      ('Virtual Lab', 'Practice Mode', Icons.science_outlined),
      ('Syllabus', 'Course Overview', Icons.menu_book_outlined),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        mainAxisExtent: 120,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return _FeatureCard(
              title: features[index].$1,
              subtitle: features[index].$2,
              icon: features[index].$3,
              maxWidth: constraints.maxWidth,
            );
          },
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double maxWidth;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CoursePage._colors['surface'],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: CoursePage._colors['border']!),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CoursePage._colors['primary'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: CoursePage._colors['accent'],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: CoursePage._colors['text'],
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: CoursePage._colors['textSecondary'],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
