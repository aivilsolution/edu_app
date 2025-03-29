
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Course extends Equatable {
  final String id;
  final String name;
  final String code;
  final String professorId;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.professorId,
    required this.createdAt,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: data['name'] as String,
      code: data['code'] as String,
      professorId: data['professorId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
  }) => Course(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    professorId: professorId ?? this.professorId,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object> get props => [id, name, code, professorId, createdAt];
}
