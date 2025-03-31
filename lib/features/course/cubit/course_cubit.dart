import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/course_repository.dart';
import 'course_state.dart';
import '../models/course.dart';
import '../utils/exceptions.dart';

class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _courseRepository;
  CourseState? _lastLoadedState;

  CourseCubit(this._courseRepository) : super(CourseInitial());

  CourseState? get lastLoadedState => _lastLoadedState;
  Future<void> fetchAllCourses() async {
    try {
      emit(CourseLoading());

      if (_lastLoadedState is CourseLoaded) {
        emit(_lastLoadedState!);
      }

      final courses = await _courseRepository.watchAll().first;
      final loadedState = CourseLoaded(courses);
      _lastLoadedState = loadedState;
      emit(loadedState);
    } on AppException catch (e) {
      emit(CourseError(e.message));
    }
  }

  Future<void> fetchCoursesByProfessor(String professorId) async {
    try {
      emit(CourseLoading());
      final courses =
          await _courseRepository.watchByProfessor(professorId).first;
      emit(CourseLoaded(courses));
    } on AppException catch (e) {
      emit(CourseError(e.message));
    }
  }

  Future<void> fetchCourseById(String courseId) async {
    try {
      emit(CourseLoading());
      final course = await _courseRepository.getById(courseId);
      emit(CourseDetailLoaded(course));
    } on AppException catch (e) {
      emit(CourseError(e.message));
    }
  }

  Future<void> createCourse(Course course) async {
    try {
      await _courseRepository.create(course);
      await fetchAllCourses();
    } on AppException catch (e) {
      emit(CourseError(e.message));
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      await _courseRepository.update(course);
      await fetchAllCourses();
    } on AppException catch (e) {
      emit(CourseError(e.message));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _courseRepository.delete(courseId);
      await fetchAllCourses();
    } on AppException catch (e) {
      emit(CourseError(e.message));
    }
  }
}
