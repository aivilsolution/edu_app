
import 'package:equatable/equatable.dart';
import '../models/enrollment.dart';

abstract class EnrollmentState extends Equatable {
  const EnrollmentState();

  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {}

class EnrollmentLoading extends EnrollmentState {}

class EnrollmentsLoaded extends EnrollmentState {
  final List<Enrollment> enrollments;

  const EnrollmentsLoaded(this.enrollments);

  @override
  List<Object?> get props => [enrollments];
}

class EnrollmentError extends EnrollmentState {
  final String message;

  const EnrollmentError(this.message);

  @override
  List<Object?> get props => [message];
}

class EnrollmentSuccess extends EnrollmentState {}
