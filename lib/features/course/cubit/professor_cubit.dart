import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/professor_repository.dart';
import 'professor_state.dart';
import '../models/professor.dart';
import '../utils/exceptions.dart';

class ProfessorCubit extends Cubit<ProfessorState> {
  final ProfessorRepository _professorRepository;

  ProfessorCubit(this._professorRepository) : super(ProfessorInitial());

  Future<void> fetchAllProfessors() async {
    try {
      emit(ProfessorLoading());
      final professors = await _professorRepository.watchAll().first;
      emit(ProfessorsLoaded(professors));
    } on AppException catch (e) {
      emit(ProfessorError(e.message));
    }
  }

  Future<void> fetchProfessorById(String professorId) async {
    try {
      emit(ProfessorLoading());
      final professor = await _professorRepository.getById(professorId);
      emit(ProfessorDetailLoaded(professor));
    } on AppException catch (e) {
      emit(ProfessorError(e.message));
    }
  }

  Future<void> createProfessor(Professor professor) async {
    try {
      await _professorRepository.create(professor);
      await fetchAllProfessors();
    } on AppException catch (e) {
      emit(ProfessorError(e.message));
    }
  }

  Future<void> updateProfessor(Professor professor) async {
    try {
      await _professorRepository.update(professor);
      await fetchAllProfessors();
    } on AppException catch (e) {
      emit(ProfessorError(e.message));
    }
  }

  Future<void> deleteProfessor(String professorId) async {
    try {
      await _professorRepository.delete(professorId);
      await fetchAllProfessors();
    } on AppException catch (e) {
      emit(ProfessorError(e.message));
    }
  }
}
