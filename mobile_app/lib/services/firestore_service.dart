import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreService {
  Future<void> setDocument({required String collection, required String docId, required Map<String, dynamic> data});
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({required String collection, required String docId});
  Future<void> updateDocument({required String collection, required String docId, required Map<String, dynamic> data});
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({required String collection});
}

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  @override
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
  }) {
    return _firestore.collection(collection).snapshots();
  }
}
