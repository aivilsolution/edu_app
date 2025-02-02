part of 'course_model.dart';

// Instructor  model
class Professor {
  final String id;
  final String name;
  final String email;
  final String department;
  final String officeHours;
  final String officeLocation;

  Professor({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.officeHours,
    required this.officeLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'officeHours': officeHours,
      'officeLocation': officeLocation,
    };
  }

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      department: map['department'],
      officeHours: map['officeHours'],
      officeLocation: map['officeLocation'],
    );
  }
}
