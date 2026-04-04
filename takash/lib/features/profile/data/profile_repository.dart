import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takash/core/providers.dart';
import 'package:takash/features/auth/domain/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRepository(this._firestore, this._storage);

  CollectionReference get _users => _firestore.collection('users');

  /// Kullanıcı profilini stream olarak izler
  Stream<UserModel?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Kullanıcı profilini bir kez getirir
  Future<UserModel?> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Profil bilgilerini günceller
  Future<void> updateProfile(UserModel user) async {
    await _users.doc(user.uid).update(user.toJson());
  }

  /// Profil fotoğrafını Storage'a yükler ve URL'sini döner
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('users').child(uid).child('profile_photo.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageProvider);
  return ProfileRepository(firestore, storage);
});

/// Mevcut giriş yapmış kullanıcının profilini izleyen provider
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  
  return ref.watch(profileRepositoryProvider).watchProfile(authUser.uid);
});

/// Belirli bir kullanıcıyı izleyen provider
final userDataProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchProfile(uid);
});
