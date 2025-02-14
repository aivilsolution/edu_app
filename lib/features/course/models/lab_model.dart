part of 'course_model.dart';

class Lab {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int duration;
  final bool isAttended;
  final double? score;
  final String location;

  Lab({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    this.isAttended = false,
    this.score,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'duration': duration,
      'isAttended': isAttended,
      'score': score,
      'location': location,
    };
  }

  factory Lab.fromMap(Map<String, dynamic> map) {
    return Lab(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      isAttended: map['isAttended'],
      score: map['score'],
      location: map['location'],
    );
  }
}
