import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_controller.dart';
import '../domain/chat_model.dart';
import '../../../core/providers.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'package:takash/shared/widgets/takash_icon.dart';

/// Sohbet listesi ekranı — Tüm aktif konuşmalar burada listelenir
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);
    final currentUserId = ref.watch(authStateProvider).value?.uid ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sohbetler'),
        centerTitle: false,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TakashIcon(
                      assetName: TakashIcon.chatBubble,
                      size: 64,
                      color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bir sohbetiniz yok',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Beğendiğiniz bir ilana teklif vererek\nsohbet başlatabilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 88),
            itemBuilder: (context, index) {
              final chat = chats[index];

              // Karşı tarafın bilgilerini bul (Katılımcılardan kendimiz olmayanı seçiyoruz)
              final otherUserId =
                  chat.participants.firstWhere((id) => id != currentUserId);
              final otherUserDetails =
                  chat.participantDetails[otherUserId] as Map<String, dynamic>?;
              final otherUserName = otherUserDetails?['name'] ?? 'Kullanıcı';
              final otherUserPhoto = otherUserDetails?['photo'];

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chat.listingThumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: chat.listingThumbnailUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 32,
                            height: 32,
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 32,
                            height: 32,
                            color: colorScheme.surfaceContainerHighest,
                            child: const TakashIcon(
                                assetName: TakashIcon.imageOff, size: 16),
                          ),
                        ),
                      ),
                    if (chat.listingThumbnailUrl != null)
                      const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: otherUserPhoto != null
                          ? CachedNetworkImageProvider(otherUserPhoto)
                          : null,
                      child: otherUserPhoto == null
                          ? TakashIcon(
                              assetName: TakashIcon.person,
                              color: colorScheme.onPrimaryContainer,
                              size: 20)
                          : null,
                    ),
                  ],
                ),
                title: Text(
                  otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat.listingTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        child: Text(
                          '📦 ${chat.listingTitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Helpers.timeAgo(chat.lastMessageAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 11),
                    ),
                    if (chat.offerStatus != OfferStatus.pending)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getOfferStatusColor(chat.offerStatus),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getOfferStatusLabel(chat.offerStatus),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  ref
                      .read(chatControllerProvider.notifier)
                      .markMessagesAsRead(chat.id, currentUserId);
                  context.push('/chat/${chat.id}');
                },
              );
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Mesajlar yükleniyor...'),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  Color _getOfferStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return Colors.amber;
      case OfferStatus.accepted:
        return Colors.green;
      case OfferStatus.declined:
        return Colors.red;
      case OfferStatus.completed:
        return Colors.blue;
    }
  }

  String _getOfferStatusLabel(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return 'Bekliyor';
      case OfferStatus.accepted:
        return 'Kabul';
      case OfferStatus.declined:
        return 'Red';
      case OfferStatus.completed:
        return 'Tamam';
    }
  }
}
