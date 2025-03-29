import 'package:edu_app/features/course/models/course_data.dart';
import 'package:flutter/material.dart';

class QuizWidget extends StatelessWidget {
  final List<Quiz> quizzes;

  const QuizWidget({super.key, this.quizzes = const []});

  @override
  Widget build(BuildContext context) {
    
    if (quizzes.isEmpty) {
      return const Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No quizzes available yet.', textAlign: TextAlign.center),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Quizzes',
                  style: Theme.of(context).textTheme.titleLarge,
                ), 
              ],
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizzes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return ListTile(
                  title: Text(quiz.title),
                  leading: Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                  subtitle: Text(
                    'Duration: ${quiz.duration} minutes, Questions: ${quiz.totalQuestions}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ), 
                  
                  
                  
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
