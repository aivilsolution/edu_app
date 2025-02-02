import 'package:edu_app/features/course/models/course_model.dart';
import 'package:flutter/material.dart';

class QuizWidget extends StatelessWidget {
  final List<Quiz> quizzes;

  const QuizWidget({super.key, required this.quizzes});

  @override
  Widget build(BuildContext context) {
    final latestCompletedQuiz = quizzes
        .where((q) => q.isCompleted)
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz),
                const SizedBox(width: 12),
                Text(
                  'Latest Quiz Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuizStat(
                  context,
                  'Score',
                  '${latestCompletedQuiz.score}/${latestCompletedQuiz.totalPoints}',
                  Icons.stars,
                ),
                _buildQuizStat(
                  context,
                  'Duration',
                  '${latestCompletedQuiz.duration}m',
                  Icons.timer,
                ),
                _buildQuizStat(
                  context,
                  'Type',
                  latestCompletedQuiz.type.toString().split('.').last,
                  Icons.category,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStat(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
