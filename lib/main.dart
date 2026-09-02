import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('vi'),
        // TripMate là sản phẩm Việt và bản dịch tiếng Anh chưa phủ hết, nên mở
        // app luôn ở tiếng Việt thay vì bám ngôn ngữ máy. Không có dòng này,
        // máy đặt tiếng Anh sẽ thấy màn hình lẫn hai thứ tiếng. Người dùng vẫn
        // đổi được ngôn ngữ trong app và lựa chọn đó được ghi nhớ.
        startLocale: const Locale('vi'),
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
    ref.listen(authProvider, (prev, next) {
      if (next.isAuthenticated && prev?.isAuthenticated != true) {
        ref.read(widgetSyncProvider).refresh();
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
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
