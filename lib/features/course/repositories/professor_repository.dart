
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/professor.dart';
import '../utils/exceptions.dart';

abstract interface class ProfessorRepository {
  Future<Professor> getById(String id);
  Stream<List<Professor>> watchAll();
  Future<void> create(Professor professor);
  Future<void> update(Professor professor);
  Future<void> delete(String professorId);
}

class FirebaseProfessorRepository implements ProfessorRepository {
  static const _professorsCollection = 'professors';

  final FirebaseFirestore _firestore;
  late final CollectionReference _professorsRef;

  FirebaseProfessorRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _professorsRef = _firestore.collection(_professorsCollection);
  }

  @override
  Future<Professor> getById(String id) async {
    try {
      final doc = await _professorsRef.doc(id).get();
      if (!doc.exists) throw NotFoundException('Professor', id);
      return Professor.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException('Professor fetch failed', error: e);
    }
  }

  @override
  Stream<List<Professor>> watchAll() => _professorsRef.snapshots().map(
    (snapshot) => snapshot.docs.map(Professor.fromFirestore).toList(),
  );

  @override
  Future<void> create(Professor professor) async {
    try {
      await _professorsRef.doc(professor.id).set(professor.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Professor creation failed', error: e);
    }
  }

  @override
  Future<void> update(Professor professor) async {
    try {
      await _professorsRef.doc(professor.id).update(professor.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Professor update failed', error: e);
    }
  }

  @override
  Future<void> delete(String professorId) async {
    try {
      await _professorsRef.doc(professorId).delete();
    } on FirebaseException catch (e) {
      throw AppException('Professor deletion failed', error: e);
    }
  }
}
