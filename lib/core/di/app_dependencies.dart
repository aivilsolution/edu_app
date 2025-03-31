import 'package:edu_app/features/auth/auth.dart';
import 'package:edu_app/features/course/cubit/course_cubit.dart';
import 'package:edu_app/features/course/cubit/enrollment_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/student_cubit.dart';
import 'package:edu_app/features/course/repositories/course_repository.dart';
import 'package:edu_app/features/course/repositories/enrollment_repository.dart';
import 'package:edu_app/features/course/repositories/professor_repository.dart';
import 'package:edu_app/features/course/repositories/student_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  final SharedPreferences prefs;
  final AuthRepository authRepository;
  final AuthBloc authBloc;
  final FirebaseCourseRepository courseRepository;
  final CourseCubit courseCubit;
  final FirebaseProfessorRepository professorRepository;
  final ProfessorCubit professorCubit;
  final FirebaseStudentRepository studentRepository;
  final StudentCubit studentCubit;
  final FirebaseEnrollmentRepository enrollmentRepository;
  final EnrollmentCubit enrollmentCubit;

  AppDependencies._({
    required this.prefs,
    required this.authRepository,
    required this.authBloc,
    required this.courseRepository,
    required this.courseCubit,
    required this.professorRepository,
    required this.professorCubit,
    required this.studentRepository,
    required this.studentCubit,
    required this.enrollmentRepository,
    required this.enrollmentCubit,
  });

  static Future<AppDependencies> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final authRepository = AuthRepository(prefs: prefs);
    final authBloc = AuthBloc(authRepository);
    final courseRepository = FirebaseCourseRepository();
    final courseCubit = CourseCubit(courseRepository);
    final professorRepository = FirebaseProfessorRepository();
    final professorCubit = ProfessorCubit(professorRepository);
    final studentRepository = FirebaseStudentRepository();
    final studentCubit = StudentCubit(studentRepository);
    final enrollmentRepository = FirebaseEnrollmentRepository();
    final enrollmentCubit = EnrollmentCubit(enrollmentRepository);

    authBloc.add(AuthStarted());

    return AppDependencies._(
      prefs: prefs,
      authRepository: authRepository,
      authBloc: authBloc,
      courseRepository: courseRepository,
      courseCubit: courseCubit,
      professorRepository: professorRepository,
      professorCubit: professorCubit,
      studentRepository: studentRepository,
      studentCubit: studentCubit,
      enrollmentRepository: enrollmentRepository,
      enrollmentCubit: enrollmentCubit,
    );
  }
}
