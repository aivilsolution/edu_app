import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enrollment.dart';
import '../utils/exceptions.dart';

abstract interface class EnrollmentRepository {
  Future<void> enroll(String courseId, String studentId);
  Future<void> unenroll(String courseId, String studentId);
  Stream<List<Enrollment>> watchEnrollmentsForCourse(String courseId);
  Stream<List<Enrollment>> watchEnrollmentsForStudent(String studentId);
}

class FirebaseEnrollmentRepository implements EnrollmentRepository {
  static const _coursesCollection = 'courses';
  static const _studentsCollection = 'students';
  static const _enrollmentsCollection = 'enrollments';

  final FirebaseFirestore _firestore;
  late final CollectionReference _coursesRef;
  late final CollectionReference _studentsRef;

  FirebaseEnrollmentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _coursesRef = _firestore.collection(_coursesCollection);
    _studentsRef = _firestore.collection(_studentsCollection);
  }

  @override
  Future<void> enroll(String courseId, String studentId) async {
    try {
      final enrollmentRef = _coursesRef
          .doc(courseId)
          .collection(_enrollmentsCollection)
          .doc(studentId);

      await _firestore.runTransaction((transaction) async {
        final courseDoc = await transaction.get(_coursesRef.doc(courseId));
        final studentDoc = await transaction.get(_studentsRef.doc(studentId));

        if (!courseDoc.exists) throw NotFoundException('Course', courseId);
        if (!studentDoc.exists) throw NotFoundException('Student', studentId);

        transaction.set(enrollmentRef, {
          'enrolledAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      throw AppException('Enrollment failed', error: e);
    }
  }

  @override
  Future<void> unenroll(String courseId, String studentId) async {
    try {
      final enrollmentRef = _coursesRef
          .doc(courseId)
          .collection(_enrollmentsCollection)
          .doc(studentId);

      await enrollmentRef.delete();
    } on FirebaseException catch (e) {
      throw AppException('Unenrollment failed', error: e);
    }
  }

  @override
  Stream<List<Enrollment>> watchEnrollmentsForCourse(String courseId) {
    return _coursesRef
        .doc(courseId)
        .collection(_enrollmentsCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Enrollment.fromFirestore(doc, courseId))
                  .toList(),
        );
  }

  @override
  Stream<List<Enrollment>> watchEnrollmentsForStudent(String studentId) {
    return _studentsRef
        .doc(studentId)
        .collection(_enrollmentsCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Enrollment.fromFirestore(
                      doc,
                      doc.reference.path.split('/')[1],
                    ),
                  )
                  .toList(),
        );
  }
}
