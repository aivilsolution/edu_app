import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_app/features/course/models/course_data.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Course extends Equatable {
  final String id;
  final String name;
  final String code;
  final String professorId;
  final DateTime createdAt;
  final CourseData? courseData;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.professorId,
    required this.createdAt,
    this.courseData,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Course(
      id: doc.id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      professorId: data['professorId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'code': code,
    'professorId': professorId,
    'createdAt': FieldValue.serverTimestamp(),
  };

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? professorId,
    DateTime? createdAt,
    CourseData? courseData,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      professorId: professorId ?? this.professorId,
      createdAt: createdAt ?? this.createdAt,
      courseData: courseData ?? this.courseData,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    professorId,
    createdAt,
    courseData,
  ];
}
