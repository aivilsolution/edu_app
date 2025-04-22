import 'package:edu_app/features/recommendation/views/screens/recommendation_screen.dart';
import 'package:edu_app/shared/widgets/carousel_widget.dart';
import 'package:flutter/material.dart';

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  static const double _horizontalPadding = 16.0;
  static const double _sectionSpacing = 24.0;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        RecommendedCoursesCarousel(),
        SectionHeader(title: 'Practice Questions', showAction: true),
        PracticeSection(),
        SectionHeader(title: 'Learning Resources', showAction: true),
        LearningResourcesSection(),
        SizedBox(height: _sectionSpacing),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.showAction = false,
  });

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: _padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showAction)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }
}

class RecommendedCoursesCarousel extends StatelessWidget {
  const RecommendedCoursesCarousel({super.key});

  static const double _carouselHeight = 150.0;
  static const double _cardSpacing = 16.0;

  @override
  Widget build(BuildContext context) {
    final courses = MockDataService.getRecommendedCourses();
    final List<Widget> courseCards =
        courses
            .map(
              (course) => Padding(
                padding: const EdgeInsets.only(right: _cardSpacing),
                child: CourseCard(course: course),
              ),
            )
            .toList();

    if (courseCards.isNotEmpty) {
      final lastIndex = courseCards.length - 1;
      final lastCard = courseCards[lastIndex] as Padding;
      courseCards[lastIndex] = Padding(
        padding: EdgeInsets.zero,
        child: lastCard.child,
      );
    }

    return SizedBox(
      height: _carouselHeight,
      child: CarouselWidget(
        height: _carouselHeight,
        items: courseCards,
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      RecommendationScreen(title: courses[index].title),
            ),
          );
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  static const double _cardWidth = 300.0;
  static const EdgeInsets _contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _footerPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);
  static const double _borderRadius = 16.0;
  static const double _progressIndicatorHeight = 8.0;
  static const double _progressIndicatorRadius = 8.0;
  static const double _progressTextSpacing = 8.0;
  static const int _maxTitleLines = 2;
  static const double _titleHeight = 1.2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: _cardWidth,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: course.onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: _contentPadding,
                child: Text(
                  course.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: _titleHeight,
                  ),
                  maxLines: _maxTitleLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: _footerPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: course.progress,
                      borderRadius: BorderRadius.circular(
                        _progressIndicatorRadius,
                      ),
                      minHeight: _progressIndicatorHeight,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: _progressTextSpacing),
                    Text(
                      course.progress > 0
                          ? '${(course.progress * 100).toInt()}% Completed'
                          : 'Start Learning',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
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

class PracticeSection extends StatelessWidget {
  const PracticeSection({super.key});

  static const double _horizontalPadding = 16.0;
  static const double _itemSpacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final topics = MockDataService.getPracticeTopics();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        children: [
          for (final topic in topics)
            Padding(
              padding: EdgeInsets.only(
                bottom: topics.last != topic ? _itemSpacing : 0,
              ),
              child: PracticeTopicCard(topic: topic),
            ),
        ],
      ),
    );
  }
}

class PracticeTopicCard extends StatelessWidget {
  final PracticeTopic topic;

  const PracticeTopicCard({super.key, required this.topic});

  static const EdgeInsets _cardMargin = EdgeInsets.only(bottom: 12.0);
  static const double _borderRadius = 12.0;
  static const EdgeInsets _cardPadding = EdgeInsets.all(16.0);
  static const double _indicatorSize = 40.0;
  static const double _indicatorRadius = 8.0;
  static const double _contentSpacing = 16.0;
  static const double _titleSpacing = 4.0;
  static const double _chipSpacing = 8.0;
  static const double _chipFontSize = 10.0;
  static const FontWeight _chipFontWeight = FontWeight.w700;
  static const double _chipPaddingHorizontal = 8.0;
  static const double _chipPaddingVertical = 2.0;
  static const double _progressIndicatorStrokeWidth = 4.0;
  static const double _progressTextFontSize = 10.0;
  static const FontWeight _progressTextFontWeight = FontWeight.w700;
  static const double _arrowIconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: _cardMargin,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_borderRadius),
        onTap: topic.onPressed,
        child: Padding(
          padding: _cardPadding,
          child: Row(
            children: [
              SizedBox(width: _contentSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: _titleSpacing),
                    Wrap(
                      spacing: _chipSpacing,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${topic.questionCount} problems',
                          style: theme.textTheme.bodySmall,
                        ),
                        Chip(
                          label: Text(topic.difficulty.label),
                          labelStyle: const TextStyle(
                            fontSize: _chipFontSize,
                            fontWeight: _chipFontWeight,
                          ),
                          backgroundColor: topic.difficulty.color.withOpacity(
                            0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              _indicatorRadius,
                            ),
                          ),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                            horizontal: _chipPaddingHorizontal,
                            vertical: _chipPaddingVertical,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildProgressIndicator(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return topic.progress > 0
        ? SizedBox(
          width: _indicatorSize,
          height: _indicatorSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: topic.progress,
                strokeWidth: _progressIndicatorStrokeWidth,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
              Text(
                '${(topic.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: _progressTextFontSize,
                  fontWeight: _progressTextFontWeight,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        )
        : Icon(
          Icons.arrow_forward_ios_rounded,
          size: _arrowIconSize,
          color: colorScheme.onSurface.withOpacity(0.6),
        );
  }
}

class LearningResourcesSection extends StatelessWidget {
  const LearningResourcesSection({super.key});

  static const double _horizontalPadding = 16.0;
  static const double _mainAxisSpacing = 12.0;
  static const double _crossAxisSpacing = 12.0;
  static const int _crossAxisCount = 2;
  static const double _childAspectRatio = 0.9;

  @override
  Widget build(BuildContext context) {
    final resources = MockDataService.getLearningResources();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          mainAxisSpacing: _mainAxisSpacing,
          crossAxisSpacing: _crossAxisSpacing,
          childAspectRatio: _childAspectRatio,
        ),
        itemCount: resources.length,
        itemBuilder:
            (context, index) =>
                LearningResourceCard(resource: resources[index]),
      ),
    );
  }
}

