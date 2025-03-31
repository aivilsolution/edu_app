import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../utils/exceptions.dart';

abstract interface class StudentRepository {
  Future<Student> getById(String id);
  Stream<List<Student>> watchAll();
  Future<void> create(Student student);
  Future<void> update(Student student);
  Future<void> delete(String studentId);
}

class FirebaseStudentRepository implements StudentRepository {
  static const _studentsCollection = 'students';

  final FirebaseFirestore _firestore;
  late final CollectionReference _studentsRef;

  FirebaseStudentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _studentsRef = _firestore.collection(_studentsCollection);
  }

  @override
  Future<Student> getById(String id) async {
    try {
      final doc = await _studentsRef.doc(id).get();
      if (!doc.exists) throw NotFoundException('Student', id);
      return Student.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException('Student fetch failed', error: e);
    }
  }

  @override
  Stream<List<Student>> watchAll() => _studentsRef.snapshots().map(
    (snapshot) => snapshot.docs.map(Student.fromFirestore).toList(),
  );

  @override
  Future<void> create(Student student) async {
    try {
      await _studentsRef.doc(student.id).set(student.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Student creation failed', error: e);
    }
  }

  @override
  Future<void> update(Student student) async {
    try {
      await _studentsRef.doc(student.id).update(student.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Student update failed', error: e);
    }
  }

  @override
  Future<void> delete(String studentId) async {
    try {
      await _studentsRef.doc(studentId).delete();
    } on FirebaseException catch (e) {
      throw AppException('Student deletion failed', error: e);
    }
  }
}
