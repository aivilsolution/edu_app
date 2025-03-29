
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Professor extends Equatable {
  final String id;
  final String name;
  final String department;
  final String email;

  const Professor({
    required this.id,
    required this.name,
    required this.department,
    required this.email,
  });

  factory Professor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Professor(
      id: doc.id,
      name: data['name'] as String,
      department: data['department'] as String,
      email: data['email'] as String,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'department': department,
    'email': email,
  };

  Professor copyWith({
    String? id,
    String? name,
    String? department,
    String? email,
  }) => Professor(
    id: id ?? this.id,
    name: name ?? this.name,
    department: department ?? this.department,
    email: email ?? this.email,
  );

  @override
  List<Object> get props => [id, name, department, email];
}
