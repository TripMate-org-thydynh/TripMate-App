import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../trips/application/trips_providers.dart';
import '../data/profile_provider.dart';

/// Xuất dữ liệu của tôi.
///
/// Trước đây màn này tên là "Sao lưu & Khôi phục Offline": nút sao lưu ghi vào
/// SharedPreferences một cục dữ liệu **in cứng** — 3 chuyến không tồn tại
/// ("Phú Quốc Escape", "Đà Lạt Săn Mây", "Hà Nội Ăn Sập"), 18 checklist, 12 địa
/// điểm — rồi báo "Đã sao lưu dữ liệu thành công!". Ai tin vào nó trước khi xoá
/// dữ liệu sẽ mất sạch.
///
/// Dữ liệu thật nằm trên máy chủ nên bản sao dưới máy không có tác dụng khôi
/// phục; thứ thật sự hữu ích là **xuất** ra JSON để người dùng tự giữ. Phần
/// "khôi phục/ghi đè" đã bỏ vì không có đường nhập ngược lại.
class BackupRestoreScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const BackupRestoreScreen({super.key, required this.isDarkMode});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _busy = false;

  /// Gom dữ liệu THẬT của user thành JSON đọc được.
  String _buildExport() {
    final profile = ref.read(profileDataProvider);
    final trips = ref.read(tripsProvider).value ?? const [];

    return const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.profile,
      'stats': profile.stats,
      'badges': profile.badges,
      'trips': [
        for (final t in trips)
          {
            'id': t.id,
            'name': t.name,
            'destination': t.destination,
            'startDate': t.startDate.toIso8601String(),
            'endDate': t.endDate.toIso8601String(),
            'currency': t.currency,
            'budget': t.budget,
            'memberCount': t.memberCount,
            'members': [for (final m in t.members) m.name],
          },
      ],
    });
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final json = _buildExport();
      await Share.share(
        json,
        subject: 'TripMate — ${'profile.export_title'.tr()}',
      );
      if (!mounted) return;
      setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _buildExport()));
    showGlobalSnack('profile.export_copied'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'profile.export_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: tripsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => AppErrorState(
          isDark: isDark,
          error: e,
          onRetry: () => ref.read(tripsProvider.notifier).refresh(),
        ),
        data: (trips) {
          final profile = ref.watch(profileDataProvider);
          return ListView(
            padding: const EdgeInsets.all(GenZTokens.space5),
            children: [
              Container(
                padding: const EdgeInsets.all(GenZTokens.space5),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(
                    color: ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.export_contains'.tr(),
                      style: AppFonts.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space3),
                    _line(ink, 'profile.export_trips'.plural(trips.length)),
                    _line(
                      ink,
                      'profile.export_badges'.plural(profile.badges.length),
                    ),
                    _line(ink, 'profile.export_profile'.tr()),
                    const SizedBox(height: GenZTokens.space3),
                    Text(
                      'profile.export_note'.tr(),
                      style: AppFonts.body(
                        fontSize: 12.5,
                        color: inkSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GenZTokens.space5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _share,
                  icon: const Icon(Icons.ios_share, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GenZTokens.yellow,
                    foregroundColor: GenZTokens.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  label: Text(
                    'profile.export_share'.tr(),
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: GenZTokens.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GenZTokens.space3),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _copy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: ink,
                      width: GenZTokens.borderWidthThin,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  label: Text(
                    'profile.export_copy'.tr(),
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(Color ink, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        const Text('• '),
        Expanded(
          child: Text(text, style: AppFonts.body(fontSize: 13.5, color: ink)),
        ),
      ],
    ),
  );
}
