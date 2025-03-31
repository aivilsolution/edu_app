import 'package:equatable/equatable.dart';
import '../models/course.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;

  const CourseLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseDetailLoaded extends CourseState {
  final Course course;

  const CourseDetailLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}
