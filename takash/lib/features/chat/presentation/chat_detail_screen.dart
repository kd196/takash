import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_controller.dart';
import '../data/chat_repository.dart';
import '../domain/chat_model.dart';
import '../domain/message_model.dart';
import '../../../core/providers.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/data/rating_repository.dart';
import '../../listings/data/listing_repository.dart';
import '../../listings/presentation/listings_controller.dart';
import '../../listings/domain/listing_category.dart';
import 'package:takash/shared/widgets/takash_icon.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImageFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(chatControllerProvider.notifier)
        .sendTextMessage(widget.chatId, text);
    _messageController.clear();
  }

  Future<void> _acceptOffer() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    try {
      await ref.read(chatRepositoryProvider).acceptOffer(
            widget.chatId,
            currentUser.uid,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teklif kabul edilirken hata: $e')),
        );
      }
    }
  }

  Future<void> _declineOffer() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    try {
      await ref.read(chatRepositoryProvider).declineOffer(
            widget.chatId,
            currentUser.uid,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teklif reddedilirken hata: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final currentUser = ref
        .read(userDataProvider(ref.read(authStateProvider).value?.uid ?? ''))
        .value;

    if (currentUser != null && currentUser.totalImageCount >= 3) {
      _showLimitDialog();
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
    );

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Düzenle',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImageFile = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _sendImageMessage() async {
    if (_selectedImageFile == null) return;

    setState(() => _isUploading = true);
    try {
      await ref.read(chatControllerProvider.notifier).sendImageMessage(
            widget.chatId,
            _selectedImageFile!,
          );
      setState(() {
        _selectedImageFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📸 Hesap Resim Sınırı'),
        content: const Text(
          'Hesap başı 3 resim sınırına ulaştınız. Premium ile sınırsız gönderim yakında!',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım')),
        ],
      ),
    );
  }

  Future<void> _completeExchange(String listingId, String otherUserId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Takas Tamamlansın mı?'),
        content: const Text(
            'Bu işlem geri alınamaz ve ilanlar yayından kaldırılır.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Evet, Tamamla')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(chatRepositoryProvider).completeTrade(widget.chatId);

        if (mounted) {
          _showRatingDialog(otherUserId, listingId);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  void _showRatingDialog(String targetUserId, String listingId) {
    double selectedRating = 5.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Center(child: Text('Takas Deneyimi Nasıl?')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Diğer kullanıcıyı puanla:'),
              const SizedBox(height: 16),
              // ── TAŞMA YAPMAYAN YILDIZ SATIRI ──
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedRating = index + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                '${selectedRating.toInt()} / 5',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(ratingRepositoryProvider).submitRating(
                        fromUserId: ref.read(authStateProvider).value!.uid,
                        toUserId: targetUserId,
                        listingId: listingId,
                        score: selectedRating,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Puanla ve Bitir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = ref.watch(authStateProvider).value;
    final colorScheme = Theme.of(context).colorScheme;

    final chat = ref
        .watch(userChatsProvider)
        .value
        ?.firstWhere((c) => c.id == widget.chatId);
    final otherUserId =
        chat?.participants.firstWhere((id) => id != currentUser?.uid);
    final otherUserDetails =
        chat?.participantDetails[otherUserId] as Map<String, dynamic>?;

    final listingAsync =
        ref.watch(singleListingProvider(chat?.listingId ?? ''));
    final isListingOwner = listingAsync
            .whenData((listing) => listing?.ownerId == currentUser?.uid)
            .valueOrNull ??
        false;

    final isCompleted = chat?.offerStatus == OfferStatus.completed;

    return Scaffold(
      appBar: _selectedImageFile != null
          ? null
          : _ChatDetailAppBar(
              listingId: chat?.listingId,
              listingTitle: chat?.listingTitle,
              listingThumbnailUrl: chat?.listingThumbnailUrl,
              otherUserName: otherUserDetails?['name'] ?? 'Kullanıcı',
              otherUserPhoto: otherUserDetails?['photo'],
              offerStatus: chat?.offerStatus,
              isCompleted: isCompleted,
              onTapListing: () {
                if (chat?.listingId != null) {
                  context.push('/listing/${chat!.listingId}');
                }
              },
              onCompleteExchange: chat?.offerStatus == OfferStatus.accepted &&
                      chat?.listingId != null &&
                      otherUserId != null
                  ? () => _completeExchange(chat!.listingId!, otherUserId!)
                  : null,
            ),
      body: Stack(
        children: [
          Column(
            children: [
              if (chat != null && chat.offerStatus != OfferStatus.pending)
                _OfferStatusBanner(
                  offerStatus: chat.offerStatus,
                  onAccept: () => _acceptOffer(),
                  onDecline: () => _declineOffer(),
                ),
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(
                          child: Text('Sohbeti başlatın... 👋'));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUser?.uid;
                        return _MessageBubble(
                          message: message,
                          isMe: isMe,
                          chatId: widget.chatId,
                        );
                      },
                    );
                  },
                  loading: () => const LoadingIndicator(),
                  error: (err, _) => Center(child: Text('Hata: $err')),
                ),
              ),
              _buildInputArea(colorScheme),
            ],
          ),
          if (_selectedImageFile != null)
            _buildProfessionalImagePreview(colorScheme),
        ],
      ),
    );
  }

  Widget _buildProfessionalImagePreview(ColorScheme colorScheme) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _selectedImageFile = null),
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Fotoğraf Önizleme',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImageFile!, fit: BoxFit.contain),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isUploading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isUploading
                              ? null
                              : () => setState(() => _selectedImageFile = null),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _sendImageMessage,
                          icon: const Icon(Icons.send),
                          label: const Text('Sohbete Gönder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
            top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: TakashIcon(
                  assetName: TakashIcon.addPhoto,
                  color: colorScheme.primary,
                  size: 28),
              onPressed: _pickImage,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  enableInteractiveSelection: true,
                  decoration: const InputDecoration(
                    hintText: 'Mesaj yazın...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: _sendMessage,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: TakashIcon(
                      assetName: TakashIcon.send,
                      color: Colors.white,
                      size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final MessageModel message;
  final bool isMe;
  final String chatId;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.chatId,
  });

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Mesajı Sil',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Metni Kopyala'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Metin kopyalandı'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesajı Sil'),
        content: const Text('Bu mesaj kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          TextButton(
            onPressed: () {
              ref
                  .read(chatControllerProvider.notifier)
                  .deleteMessage(chatId, message);
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openImageFull(BuildContext context) {
    if (message.type != MessageType.image || message.imageUrl == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white)),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: message.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showOptions(context, ref),
        onTap: message.type == MessageType.image
            ? () => _openImageFull(context)
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight:
                  isMe ? const Radius.circular(0) : const Radius.circular(16),
              bottomLeft:
                  isMe ? const Radius.circular(16) : const Radius.circular(0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.type == MessageType.image && message.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: message.imageUrl!,
                      placeholder: (context, url) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                  ),
                ),
              if (message.type == MessageType.text ||
                  message.type == MessageType.offer)
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Helpers.formatTime(message.createdAt),
                    style: TextStyle(
                      color:
                          (isMe ? colorScheme.onPrimary : colorScheme.onSurface)
                              .withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: colorScheme.onPrimary.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferStatusBanner extends StatelessWidget {
  final OfferStatus offerStatus;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _OfferStatusBanner({
    required this.offerStatus,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;
    String message;
    IconData icon;

    switch (offerStatus) {
      case OfferStatus.pending:
        bgColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        message = 'Teklif bekleniyor...';
        icon = Icons.hourglass_empty;
        break;
      case OfferStatus.accepted:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        message = 'Teklif kabul edildi! Takası koordine edin';
        icon = Icons.check_circle;
        break;
      case OfferStatus.declined:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        message = 'Teklif reddedildi';
        icon = Icons.cancel;
        break;
      case OfferStatus.completed:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        message = 'Takas tamamlandı!';
        icon = Icons.verified;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
          if (offerStatus == OfferStatus.pending) ...[
            TextButton(
              onPressed: onAccept,
              child: const Text('Kabul'),
            ),
            TextButton(
              onPressed: onDecline,
              child: Text('Red', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? listingId;
  final String? listingTitle;
  final String? listingThumbnailUrl;
  final String? otherUserName;
  final String? otherUserPhoto;
  final OfferStatus? offerStatus;
  final bool isCompleted;
  final VoidCallback? onTapListing;
  final VoidCallback? onCompleteExchange;

  const _ChatDetailAppBar({
    required this.listingId,
    required this.listingTitle,
    required this.listingThumbnailUrl,
    required this.otherUserName,
    required this.otherUserPhoto,
    required this.offerStatus,
    required this.isCompleted,
    required this.onTapListing,
    required this.onCompleteExchange,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          if (listingThumbnailUrl != null)
            GestureDetector(
              onTap: onTapListing,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: listingThumbnailUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: colorScheme.surfaceContainerHighest,
                    child: const TakashIcon(
                        assetName: TakashIcon.imageOff, size: 20),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    color: colorScheme.surfaceContainerHighest,
                    child: const TakashIcon(
                        assetName: TakashIcon.imageOff, size: 20),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (listingTitle != null)
                  Text(
                    listingTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  otherUserName ?? 'Kullanıcı',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (listingId != null)
          IconButton(
            icon: const TakashIcon(assetName: TakashIcon.info, size: 22),
            onPressed: onTapListing,
            tooltip: 'İlana Git',
          ),
        if (onCompleteExchange != null)
          TextButton.icon(
            onPressed: onCompleteExchange,
            icon: const TakashIcon(assetName: TakashIcon.checkCircle, size: 20),
            label: const Text('Takası Bitir'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        if (isCompleted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Chip(
              label: const Text('Tamamlandı'),
              backgroundColor: Colors.green.shade100,
              labelStyle: TextStyle(color: Colors.green.shade800, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
