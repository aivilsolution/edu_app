import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/student_repository.dart';
import 'student_state.dart';
import '../models/student.dart';
import '../utils/exceptions.dart';

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository _studentRepository;

  StudentCubit(this._studentRepository) : super(StudentInitial());

  Future<void> fetchAllStudents() async {
    try {
      emit(StudentLoading());
      final students = await _studentRepository.watchAll().first;
      emit(StudentsLoaded(students));
    } on AppException catch (e) {
      emit(StudentError(e.message));
    }
  }

  Future<void> fetchStudentById(String studentId) async {
    try {
      emit(StudentLoading());
      final student = await _studentRepository.getById(studentId);
      emit(StudentDetailLoaded(student));
    } on AppException catch (e) {
      emit(StudentError(e.message));
    }
  }

  Future<void> createStudent(Student student) async {
    try {
      await _studentRepository.create(student);
      await fetchAllStudents();
    } on AppException catch (e) {
      emit(StudentError(e.message));
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _studentRepository.update(student);
      await fetchAllStudents();
    } on AppException catch (e) {
      emit(StudentError(e.message));
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await _studentRepository.delete(studentId);
      await fetchAllStudents();
    } on AppException catch (e) {
      emit(StudentError(e.message));
    }
  }
}
