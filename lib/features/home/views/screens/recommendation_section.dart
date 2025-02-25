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
        ...QuestionTopic.values.map((topic) => TopicCard(topic)),
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
        ...ReviewContent.values.map((content) => MaterialCard(content)),
      ],
    );
  }
}

class TopicCard extends StatelessWidget {
  final QuestionTopic topic;

  const TopicCard(this.topic, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: topic.onSolve,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColorLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  topic.chapterId.toString(),
                  style: TextStyle(
                    color: theme.primaryColorLight,
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
                color: theme.primaryColorLight,
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

  const MaterialCard(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: content.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColorLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(content.icon, color: theme.primaryColorLight),
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
                color: theme.primaryColorLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum QuestionTopic {
  dataStructures(name: 'Data Structures', chapterId: 1, questionId: 101),
  algorithms(name: 'Algorithms', chapterId: 2, questionId: 102),
  problemSolving(name: 'Problem Solving', chapterId: 3, questionId: 103);

  final String name;
  final int chapterId;
  final int questionId;
  final VoidCallback? onSolve;

  const QuestionTopic({
    required this.name,
    required this.chapterId,
    required this.questionId,
    this.onSolve,
  });
}

enum ReviewContent {
  binaryTrees(
    title: 'Understanding Binary Trees',
    icon: Icons.account_tree,
    duration: 15,
  ),
  sorting(title: 'Advanced Sorting Techniques', icon: Icons.sort, duration: 20),
  optimization(
    title: 'Optimization Strategies',
    icon: Icons.speed,
    duration: 10,
  );

  final String title;
  final IconData icon;
  final int duration;
  final VoidCallback? onTap;

  const ReviewContent({
    required this.title,
    required this.icon,
    required this.duration,
    this.onTap,
  });
}
