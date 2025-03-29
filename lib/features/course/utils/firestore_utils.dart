
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  static const int whereInMax = 10;
  static const int batchWriteMax = 500;

  static Future<List<T>> fetchDocuments<T>({
    required CollectionReference collection,
    required List<String> ids,
    required T Function(DocumentSnapshot) mapper,
  }) async {
    final List<T> results = [];
    for (var i = 0; i < ids.length; i += whereInMax) {
      final batchIds = ids.sublist(
        i,
        i + whereInMax < ids.length ? i + whereInMax : ids.length,
      );
      final snapshot =
          await collection.where(FieldPath.documentId, whereIn: batchIds).get();
      results.addAll(snapshot.docs.map(mapper));
    }
    return results;
  }

  static Future<void> batchOperation({
    required List<String> ids,
    required Future<void> Function(WriteBatch, List<String>) operation,
  }) async {
    for (var i = 0; i < ids.length; i += batchWriteMax) {
      final batchIds = ids.sublist(
        i,
        i + batchWriteMax < ids.length ? i + batchWriteMax : ids.length,
      );
      final batch = FirebaseFirestore.instance.batch();
      await operation(batch, batchIds);
      await batch.commit();
    }
  }
}
