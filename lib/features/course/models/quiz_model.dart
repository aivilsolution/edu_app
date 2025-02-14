part of 'course_model.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int duration;
  final int totalPoints;
  final bool isCompleted;
  final double? score;
  final QuizType type;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.totalPoints,
    this.isCompleted = false,
    this.score,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'duration': duration,
      'totalPoints': totalPoints,
      'isCompleted': isCompleted,
      'score': score,
      'type': type.toString(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      totalPoints: map['totalPoints'],
      isCompleted: map['isCompleted'],
      score: map['score'],
      type: QuizType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
    );
  }
}

enum QuizType { online, inPerson, takehome }
