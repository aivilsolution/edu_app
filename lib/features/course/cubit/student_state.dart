
import 'package:equatable/equatable.dart';
import '../models/student.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentsLoaded extends StudentState {
  final List<Student> students;

  const StudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentDetailLoaded extends StudentState {
  final Student student;

  const StudentDetailLoaded(this.student);

  @override
  List<Object?> get props => [student];
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}
