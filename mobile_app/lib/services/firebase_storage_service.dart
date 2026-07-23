import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseStorageService {
  Future<String> uploadFile({required String path, required File file});
  Future<void> deleteFile({required String path});
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageServiceImpl({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile({required String path, required File file}) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Future<void> deleteFile({required String path}) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}
