part of 'course_model.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int totalPoints;
  final bool isSubmitted;
  final double? score;
  final List<String> attachments;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.totalPoints,
    this.isSubmitted = false,
    this.score,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'totalPoints': totalPoints,
      'isSubmitted': isSubmitted,
      'score': score,
      'attachments': attachments,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      totalPoints: map['totalPoints'],
      isSubmitted: map['isSubmitted'],
      score: map['score'],
      attachments: List<String>.from(map['attachments']),
    );
  }
}
