import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/chat_model.dart';
import '../domain/message_model.dart';
import '../../../core/providers.dart';
import '../../notifications/presentation/notification_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../../shared/utils/badge_formatter.dart';

/// Kullanıcının tüm sohbetlerini dinleyen provider
final userChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(chatRepositoryProvider).getUserChats(user.uid);
});

/// Belirli bir sohbetin mesajlarını dinleyen provider
final chatMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
});

/// Toplam okunmamış (chat + bildirim) sayısını hesaplayan provider (Badge için)
final unreadCountProvider = Provider<int>((ref) {
  final chats = ref.watch(userChatsProvider).value ?? [];
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) return 0;

  int chatCount = 0;
  for (final chat in chats) {
    final count = chat.unreadCounts[currentUser.uid];
    if (count != null) chatCount += count.toInt();
  }

  final notificationCount = ref.watch(unreadNotificationCountProvider);

  return chatCount + notificationCount;
});

/// Badge metnini hesaplayan provider
final badgeTextProvider = Provider<String?>((ref) {
  final count = ref.watch(unreadCountProvider);
  final formatted = formatBadgeCount(count);
  return formatted.isEmpty ? null : formatted;
});

/// Sohbet işlemlerini yöneten controller
final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);

class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Sohbet başlat veya var olanı getir
  Future<ChatModel?> startChat({
    required UserModel otherUser,
    String? listingId,
    String? listingTitle,
  }) async {
    final currentUser = ref
        .read(userDataProvider(ref.read(authStateProvider).value?.uid ?? ''))
        .value;
    if (currentUser == null) return null;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await ref.read(chatRepositoryProvider).createOrGetChat(
            currentUser: currentUser,
            otherUser: otherUser,
            listingId: listingId,
            listingTitle: listingTitle,
          );
    });

    state = const AsyncData(null);
    return result.value;
  }

  /// Metin mesajı gönder
  Future<void> sendTextMessage(String chatId, String text) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    await ref.read(chatRepositoryProvider).sendMessage(chatId, text, userId);
  }

  /// Resim mesajı gönder
  Future<void> sendImageMessage(String chatId, File imageFile) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendImageMessage(chatId, imageFile, userId);
    } catch (e) {
      rethrow; // Limit hatasını UI'da yakalamak için
    }
  }

  /// Mesajı sil
  Future<void> deleteMessage(String chatId, MessageModel message) async {
    await ref.read(chatRepositoryProvider).deleteMessage(chatId, message);
  }

  /// Okundu olarak işaretle
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await ref.read(chatRepositoryProvider).markAsRead(chatId, userId);
  }
}
