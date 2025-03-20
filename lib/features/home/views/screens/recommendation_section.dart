import 'package:flutter/material.dart';

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 24),
        PracticeSection(),
        SizedBox(height: 24),
        LearningMaterialsSection(),
      ],
    );
  }
}

class PracticeSection extends StatelessWidget {
  const PracticeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Practice Questions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...QuestionTopic.values.map((topic) => TopicCard(topic: topic)),
      ],
    );
  }
}

class LearningMaterialsSection extends StatelessWidget {
  const LearningMaterialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Learning Materials',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...ReviewContent.values.map(
          (content) => MaterialCard(content: content),
        ),
      ],
    );
  }
}

class TopicCard extends StatelessWidget {
  final QuestionTopic topic;

  const TopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => topic.onSolve(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  topic.chapterId.toString(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('5 questions', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MaterialCard extends StatelessWidget {
  final ReviewContent content;

  const MaterialCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => content.onTap(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(content.icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${content.duration} min read',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


enum QuestionTopic {
  dataStructures('Data Structures', 1, 101),
  algorithms('Algorithms', 2, 102),
  problemSolving('Problem Solving', 3, 103);

  final String name;
  final int chapterId;
  final int questionId;

  const QuestionTopic(this.name, this.chapterId, this.questionId);

  void onSolve() {
    
    debugPrint('Solving $name...');
  }
}

enum ReviewContent {
  binaryTrees('Understanding Binary Trees', Icons.account_tree, 15),
  sorting('Advanced Sorting Techniques', Icons.sort, 20),
  optimization('Optimization Strategies', Icons.speed, 10);

  final String title;
  final IconData icon;
  final int duration;

  const ReviewContent(this.title, this.icon, this.duration);

  void onTap() {
    
    debugPrint('Opening $title...');
  }
}
