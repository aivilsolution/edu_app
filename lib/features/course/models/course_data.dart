import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CourseData extends Equatable {
  final List<Syllabus> syllabus;
  final List<Document> documents;
  final List<Assignment> assignments;
  final List<Quiz> quizzes;
  final List<Lab> labs;

  const CourseData({
    this.syllabus = const [],
    this.documents = const [],
    this.assignments = const [],
    this.quizzes = const [],
    this.labs = const [],
  });

  factory CourseData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }
    return CourseData.fromJson(data);
  }

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      syllabus: _convertList(json['syllabus'], Syllabus.fromJson),
      documents: _convertList(json['documents'], Document.fromJson),
      assignments: _convertList(json['assignments'], Assignment.fromJson),
      quizzes: _convertList(json['quizzes'], Quiz.fromJson),
      labs: _convertList(json['labs'], Lab.fromJson),
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

  Map<String, dynamic> toFirestore() => toJson();

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
  List<Object> get props => [syllabus, documents, assignments, quizzes, labs];
}

List<T> _convertList<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (data == null) return [];
  final list = data as List<dynamic>;
  return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
}

@immutable
class Syllabus extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;

  const Syllabus({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory Syllabus.fromJson(Map<String, dynamic> json) {
    return Syllabus(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Map<String, dynamic> toFirestore() => toJson();

  Syllabus copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? updatedAt,
  }) => Syllabus(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object> get props => [id, title, content, updatedAt];
}

@immutable
class Document extends Equatable {
  final String id;
  final String name;
  final String url;
  final DateTime uploadedAt;
  final String? description;

  const Document({
    required this.id,
    required this.name,
    required this.url,
    required this.uploadedAt,
    this.description,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      uploadedAt:
          (json['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'uploadedAt': Timestamp.fromDate(uploadedAt),
    'description': description,
  };

  Map<String, dynamic> toFirestore() => toJson();

  Document copyWith({
    String? id,
    String? name,
    String? url,
    DateTime? uploadedAt,
    String? uploadedBy,
    String? description,
  }) => Document(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    description: description ?? this.description,
  );

  @override
  List<Object?> get props => [id, name, url, uploadedAt, description];
}

@immutable
class Assignment extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final int maxScore;
  final List<String>? resources;
  final List<String>? requiredAttachments;

  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.maxScore,
    this.resources,
    this.requiredAttachments,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: (json['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxScore: json['maxScore'] as int? ?? 0,
      resources:
          json['resources'] != null
              ? List<String>.from(json['resources'])
              : null,
      requiredAttachments:
          json['requiredAttachments'] != null
              ? List<String>.from(json['requiredAttachments'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': Timestamp.fromDate(dueDate),
    'createdAt': Timestamp.fromDate(createdAt),
    'maxScore': maxScore,
    'resources': resources,
    'requiredAttachments': requiredAttachments,
  };

  Map<String, dynamic> toFirestore() => toJson();

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
    int? maxScore,
    List<String>? resources,
    List<String>? requiredAttachments,
  }) => Assignment(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    maxScore: maxScore ?? this.maxScore,
    resources: resources ?? this.resources,
    requiredAttachments: requiredAttachments ?? this.requiredAttachments,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    createdAt,
    maxScore,
    resources,
    requiredAttachments,
  ];
}

@immutable
class Quiz extends Equatable {
  final String id;
  final String title;
  final String description;
  final int duration;
  final DateTime createdAt;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'duration': duration,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Map<String, dynamic> toFirestore() => toJson();

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    DateTime? createdAt,
  }) => Quiz(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    duration: duration ?? this.duration,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object> get props => [id, title, description, duration, createdAt];
}

@immutable
class Lab extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  const Lab({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Map<String, dynamic> toFirestore() => toJson();

  Lab copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
  }) => Lab(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object> get props => [id, title, description, createdAt];
}
