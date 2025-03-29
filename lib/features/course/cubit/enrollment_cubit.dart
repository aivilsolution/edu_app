
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/enrollment_repository.dart';
import 'enrollment_state.dart';
import '../utils/exceptions.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  final EnrollmentRepository _enrollmentRepository;

  EnrollmentCubit(this._enrollmentRepository) : super(EnrollmentInitial());

  Future<void> enrollInCourse(String courseId, String studentId) async {
    try {
      emit(EnrollmentLoading());
      await _enrollmentRepository.enroll(courseId, studentId);
      emit(EnrollmentSuccess());
    } on AppException catch (e) {
      emit(EnrollmentError(e.message));
    }
  }

  Future<void> unenrollFromCourse(String courseId, String studentId) async {
    try {
      emit(EnrollmentLoading());
      await _enrollmentRepository.unenroll(courseId, studentId);
      emit(EnrollmentSuccess());
    } on AppException catch (e) {
      emit(EnrollmentError(e.message));
    }
  }

  Future<void> fetchEnrollmentsForCourse(String courseId) async {
    try {
      emit(EnrollmentLoading());
      final enrollments =
          await _enrollmentRepository
              .watchEnrollmentsForCourse(courseId)
              .first; 
      emit(EnrollmentsLoaded(enrollments));
    } on AppException catch (e) {
      emit(EnrollmentError(e.message));
    }
  }

  Future<void> fetchEnrollmentsForStudent(String studentId) async {
    try {
      emit(EnrollmentLoading());
      final enrollments =
          await _enrollmentRepository
              .watchEnrollmentsForStudent(studentId)
              .first; 
      emit(EnrollmentsLoaded(enrollments));
    } on AppException catch (e) {
      emit(EnrollmentError(e.message));
    }
  }
}
