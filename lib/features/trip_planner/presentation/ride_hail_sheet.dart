import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_messenger.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../domain/itinerary_item.dart';

/// Gọi xe tới một điểm dừng.
///
/// Người Việt đi lại bằng Grab/Be chứ ít khi tự dẫn đường, nên mỗi điểm có lối
/// tắt gọi xe. Giới hạn cần biết:
/// - Grab: deep link `grab://open?screenType=BOOKING&dropOff...` mở màn đặt xe
///   với điểm đến điền sẵn. Tham số này là tài liệu dành cho đối tác Grab; nếu
///   bản app không nhận, Grab vẫn mở và người dùng dán địa chỉ.
/// - Be: không công bố deep link đặt xe → mở trang app trên cửa hàng (có nút
///   "Mở" khi đã cài) và người dùng dán địa chỉ.
/// Vì vậy địa chỉ LUÔN được chép sẵn vào bộ nhớ tạm trước khi mở app.
class RideHailSheet extends StatelessWidget {
  const RideHailSheet({super.key, required this.item, required this.isDark});

  final ItineraryItem item;
  final bool isDark;

  static Future<void> show(
    BuildContext context,
    ItineraryItem item, {
    required bool isDark,
  }) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => RideHailSheet(item: item, isDark: isDark),
  );

  String get _address {
    final addr = item.placeAddress?.trim() ?? '';
    return addr.isEmpty ? item.placeName : '${item.placeName}, $addr';
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _address));
  }

  Future<bool> _open(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _grab(BuildContext context) async {
    final nav = Navigator.of(context);
    await _copy();
    final q = <String, String>{
      'screenType': 'BOOKING',
      'dropOffAddress': _address,
      'dropOffKeywords': item.placeName,
      if (item.hasCoords) 'dropOffLatitude': '${item.latitude}',
      if (item.hasCoords) 'dropOffLongitude': '${item.longitude}',
    };
    final deep = Uri(scheme: 'grab', host: 'open', queryParameters: q);
    final ok =
        await _open(deep.toString()) ||
        await _open('market://details?id=com.grabtaxi.passenger') ||
        await _open(
          'https://play.google.com/store/apps/details?id=com.grabtaxi.passenger',
        );
    _done(nav, ok);
  }

  Future<void> _be(BuildContext context) async {
    final nav = Navigator.of(context);
    await _copy();
    final ok =
        await _open('market://details?id=xyz.be.customer') ||
        await _open(
          'https://play.google.com/store/apps/details?id=xyz.be.customer',
        );
    _done(nav, ok);
  }

  void _done(NavigatorState nav, bool ok) {
    nav.pop();
    showGlobalSnack(
      ok ? 'itinerary.ride_copied'.tr() : 'itinerary.ride_failed'.tr(),
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    Widget option(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
    ) => ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        style: AppFonts.heading(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.body(fontSize: 12, color: inkSoft),
      ),
      trailing: Icon(PhosphorIcons.caretRight(), size: 18, color: inkSoft),
    );

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'itinerary.ride_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _address,
                style: AppFonts.body(fontSize: 13, color: inkSoft),
              ),
              const SizedBox(height: 12),
              option(
                PhosphorIcons.car(),
                'Grab',
                'itinerary.ride_grab_hint'.tr(),
                () => _grab(context),
              ),
              option(
                PhosphorIcons.motorcycle(),
                'Be',
                'itinerary.ride_be_hint'.tr(),
                () => _be(context),
              ),
              option(
                PhosphorIcons.copy(),
                'itinerary.ride_copy'.tr(),
                'itinerary.ride_copy_hint'.tr(),
                () async {
                  await _copy();
                  if (context.mounted) Navigator.pop(context);
                  showGlobalSnack('itinerary.ride_copy_done'.tr());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
