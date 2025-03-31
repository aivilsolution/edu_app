import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../utils/exceptions.dart';

abstract interface class CourseRepository {
  Future<Course> getById(String id);
  Stream<List<Course>> watchAll();
  Stream<List<Course>> watchByProfessor(String professorId);
  Future<void> create(Course course);
  Future<void> update(Course course);
  Future<void> delete(String courseId);
}

class FirebaseCourseRepository implements CourseRepository {
  static const _coursesCollection = 'courses';

  final FirebaseFirestore _firestore;
  late final CollectionReference _coursesRef;

  FirebaseCourseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _coursesRef = _firestore.collection(_coursesCollection);
  }

  @override
  Future<Course> getById(String id) async {
    try {
      final doc = await _coursesRef.doc(id).get();
      if (!doc.exists) throw NotFoundException('Course', id);
      return Course.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException('Course fetch failed', error: e);
    }
  }

  @override
  Stream<List<Course>> watchAll() => _coursesRef
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Course.fromFirestore).toList());

  @override
  Stream<List<Course>> watchByProfessor(String professorId) => _coursesRef
      .where('professorId', isEqualTo: professorId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Course.fromFirestore).toList());

  @override
  Future<void> create(Course course) async {
    try {
      await _coursesRef.doc(course.id).set(course.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Course creation failed', error: e);
    }
  }

  @override
  Future<void> update(Course course) async {
    try {
      await _coursesRef.doc(course.id).update(course.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Course update failed', error: e);
    }
  }

  @override
  Future<void> delete(String courseId) async {
    try {
      await _coursesRef.doc(courseId).delete();
    } on FirebaseException catch (e) {
      throw AppException('Course deletion failed', error: e);
    }
  }
}