class LearningResourceCard extends StatelessWidget {
  final LearningResource resource;

  const LearningResourceCard({super.key, required this.resource});

  static const double _borderRadius = 12.0;
  static const EdgeInsets _cardPadding = EdgeInsets.all(12.0);
  static const double _iconContainerHeight = 80.0;
  static const double _iconSize = 32.0;
  static const double _titleSpacing = 12.0;
  static const int _maxTitleLines = 2;
  static const double _durationIconSize = 14.0;
  static const double _durationSpacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_borderRadius),
        onTap: resource.onPressed,
        child: Padding(
          padding: _cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: _iconContainerHeight,
                decoration: BoxDecoration(
                  color: resource.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_borderRadius / 1.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  resource.icon,
                  size: _iconSize,
                  color: resource.color,
                ),
              ),
              const SizedBox(height: _titleSpacing),
              Expanded(
                child: Text(
                  resource.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: _maxTitleLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: _durationIconSize,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: _durationSpacing),
                  Text(
                    '${resource.duration} mins',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Course {
  final String title;
  final String category;
  final String instructor;
  final String imageUrl;
  final String duration;
  final double rating;
  final double progress;
  final bool isBookmarked;
  final VoidCallback onPressed;

  const Course({
    required this.title,
    required this.category,
    required this.instructor,
    required this.imageUrl,
    required this.duration,
    this.rating = 4.5,
    this.progress = 0.0,
    this.isBookmarked = false,
    required this.onPressed,
  });
}

class PracticeTopic {
  final String title;
  final int chapter;
  final int questionCount;
  final Difficulty difficulty;
  final Color color;
  final double progress;
  final VoidCallback onPressed;

  const PracticeTopic({
    required this.title,
    required this.chapter,
    required this.questionCount,
    required this.difficulty,
    required this.color,
    this.progress = 0.0,
    required this.onPressed,
  });
}

class LearningResource {
  final String title;
  final IconData icon;
  final int duration;
  final Color color;
  final bool isNew;
  final VoidCallback onPressed;

  const LearningResource({
    required this.title,
    required this.icon,
    required this.duration,
    required this.color,
    this.isNew = false,
    required this.onPressed,
  });
}

enum Difficulty {
  easy('Easy', Colors.green),
  medium('Medium', Colors.orange),
  hard('Hard', Colors.red);

  final String label;
  final Color color;

  const Difficulty(this.label, this.color);
}

class MockDataService {
  static List<Course> getRecommendedCourses() => [
    Course(
      title: 'Advanced Data Structures & Algorithms',
      category: 'Computer Science',
      instructor: 'Dr. Jane Smith',
      imageUrl: 'assets/courses/dsa.jpg',
      duration: '6 Weeks',
      rating: 4.8,
      progress: 0.65,
      isBookmarked: true,
      onPressed: () {},
    ),
    Course(
      title: 'Dijkstra\'s Algorithm',
      category: 'Algorithm',
      instructor: 'Prof. Andrew Ng',
      imageUrl: 'assets/courses/ml.jpg',
      duration: '8 Weeks',
      rating: 4.9,
      progress: 0.2,
      onPressed: () {},
    ),
    Course(
      title: 'Modern App Development with Flutter',
      category: 'Mobile',
      instructor: 'Google Team',
      imageUrl: 'assets/courses/flutter.jpg',
      duration: '4 Weeks',
      rating: 4.7,
      onPressed: () {},
    ),
  ];

  static List<PracticeTopic> getPracticeTopics() => [
    PracticeTopic(
      title: 'Array Manipulation',
      chapter: 1,
      questionCount: 15,
      difficulty: Difficulty.medium,
      color: Colors.blue,
      progress: 0.75,
      onPressed: () {},
    ),
    PracticeTopic(
      title: 'Dynamic Programming',
      chapter: 4,
      questionCount: 20,
      difficulty: Difficulty.hard,
      color: Colors.purple,
      progress: 0.3,
      onPressed: () {},
    ),
    PracticeTopic(
      title: 'Graph Algorithms',
      chapter: 5,
      questionCount: 12,
      difficulty: Difficulty.hard,
      color: Colors.teal,
      onPressed: () {},
    ),
  ];

  static List<LearningResource> getLearningResources() => [
    LearningResource(
      title: 'Binary Search Masterclass',
      icon: Icons.search,
      duration: 15,
      color: Colors.indigo,
      isNew: true,
      onPressed: () {},
    ),
    LearningResource(
      title: 'System Design Patterns',
      icon: Icons.design_services,
      duration: 25,
      color: Colors.orange,
      onPressed: () {},
    ),
    LearningResource(
      title: 'Clean Code Principles',
      icon: Icons.code,
      duration: 20,
      color: Colors.green,
      isNew: true,
      onPressed: () {},
    ),
    LearningResource(
      title: 'Database Optimization',
      icon: Icons.storage,
      duration: 18,
      color: Colors.blue,
      onPressed: () {},
    ),
  ];
}
