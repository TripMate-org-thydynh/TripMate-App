import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/responsive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart'; // themeProvider + accentProvider
import 'core/router/app_router.dart';
import 'core/app_messenger.dart';
import 'core/api_service.dart';
import 'core/services/widget_sync.dart';
import 'core/providers/auth_provider.dart';
import 'core/network/api_client.dart';
import 'core/services/push_notifications.dart';
import 'core/services/crash_reporter.dart';
import 'features/premium/data/entitlement_provider.dart';
import 'features/premium/data/trial_provider.dart';
import 'features/trips/application/trips_providers.dart';
import 'features/dashboard/data/home_feed_repository.dart';
import 'features/profile/data/profile_provider.dart';
import 'core/locale_detect.dart';
import 'core/widgets/app_gate_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Trước mọi thứ khác: lỗi lúc khởi động cũng phải được ghi nhận.
  CrashReporter.install();
  await EasyLocalization.ensureInitialized();

  // Container riêng để push (chạy trước khi có widget) điều hướng được bằng
  // router của app khi người dùng bấm vào thông báo.
  final container = ProviderContainer();
  unawaited(
    PushNotifications.init(
      onOpen: () => container.read(appRouterProvider).go('/dashboard'),
    ),
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('vi'),
        // Lần mở đầu: chọn theo máy — ngôn ngữ tiếng Việt HOẶC vùng Việt Nam
        // → vi, còn lại → en (bản dịch en đã phủ toàn app từ 2026-11-24). Từ
        // màn splash/đăng nhập đã đúng ngôn ngữ. Người dùng đổi trong app thì
        // lựa chọn đó được lưu và thắng lựa chọn tự động này.
        startLocale: detectStartLocale(
          WidgetsBinding.instance.platformDispatcher.locales,
        ),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Update API client languages dynamically when locale changes
    ApiService.currentLanguage = context.locale.languageCode;
    ApiClient.currentLanguage = context.locale.languageCode;

    // ApiService là service tĩnh nên tự nó không logout được khi token hết hạn.
    // Nối vào authProvider để 401 ở nhánh này cũng đưa người dùng về /auth,
    // giống AuthInterceptor của ApiClient.
    ApiService.onUnauthorized = () {
      ref.read(authProvider.notifier).logout();
      // Xoá ảnh squad khỏi widget màn hình chính khi phiên hết hạn — không để
      // ảnh của nhóm nằm lại trên máy sau khi người dùng đã đăng xuất.
      ref.read(widgetSyncProvider).clear();
    };

    // Đồng bộ widget mỗi lần mở app: đây là một trong hai lần cập nhật chắc
    // chắn (lần kia là ngay sau khi chính mình gửi ảnh). Ảnh của người khác
    // phụ thuộc lịch làm mới của hệ điều hành — xem ios/WIDGET_SETUP.md.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated && prev?.isAuthenticated != true) {
        ref.read(widgetSyncProvider).refresh();
        // Báo token máy cho server để nhận bản tin sáng.
        PushNotifications.register(ref.read(apiClientProvider));
      }
      if (!next.isAuthenticated && prev?.isAuthenticated == true) {
        PushNotifications.unregister();
        ref.read(widgetSyncProvider).clear();
        ref.invalidate(entitlementProvider);
        ref.invalidate(trialStatusProvider);
        ref.invalidate(tripsProvider);
        ref.invalidate(upNextProvider);
        ref.invalidate(expenseSummaryProvider);
        ref.invalidate(squadActivitiesProvider);
        ref.invalidate(profileDataProvider);
      }
    });

    final themeMode = ref.watch(themeProvider);
    final accent = ref.watch(accentProvider);
    final _ = ref.watch(
      fontProvider,
    ); // Watch font changes to trigger global rebuild
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      scaffoldMessengerKey: rootMessengerKey,
      title: 'TripMate',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: TripMateTheme.buildLight(accent),
      darkTheme: TripMateTheme.buildDark(accent),
      themeMode: themeMode,
      // Kep co chu trong khoang 1.0–1.3.
      //
      // Tren may that de co chu he thong lon (Samsung), giao dien vo ra: the
      // "Chua co chuyen nao" tran 54px, nhan "Chia tien" bi cat con "Chia
      // ti...", va nhan thanh dieu huong duoi chong len nhau. Van ton trong
      // nguoi dung tang co chu (den 1.3x), nhung khong de mot muc phong bat ky
      // pha vo bo cuc.
      builder: (context, child) {
        // Co giãn chữ theo khung nhìn thật của máy.
        //
        // Mọi cỡ chữ trong app được chọn trên khung thiết kế 411x914dp. Trên
        // máy có khung chật hơn (SM-A920F thật: 360x740dp vì người dùng bật
        // chế độ hiển thị phóng to), chữ giữ nguyên cỡ sẽ ngốn hết chiều cao
        // và bố cục vỡ tỉ lệ — dù không tràn.
        //
        // Nhân hệ số này vào `textScaler` là điểm sửa tập trung duy nhất, thay
        // vì đi sửa cỡ chữ ở hàng trăm chỗ gọi.
        final media = MediaQuery.of(context);
        final scale = uiScaleOf(media.size);
        return MediaQuery(
          data: media.copyWith(
            // Vẫn tôn trọng người dùng phóng chữ (tới 1.3x), nhưng trần
            // được hạ theo khung máy để không phá bố cục.
            textScaler: TextScaler.linear(
              media.textScaler.scale(1).clamp(1.0, 1.3) * scale,
            ),
          ),
          child: AppGateBoundary(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
