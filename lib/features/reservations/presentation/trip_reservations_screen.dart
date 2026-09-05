import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:tripmate/core/theme/app_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/reservations_repository.dart';

/// Đặt chỗ / vé của chuyến — vé máy bay, khách sạn, nhà hàng... (logic giống TREK).
class TripReservationsScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripReservationsScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary => const Color(0xFF8B4DE8);
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  static const _meta = <ReservationType, (String, IconData, Color)>{
    ReservationType.flight: (
      'reservations.type_flight',
      PhosphorIconsFill.airplaneTilt,
      Color(0xFF3D8BFF),
    ),
    ReservationType.train: (
      'reservations.type_train',
      PhosphorIconsFill.train,
      Color(0xFF06B6D4),
    ),
    ReservationType.bus: (
      'reservations.type_bus',
      PhosphorIconsFill.bus,
      Color(0xFF1FA85C),
    ),
    ReservationType.hotel: (
      'reservations.type_hotel',
      PhosphorIconsFill.buildings,
      Color(0xFF8B4DE8),
    ),
    ReservationType.restaurant: (
      'reservations.type_restaurant',
      PhosphorIconsFill.forkKnife,
      Color(0xFFF5822B),
    ),
    ReservationType.car: (
      'reservations.type_car_rental',
      PhosphorIconsFill.car,
      Color(0xFFD6248C),
    ),
    ReservationType.event: (
      'reservations.type_event',
      PhosphorIconsFill.ticket,
      Color(0xFFFFB020),
    ),
    ReservationType.attraction: (
      'reservations.type_attraction',
      PhosphorIconsFill.mapPin,
      Color(0xFFEF4444),
    ),
    ReservationType.other: (
      'expense.cat_other',
      PhosphorIconsFill.bookmarkSimple,
      Color(0xFF64748B),
    ),
  };

  /// Phần tử thứ 1 trong `_meta` là KEY i18n (const map không gọi được .tr()).
  (String, IconData, Color) _typeMeta(ReservationType t) {
    final m = _meta[t] ?? _meta[ReservationType.other]!;
    return (m.$1.tr(), m.$2, m.$3);
  }

  String _fmtMoney(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}tr';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  static const _months = 'Th1 Th2 Th3 Th4 Th5 Th6 Th7 Th8 Th9 Th10 Th11 Th12';
  String _fmtDate(DateTime d) {
    final m = _months.split(' ')[d.month - 1];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$m ${d.day} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripReservationsProvider(tripId));
    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => _addReservation(context, ref),
        icon: const Icon(Icons.add),
        label: Text(
          'packing.add'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'reservations.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
        actions: [
          // Booking-import: dán email vé → AI tự tách.
          IconButton(
            tooltip: 'reservations.paste_ticket'.tr(),
            onPressed: () => _importBooking(context, ref),
            icon: Icon(PhosphorIconsFill.sparkle, color: _primary),
          ),
          // Booking-import từ ảnh (Gemini vision).
          IconButton(
            tooltip: 'reservations.ticket_photo'.tr(),
            onPressed: () => _importFromImage(context, ref),
            icon: Icon(PhosphorIconsFill.camera, color: _primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () async => ref.invalidate(tripReservationsProvider(tripId)),
        child: async.when(
          loading: () => _skeleton(),
          error: (e, _) => _error(),
          data: (items) {
            if (items.isEmpty) return _empty();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: items.length,
              itemBuilder: (context, i) => _card(context, ref, items[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, Reservation r) {
    final meta = _typeMeta(r.type);
    final cancelled = r.status.toUpperCase() == 'CANCELLED';
    return GestureDetector(
      onLongPress: () => _showActions(context, ref, r),
      onTap: r.url == null || r.url!.isEmpty
          ? null
          : () => launchUrl(
              Uri.parse(r.url!),
              mode: LaunchMode.externalApplication,
            ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _textPri.withValues(alpha: 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dải màu + icon theo loại.
            Container(
              width: 56,
              decoration: BoxDecoration(
                color: meta.$3.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
              child: Icon(meta.$2, color: meta.$3, size: 26),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.title,
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: _textPri,
                              decoration: cancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (r.url != null && r.url!.isNotEmpty)
                          Icon(Icons.open_in_new, size: 15, color: _textSec),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta.$1,
                      style: AppFonts.body(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: meta.$3,
                      ),
                    ),
                    if (r.startTime != null) ...[
                      const SizedBox(height: 6),
                      _line(Icons.schedule, _fmtDate(r.startTime!.toLocal())),
                    ],
                    if (r.location != null && r.location!.isNotEmpty)
                      _line(Icons.place_outlined, r.location!),
                    if (r.confirmationNumber != null &&
                        r.confirmationNumber!.isNotEmpty)
                      _line(
                        Icons.confirmation_number_outlined,
                        r.confirmationNumber!,
                      ),
                    if (r.price != null && r.price! > 0)
                      _line(
                        Icons.account_balance_wallet_outlined,
                        _fmtMoney(r.price!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, size: 13, color: _textSec),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppFonts.body(fontSize: 12.5, color: _textSec),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    Reservation r,
  ) async {
    final cancelled = r.status.toUpperCase() == 'CANCELLED';
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _actionTile(
              ctx,
              Icons.edit_outlined,
              'reservations.edit'.tr(),
              'edit',
            ),
            _actionTile(
              ctx,
              cancelled ? Icons.check_circle_outline : Icons.cancel_outlined,
              cancelled ? 'reservations.restore_confirmed'.tr() : 'reservations.mark_cancelled'.tr(),
              'toggle',
            ),
            _actionTile(
              ctx,
              Icons.delete_outline,
              'general.delete2'.tr(),
              'delete',
              danger: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case 'edit':
        await _addReservation(context, ref, existing: r);
        break;
      case 'toggle':
        HapticFeedback.selectionClick();
        await ref
            .read(reservationsRepositoryProvider)
            .update(
              tripId,
              r.id,
              status: cancelled ? 'CONFIRMED' : 'CANCELLED',
            );
        ref.invalidate(tripReservationsProvider(tripId));
        break;
      case 'delete':
        await _confirmDelete(context, ref, r);
        break;
    }
  }

  Widget _actionTile(
    BuildContext ctx,
    IconData icon,
    String label,
    String value, {
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFD8422B) : _textPri;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppFonts.body(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Reservation r,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'common.delete_confirm'.tr(namedArgs: {'name': r.title}),
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            color: _textPri,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD8422B),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('general.delete2'.tr()),
          ),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await ref.read(reservationsRepositoryProvider).remove(tripId, r.id);
      ref.invalidate(tripReservationsProvider(tripId));
    }
  }

  Future<void> _importBooking(BuildContext context, WidgetRef ref) async {
    final textCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final paste = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(PhosphorIconsFill.sparkle, color: _primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'reservations.paste_title'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  color: _textPri,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'reservations.paste_sub'.tr(),
              style: AppFonts.body(fontSize: 12.5, color: _textSec),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              autofocus: true,
              maxLines: 6,
              style: AppFonts.body(color: _textPri, fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    'reservations.paste_hint'.tr(),
                hintStyle: AppFonts.body(color: _textSec, fontSize: 12),
                filled: true,
                fillColor: _bgOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('reservations.split_ticket'.tr()),
          ),
        ],
      ),
    );
    if (paste != true || textCtrl.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    messenger.showSnackBar(
      SnackBar(
        content: Text('reservations.parsing'.tr()),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 8),
      ),
    );
    final result = await ref
        .read(reservationsRepositoryProvider)
        .importFromText(tripId, textCtrl.text.trim());
    ref.invalidate(tripReservationsProvider(tripId));
    messenger.hideCurrentSnackBar();
    final created = result['created'] ?? 0;
    final exps = result['expensesCreated'] ?? 0;
    String msg;
    if (created == 0) {
      msg = 'reservations.ai_none_text'.tr();
    } else if (exps > 0) {
      msg = 'reservations.added_with_expenses'.tr(namedArgs: {'n': '\$created', 'e': '\$exps'});
    } else {
      msg = 'reservations.added_from_ticket'.tr(namedArgs: {'n': '\$created'});
    }
    messenger.showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  /// Import vé từ ảnh/screenshot — tái sử dụng Gemini vision (pattern photo-location).
  Future<void> _importFromImage(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    // Hỏi nguồn ảnh: thư viện hoặc chụp
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reservations.pick_photo'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'reservations.pick_photo_sub'.tr(),
              style: AppFonts.body(fontSize: 12.5, color: _textSec),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _sourceBtn(
                    ctx,
                    icon: PhosphorIconsFill.images,
                    label: 'common.gallery'.tr(),
                    source: ImageSource.gallery,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sourceBtn(
                    ctx,
                    icon: PhosphorIconsFill.camera,
                    label: 'common.take_photo'.tr(),
                    source: ImageSource.camera,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (file == null) return;

    HapticFeedback.mediumImpact();
    messenger.showSnackBar(
      SnackBar(
        content: Text('reservations.reading_photo'.tr()),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 12),
      ),
    );

    try {
      final bytes = await file.readAsBytes();
      final mime =
          file.mimeType ??
          (file.path.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');
      final result = await ref
          .read(reservationsRepositoryProvider)
          .importFromImage(tripId, base64Encode(bytes), mime);
      ref.invalidate(tripReservationsProvider(tripId));
      messenger.hideCurrentSnackBar();
      final created = result['created'] ?? 0;
      final exps = result['expensesCreated'] ?? 0;
      String msg;
      if (created == 0) {
        msg = 'reservations.ai_none_image'.tr();
      } else if (exps > 0) {
        msg = 'reservations.added_with_expenses'.tr(namedArgs: {'n': '\$created', 'e': '\$exps'});
      } else {
        msg = 'reservations.detected_from_image'.tr(
          namedArgs: {'n': '$created'},
        );
      }
      messenger.showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('reservations.photo_failed'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _sourceBtn(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) => GestureDetector(
    onTap: () => Navigator.pop(ctx, source),
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppFonts.heading(
              fontWeight: FontWeight.w700,
              color: _primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _addReservation(
    BuildContext context,
    WidgetRef ref, {
    Reservation? existing,
  }) async {
    final editing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final locCtrl = TextEditingController(text: existing?.location ?? '');
    final confCtrl = TextEditingController(
      text: existing?.confirmationNumber ?? '',
    );
    final urlCtrl = TextEditingController(text: existing?.url ?? '');
    final priceCtrl = TextEditingController(
      text: existing?.price == null ? '' : existing!.price!.toStringAsFixed(0),
    );
    var type = existing?.type ?? ReservationType.flight;
    DateTime? when = existing?.startTime?.toLocal();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'reservations.edit'.tr() : 'reservations.add'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: _textPri,
                  ),
                ),
                const SizedBox(height: 16),
                // Loại
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReservationType.values.map((t) {
                    final m = _typeMeta(t);
                    final sel = type == t;
                    return GestureDetector(
                      onTap: () => setSheet(() => type = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? m.$3 : _bgOf(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? m.$3 : _textSec.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              m.$2,
                              size: 14,
                              color: sel ? Colors.white : _textSec,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              m.$1,
                              style: AppFonts.body(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: sel ? Colors.white : _textPri,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _field(
                  context,
                  titleCtrl,
                  'reservations.title_hint'.tr(),
                  autofocus: true,
                ),
                const SizedBox(height: 10),
                _field(context, locCtrl, 'reservations.place_hint'.tr()),
                const SizedBox(height: 10),
                _field(context, confCtrl, 'reservations.ref_hint'.tr()),
                const SizedBox(height: 10),
                _field(context, urlCtrl, 'reservations.link_hint'.tr()),
                const SizedBox(height: 10),
                _field(
                  context,
                  priceCtrl,
                  'reservations.price_hint'.tr(),
                  number: true,
                ),
                const SizedBox(height: 12),
                // Ngày giờ
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: when ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (d == null) return;
                    if (!ctx.mounted) return;
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.now(),
                    );
                    setSheet(
                      () => when = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        t?.hour ?? 0,
                        t?.minute ?? 0,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _bgOf(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 18, color: _primary),
                        const SizedBox(width: 10),
                        Text(
                          when == null
                              ? 'reservations.datetime_hint'.tr()
                              : _fmtDate(when!),
                          style: AppFonts.body(
                            fontWeight: FontWeight.w600,
                            color: when == null ? _textSec : _textPri,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      editing
                          ? 'reservations.save_changes'.tr()
                          : 'reservations.save'.tr(),
                      style: AppFonts.heading(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      if (!context.mounted) return;
      HapticFeedback.mediumImpact();
      final price = double.tryParse(
        priceCtrl.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      final messenger = ScaffoldMessenger.of(context);
      final repo = ref.read(reservationsRepositoryProvider);
      if (editing) {
        await repo.update(
          tripId,
          existing.id,
          type: type,
          title: titleCtrl.text.trim(),
          location: locCtrl.text.trim().isEmpty ? null : locCtrl.text.trim(),
          confirmationNumber: confCtrl.text.trim().isEmpty
              ? null
              : confCtrl.text.trim(),
          url: urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim(),
          price: (price != null && price > 0) ? price : null,
          startTime: when,
        );
      } else {
        await repo.add(
          tripId,
          type: type,
          title: titleCtrl.text.trim(),
          location: locCtrl.text.trim().isEmpty ? null : locCtrl.text.trim(),
          confirmationNumber: confCtrl.text.trim().isEmpty
              ? null
              : confCtrl.text.trim(),
          url: urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim(),
          price: (price != null && price > 0) ? price : null,
          startTime: when,
        );
      }
      ref.invalidate(tripReservationsProvider(tripId));
      if (!editing && price != null && price > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('reservations.saved_with_expense'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _field(
    BuildContext context,
    TextEditingController c,
    String hint, {
    bool autofocus = false,
    bool number = false,
  }) => TextField(
    controller: c,
    autofocus: autofocus,
    keyboardType: number ? TextInputType.number : TextInputType.text,
    // Lọc chữ khi ô ấy là ô số — keyboardType chỉ gợi ý bàn phím.
    inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
    style: AppFonts.body(color: _textPri),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppFonts.body(color: _textSec),
      filled: true,
      fillColor: _bgOf(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  Widget _empty() => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      const SizedBox(height: 50),
      Icon(PhosphorIconsFill.ticket, size: 60, color: _primary),
      const SizedBox(height: 16),
      Text(
        'reservations.empty'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.heading(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: _textPri,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'reservations.empty_sub'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.body(fontSize: 14, color: _textSec),
      ),
    ],
  );

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      5,
      (i) => Container(
        height: 84,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  );

  Widget _error() => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'reservations.load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
