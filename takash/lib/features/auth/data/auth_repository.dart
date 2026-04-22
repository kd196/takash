import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';
import '../../../core/providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firestore'da profil var mı kontrol et, yoksa oluştur
    if (credential.user != null) {
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        await _saveUserToFirestore(
          credential.user!,
          credential.user!.displayName ?? email.split('@').first,
        );
      }
    }

    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await _saveUserToFirestore(credential.user!, displayName);
    }

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('idToken null');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!doc.exists) {
          await _saveUserToFirestore(
            userCredential.user!,
            userCredential.user!.displayName ?? 'Kullanıcı',
          );
        }
      }

      return userCredential;
    } catch (e, stack) {
      developer.log('=== GOOGLE SIGN-IN ERROR ===');
      developer.log('Error: $e');
      developer.log('Stack: $stack');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> _saveUserToFirestore(User user, String displayName) async {
    final Map<String, dynamic> data = {
      'uid': user.uid,
      'displayName': displayName,
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      // totalImageCount yoksa 0 yap, varsa dokunma (FieldValue.serverTimestamp benzeri bir mantık)
    };

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      data['totalImageCount'] = 0; // Sadece ilk girişte 0 yap
    }

    await userRef.set(data, SetOptions(merge: true));
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updatePrivacySettings({
    required String uid,
    bool? isLocationShared,
    String? profileVisibility,
  }) async {
    final updates = <String, dynamic>{};
    if (isLocationShared != null) {
      updates['isLocationShared'] = isLocationShared;
    }
    if (profileVisibility != null) {
      updates['profileVisibility'] = profileVisibility;
    }
    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }
  }

  Future<void> deleteAccount(String uid, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');

    final credential = EmailAuthProvider.credential(
      email: user.email ?? '',
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    final batch = _firestore.batch();

    final userDocRef = _firestore.collection('users').doc(uid);
    batch.delete(userDocRef);

    final listingsSnapshot = await _firestore
        .collection('listings')
        .where('ownerId', isEqualTo: uid)
        .get();
    for (final doc in listingsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    try {
      final storage = FirebaseStorage.instance;
      await storage.ref('profile_photos/$uid').delete();
    } catch (_) {}

    await user.delete();
  }
}
