import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_service.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileState {
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? stats;
  final List<dynamic> badges;
  final bool isLoading;

  ProfileState({
    this.profile,
    this.stats,
    this.badges = const [],
    this.isLoading = true,
  });

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    Map<String, dynamic>? stats,
    List<dynamic>? badges,
    bool? isLoading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    // SWR (Stale-While-Revalidate) Cache implementation:
    // If cache already exists, we do not show the loading spinner.
    // Instead, we serve it instantly and update it in the background silently.
    if (state.profile != null) {
      _fetchData();
      return;
    }

    state = state.copyWith(isLoading: true);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // 3 request độc lập → gọi song song thay vì nối tiếp.
      final results = await Future.wait([
        ApiService.get('/users/me'),
        ApiService.get('/users/me/stats'),
        ApiService.get('/users/me/badges'),
      ]);

      // Provider `watch` authProvider nên bị dispose ngay khi logout (vd 401).
      // Nếu request đang bay về mà ghi state sau dispose thì StateNotifier ném
      // "Tried to use ProfileNotifier after dispose was called".
      if (!mounted) return;

      final profile = results[0];
      final stats = results[1];
      final badges = results[2];
      state = ProfileState(
        profile: profile is Map<String, dynamic> ? profile : null,
        stats: stats is Map<String, dynamic> ? stats : null,
        badges: badges is List ? badges : [],
        isLoading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  void clearCache() {
    state = ProfileState(isLoading: false);
  }
}

final profileDataProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
      ref.watch(authProvider);
      return ProfileNotifier();
    });
