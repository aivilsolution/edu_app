import 'package:equatable/equatable.dart';

part 'professor_model.dart';
part 'assignment_model.dart';
part 'lab_model.dart';
part 'quiz_model.dart';
part 'analytics_model.dart';

class Course extends Equatable {
  final String code;
  final String name;
  final String syllabus;
  final Professor professor;
  final List<Quiz> quizzes;
  // final List<Analytics> analytics;
  final List<Assignment> assignments;
  final List<Lab> labs;

  const Course({
    required this.code,
    required this.name,
    required this.syllabus,
    required this.professor,
    this.quizzes = const [],
    // this.analytics = const [],
    this.assignments = const [],
    this.labs = const [],
  });

  Course copyWith({
    String? code,
    String? name,
    String? syllabus,
    Professor? professor,
    List<Quiz>? quizzes,
    List<Analytics>? analytics,
    List<Assignment>? assignments,
    List<Lab>? labs,
  }) {
    return Course(
      code: code ?? this.code,
      name: name ?? this.name,
      syllabus: syllabus ?? this.syllabus,
      professor: professor ?? this.professor,
      quizzes: quizzes ?? this.quizzes,
      // analytics: analytics ?? this.analytics,
      assignments: assignments ?? this.assignments,
      labs: labs ?? this.labs,
    );
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'name': name,
        'syllabus': syllabus,
        'professor': professor.toMap(),
        'quizzes': quizzes.map((q) => q.toMap()).toList(),
        // 'analytics': analytics.map((x) => x.toMap()).toList(),
        'assignments': assignments.map((a) => a.toMap()).toList(),
        'labs': labs.map((l) => l.toMap()).toList(),
      };

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      code: map['code'],
      name: map['name'],
      syllabus: map['syllabus'],
      professor: Professor.fromMap(map['professor']),
      quizzes: (map['quizzes'] as List<dynamic>? ?? [])
          .map((x) => Quiz.fromMap(x))
          .toList(),
      // analytics: (map['analytics'] as List<dynamic>? ?? [])
      //     .map((x) => Analytics.fromMap(x))
      //     .toList(),
      assignments: (map['assignments'] as List<dynamic>? ?? [])
          .map((x) => Assignment.fromMap(x))
          .toList(),
      labs: (map['labs'] as List<dynamic>? ?? [])
          .map((x) => Lab.fromMap(x))
          .toList(),
    );
  }

  @override
  List<Object> get props => [
        code,
        name,
        syllabus,
        professor,
        quizzes,
        // analytics,
        assignments,
        labs,
      ];
}
