import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/chat_model.dart';
import '../domain/message_model.dart';
import '../../auth/domain/user_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// İki kullanıcı için benzersiz sohbet ID üret (Alfabetik UID birleşimi)
  String generateChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  /// Sohbet odası oluştur veya var olanı getir
  Future<ChatModel> createOrGetChat({
    required UserModel currentUser,
    required UserModel otherUser,
    String? listingId,
    String? listingTitle,
  }) async {
    final chatId = generateChatId(currentUser.uid, otherUser.uid);
    final chatRef = _firestore.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (doc.exists) {
      return ChatModel.fromJson(doc.data()!, doc.id);
    }

    // Yeni sohbet oluştur
    final newChat = ChatModel(
      id: chatId,
      participants: [currentUser.uid, otherUser.uid],
      participantDetails: {
        currentUser.uid: {
          'name': currentUser.displayName,
          'photo': currentUser.photoUrl,
        },
        otherUser.uid: {
          'name': otherUser.displayName,
          'photo': otherUser.photoUrl,
        },
      },
      lastMessage: 'Sohbet başladı 👋',
      lastMessageAt: DateTime.now(),
      imageCount: 0,
      listingId: listingId,
      listingTitle: listingTitle,
    );

    await chatRef.set(newChat.toJson());
    return newChat;
  }

  /// Kullanıcının tüm sohbetlerini dinle
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Sohbet mesajlarını dinle
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Metin mesajı gönder
  Future<void> sendMessage(String chatId, String text, String senderId, {MessageType type = MessageType.text}) async {
    final messageId = const Uuid().v4();
    final now = DateTime.now();

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      text: text,
      type: type,
      createdAt: now,
    );

    final batch = _firestore.batch();
    
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc(messageId);

    batch.set(messageRef, message.toJson());
    
    final chatDoc = await chatRef.get();
    final participants = List<String>.from(chatDoc.data()!['participants'] ?? []);
    final otherUserId = participants.firstWhere((id) => id != senderId);
    
    batch.update(chatRef, {
      'lastMessage': type == MessageType.image ? '📷 Fotoğraf' : text,
      'lastMessageAt': Timestamp.fromDate(now),
      'unreadCounts.$otherUserId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Resim mesajı gönder (Global Limit Kontrolü - Hesap Başına 3 Resim)
  Future<void> sendImageMessage(String chatId, File imageFile, String senderId) async {
    final userRef = _firestore.collection('users').doc(senderId);
    
    // 1. Hesap Başına Limit Kontrolü
    final userDoc = await userRef.get();
    final totalImageCount = userDoc.data()?['totalImageCount'] ?? 0;
    
    if (totalImageCount >= 3) {
      throw Exception('📸 Hesap başına resim sınırına ulaştınız (Max 3). Sınırsız gönderim için Premium çok yakında!');
    }

    final messageId = const Uuid().v4();
    final now = DateTime.now();

    // 2. Storage'a Yükle
    final storagePath = 'chats/$chatId/images/$messageId.jpg';
    final uploadTask = await _storage.ref().child(storagePath).putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await uploadTask.ref.getDownloadURL();

    // 3. Mesajı Kaydet, Sohbeti Güncelle ve Kullanıcı Sayacını Artır
    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      text: 'Fotoğraf gönderdi',
      imageUrl: imageUrl,
      type: MessageType.image,
      createdAt: now,
    );

    final batch = _firestore.batch();
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    batch.set(chatRef.collection('messages').doc(messageId), message.toJson());
    batch.update(chatRef, {
      'lastMessage': '📷 Fotoğraf',
      'lastMessageAt': Timestamp.fromDate(now),
    });
    // Kullanıcının toplam resim sayısını artır
    batch.update(userRef, {
      'totalImageCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Mesajı sil (Eğer resimse sayaçtan düşer)
  Future<void> deleteMessage(String chatId, MessageModel message) async {
    final batch = _firestore.batch();
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc(message.id);
    
    batch.delete(messageRef);

    // Eğer silinen mesaj bir resimse, kullanıcının limit hakkını iade et
    if (message.type == MessageType.image) {
      final userRef = _firestore.collection('users').doc(message.senderId);
      batch.update(userRef, {
        'totalImageCount': FieldValue.increment(-1),
      });
    }

    await batch.commit();
  }

  /// Mesajı okundu olarak işaretle
  Future<void> markAsRead(String chatId, String userId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({'unreadCounts.$userId': 0});
  }
}

final chatRepositoryProvider = Provider((ref) => ChatRepository());
