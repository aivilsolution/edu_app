import 'package:equatable/equatable.dart';
import '../models/professor.dart';

abstract class ProfessorState extends Equatable {
  const ProfessorState();

  @override
  List<Object?> get props => [];
}

class ProfessorInitial extends ProfessorState {}

class ProfessorLoading extends ProfessorState {}

class ProfessorsLoaded extends ProfessorState {
  final List<Professor> professors;

  const ProfessorsLoaded(this.professors);

  @override
  List<Object?> get props => [professors];
}

class ProfessorDetailLoaded extends ProfessorState {
  final Professor professor;

  const ProfessorDetailLoaded(this.professor);

  @override
  List<Object?> get props => [professor];
}

class ProfessorError extends ProfessorState {
  final String message;

  const ProfessorError(this.message);

  @override
  List<Object?> get props => [message];
}
