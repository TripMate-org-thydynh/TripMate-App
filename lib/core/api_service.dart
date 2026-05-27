import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../features/system_states/pages/no_internet_screen.dart';

class ApiService {
  // Global Navigator Key for system-level redirection
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isOfflineScreenShowing = false;

  static void _navigateToNoInternet() {
    if (_isOfflineScreenShowing) return;
    final context = navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      _isOfflineScreenShowing = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NoInternetScreen(
            isDarkMode: true,
          ),
        ),
      ).then((_) {
        _isOfflineScreenShowing = false;
      });
    }
  }

  // Dynamically map localhost to 10.0.2.2 when running on Android Emulator
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api/v1';
      }
    } catch (_) {
      // Fallback for non-io platforms
    }
    return 'http://localhost:3000/api/v1';
  }

  // Secure in-memory token cache for authenticated requests
  static String? authToken;

  // Single persistent HttpClient instance for connection pooling & Keep-Alive
  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 6)
    ..idleTimeout = const Duration(seconds: 15);

  static Future<dynamic> get(String path) async {
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 6));
      
      // Inject headers
      request.headers.set('content-type', 'application/json');
      if (authToken != null) {
        request.headers.set('authorization', 'Bearer $authToken');
      } else {
        request.headers.set('authorization', 'Bearer dummy-token');
      }
      
      final response = await request.close()
          .timeout(const Duration(seconds: 6));
          
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body);
      }
      debugPrint('ApiService GET $path failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ApiService GET $path exception: $e');
      if (e is SocketException || e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        _navigateToNoInternet();
      }
      return null; // Triggers graceful offline mock fallbacks
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final request = await _client.postUrl(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 6));
      
      // Inject headers
      request.headers.set('content-type', 'application/json');
      if (authToken != null) {
        request.headers.set('authorization', 'Bearer $authToken');
      } else {
        request.headers.set('authorization', 'Bearer dummy-token');
      }
      
      request.write(jsonEncode(body));
      final response = await request.close()
          .timeout(const Duration(seconds: 6));
          
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = await response.transform(utf8.decoder).join();
        return jsonDecode(resBody);
      }
      debugPrint('ApiService POST $path failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ApiService POST $path exception: $e');
      if (e is SocketException || e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        _navigateToNoInternet();
      }
      return null;
    }
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final request = await _client.patchUrl(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 6));
      
      // Inject headers
      request.headers.set('content-type', 'application/json');
      if (authToken != null) {
        request.headers.set('authorization', 'Bearer $authToken');
      } else {
        request.headers.set('authorization', 'Bearer dummy-token');
      }
      
      request.write(jsonEncode(body));
      final response = await request.close()
          .timeout(const Duration(seconds: 6));
          
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = await response.transform(utf8.decoder).join();
        return jsonDecode(resBody);
      }
      debugPrint('ApiService PATCH $path failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ApiService PATCH $path exception: $e');
      if (e is SocketException || e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        _navigateToNoInternet();
      }
      return null;
    }
  }
}
