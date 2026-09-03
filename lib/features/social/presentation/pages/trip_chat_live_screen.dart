import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/network/error_message.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../profile/data/xp_repository.dart';
import '../../../profile/pages/sticker_store_screen.dart';
import '../../data/chat_repository.dart';
import '../../domain/chat_message.dart';

/// Chat nhóm realtime — history qua REST, live qua socket.io (`/chat`).
class TripChatLiveScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;
  const TripChatLiveScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<TripChatLiveScreen> createState() => _TripChatLiveScreenState();
}

class _TripChatLiveScreenState extends ConsumerState<TripChatLiveScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  ChatSocket? _socket;
  String? _myId;
  bool _loading = true;
  bool _connected = false;
  bool _loadingOlder = false;
  bool _hasMore = true;
  String? _error;

  bool get _dark => widget.isDarkMode;
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary =>
      _dark ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
  Color get _textPri => _dark ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _init();
  }

  void _onScroll() {
    // Gần đỉnh danh sách → tải tin nhắn cũ hơn.
    if (_scroll.position.pixels <= 80 && !_loadingOlder && _hasMore) {
      _loadOlder();
    }
  }

  Future<void> _loadOlder() async {
    if (_messages.isEmpty) return;
    setState(() => _loadingOlder = true);
    final oldestId = _messages.first.id;
    try {
      final older = await ref
          .read(chatRepositoryProvider)
          .fetch(widget.tripId, cursor: oldestId);
      if (older.isEmpty) {
        _hasMore = false;
      } else {
        final before = _scroll.position.maxScrollExtent;
        setState(() => _messages.insertAll(0, older));
        // Giữ nguyên vị trí cuộn sau khi chèn tin cũ lên đầu.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(
              _scroll.position.maxScrollExtent -
                  before +
                  _scroll.position.pixels,
            );
          }
        });
      }
    } catch (_) {
      // im lặng, giữ nguyên danh sách hiện có
    }
    if (mounted) setState(() => _loadingOlder = false);
  }

  Future<void> _init() async {
    final auth = ref.read(authProvider);
    _myId = auth.user?['id'] as String?;

    // 1) History qua REST
    try {
      final history = await ref
          .read(chatRepositoryProvider)
          .fetch(widget.tripId);
      _messages
        ..clear()
        ..addAll(history);
    } catch (e) {
      _error = friendlyError(e);
    }
    if (mounted) setState(() => _loading = false);
    _scrollToEnd();

    // 2) Live qua socket
    final token = auth.token;
    if (token != null) {
      _socket = ChatSocket(token)
        ..onConnectionChanged((c) {
          if (_disposed || !mounted) return;
          setState(() => _connected = c);
        })
        ..connect()
        ..join(widget.tripId)
        ..onMessage(_onLiveMessage);
    }
  }

  /// Đặt trước khi tháo socket.
  ///
  /// `dispose()` của socket phát luôn sự kiện disconnect, mà lúc đó `mounted`
  /// vẫn còn true trong khi element đã bị finalize → setState ném
  /// "_lifecycleState != defunct". Cờ này chặn mọi setState đến muộn.
  bool _disposed = false;

  void _onLiveMessage(dynamic data) {
    if (_disposed || !mounted) return;
    if (data is! Map) return;
    final msg = ChatMessage.fromJson(data.cast<String, dynamic>());
    if (_messages.any((m) => m.id == msg.id)) return;
    setState(() => _messages.add(msg));
    _scrollToEnd();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    if (_socket?.connected ?? false) {
      _socket!.send(widget.tripId, text);
    } else {
      // Fallback REST nếu socket chưa kết nối
      ref.read(chatRepositoryProvider).send(widget.tripId, text).then((m) {
        if (_disposed || !mounted) return;
        setState(() => _messages.add(m));
        _scrollToEnd();
      });
    }
    _input.clear();
  }

  /// Mở bảng chọn sticker — chỉ hiện sticker THẬT SỰ đã sở hữu.
  void _openStickerPicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Consumer(
        builder: (context, ref, _) => ref
            .watch(myStickersProvider)
            .when(
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  'errors.load_failed'.tr(),
                  style: AppFonts.body(color: _textSec),
                ),
              ),
              data: (stickers) {
                if (stickers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'xp.inventory_empty'.tr(),
                          textAlign: TextAlign.center,
                          style: AppFonts.body(color: _textSec, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StickerStoreScreen(
                                  isDarkMode: widget.isDarkMode,
                                ),
                              ),
                            );
                          },
                          child: Text('xp.open_store'.tr()),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: stickers.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _sendSticker(stickers[i].id);
                    },
                    child: Center(
                      child: Text(
                        stickers[i].emoji ?? '❔',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  Future<void> _sendSticker(String stickerId) async {
    HapticFeedback.lightImpact();
    try {
      final m = await ref
          .read(chatRepositoryProvider)
          .sendSticker(widget.tripId, stickerId);
      if (_disposed || !mounted) return;
      setState(() => _messages.add(m));
      _scrollToEnd();
    } catch (e) {
      if (_disposed || !mounted) return;
      // BE trả 403 nếu chưa sở hữu — hiện đúng câu đó.
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Bật cờ TRƯỚC khi tháo socket: socket.dispose() phát disconnect ngay.
    _disposed = true;
    _socket
      ?..leave(widget.tripId)
      ..dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Squad Chat',
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _connected ? const Color(0xFF1FA85C) : _textSec,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              _connected ? 'live' : 'common.connecting'.tr(),
              style: AppFonts.body(fontSize: 11, color: _textSec),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _body()),
          _composer(),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'chat.load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                color: _primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'chat.empty'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'chat.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 13, color: _textSec),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, i) => _bubble(_messages[i]),
    );
  }

  Widget _bubble(ChatMessage m) {
    final isMe = m.senderId == _myId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 2),
              child: Text(
                m.senderName,
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textSec,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMe ? _primary : _surface,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: isMe ? const Radius.circular(4) : null,
                bottomLeft: isMe ? null : const Radius.circular(4),
              ),
              border: isMe
                  ? null
                  : Border.all(
                      color: _dark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black,
                      width: 2,
                    ),
            ),
            // Tin nhắn sticker: `content` là MÃ sticker (stk-fire), không phải
            // chữ để đọc. Đổi sang emoji cỡ lớn, nếu không người nhận sẽ thấy
            // đúng chuỗi "stk-fire".
            child: m.type == 'STICKER'
                ? Text(
                    _stickerEmoji(m.content) ?? '❔',
                    style: const TextStyle(fontSize: 44),
                  )
                : Text(
                    m.content ?? '',
                    style: AppFonts.body(
                      fontSize: 14,
                      color: isMe ? Colors.white : _textPri,
                      height: 1.3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Emoji của một mã sticker.
  ///
  /// Ưu tiên tra trong kho đã tải; không có (người khác gửi sticker mình chưa
  /// mua) thì tra bảng dự phòng khớp với danh mục của backend.
  String? _stickerEmoji(String? stickerId) {
    if (stickerId == null) return null;
    final mine = ref.read(myStickersProvider).valueOrNull;
    final hit = mine?.where((s) => s.id == stickerId).firstOrNull;
    if (hit?.emoji != null) return hit!.emoji;
    return const {
      'stk-laugh': '😂',
      'stk-roast': '😜',
      'stk-broke': '💸',
      'stk-party': '🚀',
      'stk-fire': '🔥',
      'stk-cry': '😭',
      'stk-skull': '💀',
      'stk-crown': '👑',
    }[stickerId];
  }

  Widget _composer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Row(
          children: [
            // Nút sticker — chỗ DÙNG sticker đã đổi bằng XP. Không có chỗ này
            // thì việc mua sticker chẳng để làm gì.
            GestureDetector(
              onTap: _openStickerPicker,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: _surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.smiley(PhosphorIconsStyle.fill),
                  color: _primary,
                  size: 22,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                style: AppFonts.body(color: _textPri),
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'chat.input_hint'.tr(),
                  hintStyle: AppFonts.body(color: _textSec),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
