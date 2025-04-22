import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Recommendation extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const Recommendation({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Recommendation(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'createdAt': FieldValue.serverTimestamp(),
  };

  Recommendation copyWith({String? id, String? name, DateTime? createdAt}) {
    return Recommendation(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt];
}
