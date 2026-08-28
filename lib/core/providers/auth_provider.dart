import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final bool onboardingDone;

  AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.onboardingDone = false,
  });

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? token,
    Map<String, dynamic>? user,
    bool? isLoading,
    bool? onboardingDone,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  // Token & user nhạy cảm → secure storage (Keychain/Keystore).
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  // onboarding_done không nhạy cảm → SharedPreferences là đủ.
  static const _onboardingKey = 'onboarding_done';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AuthNotifier() : super(AuthState(isLoading: true)) {
    _loadSession();
  }

  Future<bool> _onboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> _loadSession() async {
    try {
      final token = await _secure.read(key: _tokenKey);
      final userStr = await _secure.read(key: _userKey);
      final onboardingDone = await _onboardingFlag();

      if (token != null && userStr != null) {
        final user = jsonDecode(userStr) as Map<String, dynamic>;
        ApiService.authToken = token; // Synchronize with ApiService
        state = AuthState(
          token: token,
          user: user,
          isLoading: false,
          onboardingDone: onboardingDone,
        );
      } else {
        state = AuthState(isLoading: false, onboardingDone: onboardingDone);
      }
    } catch (_) {
      state = AuthState(isLoading: false);
    }
  }

  Future<void> setSession(String token, Map<String, dynamic> user) async {
    try {
      await _secure.write(key: _tokenKey, value: token);
      await _secure.write(key: _userKey, value: jsonEncode(user));
      final onboardingDone = await _onboardingFlag();

      ApiService.authToken = token; // Synchronize with ApiService
      state = AuthState(
        token: token,
        user: user,
        isLoading: false,
        onboardingDone: onboardingDone,
      );
    } catch (_) {
      // Handle fallback
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {
      // ignore persistence failure, vẫn cập nhật state
    }
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> logout() async {
    try {
      await _secure.delete(key: _tokenKey);
      await _secure.delete(key: _userKey);

      ApiService.authToken = null; // Synchronize with ApiService
      state = AuthState(isLoading: false);
    } catch (_) {
      // Handle fallback
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
