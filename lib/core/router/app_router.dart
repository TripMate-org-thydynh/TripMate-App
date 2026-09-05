import '../../features/moments/presentation/pages/moment_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/theme_provider.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/auth_flow_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/onboarding/presentation/vibe_quiz_screen.dart';
import '../../features/trips/presentation/join_trip_screen.dart';
import '../../features/moments/presentation/pages/trip_recap_reel_screen.dart';

/// Mã mời đến từ deep link khi người dùng CHƯA đăng nhập.
///
/// Deep link có thể mở app ở trạng thái chưa auth; nếu chỉ redirect sang
/// `/auth` thì mã sẽ mất. Giữ lại đây để sau khi đăng nhập xong đưa thẳng
/// người dùng vào màn tham gia chuyến với mã đã điền sẵn.
final pendingJoinCodeProvider = StateProvider<String?>((ref) => null);

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final themeNotifier = ref.read(themeProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          final isDark = ref.watch(themeProvider) == ThemeMode.dark;
          return SplashScreen(
            isDarkMode: isDark,
            onThemeToggle: () => themeNotifier.toggleTheme(),
          );
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final isDark = ref.watch(themeProvider) == ThemeMode.dark;
          return AuthFlowScreen(
            isDarkMode: isDark,
            onThemeToggle: () => themeNotifier.toggleTheme(),
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final isDark = ref.watch(themeProvider) == ThemeMode.dark;
          return VibeQuizScreen(isDarkMode: isDark);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return const DashboardScreen();
        },
      ),
      // Deep link từ link mời: https://tripmate.app/join/<code>
      // hoặc tripmate://join/<code>.
      GoRoute(
        path: '/join/:code',
        builder: (context, state) {
          final isDark = ref.watch(themeProvider) == ThemeMode.dark;
          return JoinTripScreen(
            isDarkMode: isDark,
            initialCode: state.pathParameters['code'],
          );
        },
      ),
      // Trip Wrapped / TikTok/Spotify style story recap reel
      GoRoute(
        path: '/recap/:tripId',
        builder: (context, state) {
          final isDark = ref.watch(themeProvider) == ThemeMode.dark;
          final tripId = state.pathParameters['tripId'] ?? 'demo';
          return TripRecapReelScreen(
            isDarkMode: isDark,
            tripId: tripId,
          );
        },
      ),
      // Widget màn hình chính mở thẳng vào đây: tripmate://moments/viewer
      //
      // Phải khai báo TRƯỚC route bắt-tất `/:code` bên dưới, nếu không "viewer"
      // sẽ bị hiểu là mã mời chuyến và mở nhầm màn tham gia.
      GoRoute(
        path: '/viewer',
        builder: (context, state) => const MomentViewerScreen(),
      ),
      // Custom scheme tripmate://join/<code> nơi 'join' là host còn path là '/<code>'
      GoRoute(
        path: '/:code([A-Za-z0-9_-]{3,16})',
        builder: (context, state) {
          final isDark = ref.watch(themeProvider) == ThemeMode.dark;
          return JoinTripScreen(
            isDarkMode: isDark,
            initialCode: state.pathParameters['code'],
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      final isDark = ref.watch(themeProvider) == ThemeMode.dark;
      final uri = state.uri;
      final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      if (code != null &&
          code.isNotEmpty &&
          code != 'dashboard' &&
          code != 'auth' &&
          code != 'splash' &&
          code != 'onboarding') {
        return JoinTripScreen(isDarkMode: isDark, initialCode: code);
      }
      return const DashboardScreen();
    },
    redirect: (context, state) {
      // If auth state is still loading from storage, stay on splash or wait
      if (authState.isLoading) return null;

      final uri = state.uri;
      final isRecapUri = (uri.scheme == 'tripmate' && uri.host == 'recap') ||
          state.matchedLocation.startsWith('/recap/');
      if (isRecapUri) {
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'demo';
        if (!state.matchedLocation.startsWith('/recap/')) {
          return '/recap/$id';
        }
        return null;
      }

      final isLoggingIn = state.matchedLocation == '/auth';
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isJoining = state.matchedLocation.startsWith('/join/') ||
          (uri.scheme == 'tripmate' && uri.host == 'join') ||
          (state.pathParameters['code'] != null);
      final isAuthenticated = authState.isAuthenticated;

      if (isAuthenticated) {
        // Đã đăng nhập nhưng chưa làm vibe quiz → vào onboarding
        if (!authState.onboardingDone) {
          return isOnboarding ? null : '/onboarding';
        }
        // Vừa đăng nhập xong mà trước đó có deep link mời → vào thẳng màn join.
        final pending = ref.read(pendingJoinCodeProvider);
        if (pending != null && !isJoining) {
          // Xoá ngay để không lặp lại redirect ở lần điều hướng sau.
          Future.microtask(
            () => ref.read(pendingJoinCodeProvider.notifier).state = null,
          );
          return '/join/$pending';
        }
        // Đã xong onboarding → không cho quay lại splash/auth/onboarding
        if (isLoggingIn || isSplash || isOnboarding) {
          return '/dashboard';
        }
      } else {
        // Chưa đăng nhập mà mở link mời → nhớ mã rồi bắt đăng nhập trước.
        if (isJoining) {
          final code = state.pathParameters['code'];
          if (code != null && code.isNotEmpty) {
            Future.microtask(
              () => ref.read(pendingJoinCodeProvider.notifier).state = code,
            );
          }
          return '/auth';
        }
        // Chưa đăng nhập: chỉ được ở splash hoặc auth
        if (!isLoggingIn && !isSplash) {
          return '/auth';
        }
      }

      return null;
    },
  );
});
