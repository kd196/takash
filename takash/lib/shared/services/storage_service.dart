import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file,
      {String? contentType}) async {
    final ref = _storage.ref().child(path);
    final metadata =
        contentType != null ? SettableMetadata(contentType: contentType) : null;

    final uploadTask = await ref.putFile(file, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<List<String>> uploadMultipleFiles(
    String path,
    List<File> files, {
    String? contentType,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
      final url = await uploadFile('$path/$fileName', files[i],
          contentType: contentType);
      urls.add(url);
    }
    return urls;
  }

  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  Reference ref(String path) => _storage.ref().child(path);
}
