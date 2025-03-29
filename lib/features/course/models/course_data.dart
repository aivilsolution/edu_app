
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CourseData extends Equatable {
  final List<Syllabus> syllabus;
  final List<Document> documents;
  final List<Assignment> assignments;
  final List<Quiz> quizzes;
  final List<Lab> labs;

  const CourseData({
    List<Syllabus>? syllabus,
    List<Document>? documents,
    List<Assignment>? assignments,
    List<Quiz>? quizzes,
    List<Lab>? labs,
  }) : syllabus = syllabus ?? const [],
       documents = documents ?? const [],
       assignments = assignments ?? const [],
       quizzes = quizzes ?? const [],
       labs = labs ?? const [];

  factory CourseData.fromFirestore(Map<String, dynamic> data) {
    return CourseData.fromJson(data);
  }

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      syllabus: _convertList(json['syllabus'], Syllabus.fromFirestore),
      documents: _convertList(json['documents'], Document.fromFirestore),
      assignments: _convertList(json['assignments'], Assignment.fromFirestore),
      quizzes: _convertList(json['quizzes'], Quiz.fromFirestore),
      labs: _convertList(json['labs'], Lab.fromFirestore),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'syllabus': syllabus.map((s) => s.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
      'labs': labs.map((l) => l.toJson()).toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  CourseData copyWith({
    List<Syllabus>? syllabus,
    List<Document>? documents,
    List<Assignment>? assignments,
    List<Quiz>? quizzes,
    List<Lab>? labs,
  }) => CourseData(
    syllabus: syllabus ?? this.syllabus,
    documents: documents ?? this.documents,
    assignments: assignments ?? this.assignments,
    quizzes: quizzes ?? this.quizzes,
    labs: labs ?? this.labs,
  );

  @override
  List<Object?> get props => [syllabus, documents, assignments, quizzes, labs];
}


List<T> _convertList<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromFirestore,
) {
  if (data == null) return [];
  final list = data as List<dynamic>;
  return list
      .map((item) => fromFirestore(item as Map<String, dynamic>))
      .toList();
}




class Syllabus extends Equatable {
  final String title;
  final String content;

  const Syllabus({required this.title, required this.content});

  factory Syllabus.fromFirestore(Map<String, dynamic> data) {
    return Syllabus.fromJson(data);
  }
  factory Syllabus.fromJson(Map<String, dynamic> json) {
    if (json['title'] == null || json['content'] == null) {
      throw const FormatException('Missing required fields in Syllabus');
    }
    return Syllabus(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'content': content};
  Map<String, dynamic> toFirestore() => toJson();

  @override
  List<Object> get props => [title, content];
}

class Document extends Equatable {
  final String id;
  final String name;
  final String url;
  final DateTime uploadedAt;

  const Document({
    required this.id,
    required this.name,
    required this.url,
    required this.uploadedAt,
  });

  factory Document.fromFirestore(Map<String, dynamic> data) {
    return Document.fromJson(data);
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['name'] == null ||
        json['url'] == null ||
        json['uploadedAt'] == null) {
      throw const FormatException('Missing required fields in Document');
    }
    return Document(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'uploadedAt': uploadedAt,
  };
  Map<String, dynamic> toFirestore() => toJson();

  @override
  List<Object> get props => [id, name, url, uploadedAt];
}

class Assignment extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxScore;

  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxScore,
  });

  factory Assignment.fromFirestore(Map<String, dynamic> data) {
    return Assignment.fromJson(data);
  }
  factory Assignment.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['title'] == null ||
        json['description'] == null ||
        json['dueDate'] == null ||
        json['maxScore'] == null) {
      throw const FormatException('Missing required fields in Assignment');
    }
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      maxScore: json['maxScore'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'maxScore': maxScore,
  };
  Map<String, dynamic> toFirestore() => toJson();

  @override
  List<Object> get props => [id, title, description, dueDate, maxScore];
}

class Quiz extends Equatable {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final int totalQuestions;

  const Quiz({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalQuestions,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data) {
    return Quiz.fromJson(data);
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['title'] == null ||
        json['startTime'] == null ||
        json['endTime'] == null ||
        json['duration'] == null ||
        json['totalQuestions'] == null) {
      throw const FormatException('Missing required fields in Quiz');
    }

    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      duration: json['duration'] as int,
      totalQuestions: json['totalQuestions'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'duration': duration,
    'totalQuestions': totalQuestions,
  };
  Map<String, dynamic> toFirestore() => toJson();

  @override
  List<Object> get props => [
    id,
    title,
    startTime,
    endTime,
    duration,
    totalQuestions,
  ];
}

class Lab extends Equatable {
  final String id;
  final String title;

  const Lab({required this.id, required this.title});

  factory Lab.fromFirestore(Map<String, dynamic> data) {
    return Lab.fromJson(data);
  }
  factory Lab.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['title'] == null) {
      throw const FormatException('Missing required fields in Lab');
    }
    return Lab(id: json['id'] as String, title: json['title'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
  Map<String, dynamic> toFirestore() => toJson();

  @override
  List<Object> get props => [id, title];
}
