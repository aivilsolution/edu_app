import 'package:edu_app/features/course/models/course_model.dart';
import 'package:flutter/material.dart';

class AIRecommendations extends StatelessWidget {
  final Quiz latestQuiz;
  final Course course;

  const AIRecommendations({
    super.key,
    required this.latestQuiz,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RecommendationHeader(),
            const SizedBox(height: 24),
            const PracticeQuestionsSection(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            const ReviewMaterialsSection(),
          ],
        ),
      ),
    );
  }
}

class RecommendationHeader extends StatelessWidget {
  const RecommendationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.psychology, color: theme.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          'Recommended Practice',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PracticeQuestionsSection extends StatelessWidget {
  const PracticeQuestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.quiz,
          title: 'Practice Questions',
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => PracticeQuestionCard(
            questionNumber: index + 1,
            topic: QuestionTopic.values[index],
          ),
        ),
      ],
    );
  }
}

class ReviewMaterialsSection extends StatelessWidget {
  const ReviewMaterialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.menu_book,
          title: 'Review Materials',
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => ReviewMaterialCard(
            content: ReviewContent.values[index],
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class PracticeQuestionCard extends StatelessWidget {
  final int questionNumber;
  final QuestionTopic topic;

  const PracticeQuestionCard({
    super.key,
    required this.questionNumber,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Text(
                questionNumber.toString(),
                style: TextStyle(
                  color: theme.primaryColor,
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
                    'Similar to Question ${topic.questionId}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chapter ${topic.chapterId} - ${topic.name}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () => topic.onSolve?.call(),
              child: const Text('Solve'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewMaterialCard extends StatelessWidget {
  final ReviewContent content;

  const ReviewMaterialCard({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: content.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(content.icon, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
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
                Icons.arrow_forward,
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum QuestionTopic {
  dataStructures(
    name: 'Data Structures',
    chapterId: 1,
    questionId: 101,
  ),
  algorithms(
    name: 'Algorithms',
    chapterId: 2,
    questionId: 102,
  ),
  problemSolving(
    name: 'Problem Solving',
    chapterId: 3,
    questionId: 103,
  );

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
  sorting(
    title: 'Advanced Sorting Techniques',
    icon: Icons.sort,
    duration: 20,
  ),
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
