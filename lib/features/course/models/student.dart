
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Student extends Equatable {
  final String id;
  final String name;
  final String email;

  const Student({required this.id, required this.name, required this.email});

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
    );
  }

  Map<String, dynamic> toFirestore() => {'name': name, 'email': email};

  Student copyWith({String? id, String? name, String? email}) => Student(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );

  @override
  List<Object> get props => [id, name, email];
}
