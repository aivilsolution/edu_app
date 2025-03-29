
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Enrollment extends Equatable {
  final String courseId;
  final String studentId;
  final DateTime enrolledAt;

  const Enrollment({
    required this.courseId,
    required this.studentId,
    required this.enrolledAt,
  });

  factory Enrollment.fromFirestore(DocumentSnapshot doc, String courseId) {
    final data = doc.data()! as Map<String, dynamic>;
    return Enrollment(
      courseId: courseId,
      studentId: doc.id,
      enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'enrolledAt': FieldValue.serverTimestamp(),
  };

  @override
  List<Object> get props => [courseId, studentId, enrolledAt];
}
