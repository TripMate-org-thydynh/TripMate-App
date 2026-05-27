import 'dart:convert';
import 'dart:io';

class ApiService {
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

  static Future<dynamic> get(String path) async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('$baseUrl$path'));
      
      // Inject headers
      request.headers.set('content-type', 'application/json');
      if (authToken != null) {
        request.headers.set('authorization', 'Bearer $authToken');
      } else {
        request.headers.set('authorization', 'Bearer dummy-token');
      }
      
      final response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body);
      }
      print('ApiService GET $path failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('ApiService GET $path exception: $e');
      return null; // Triggers graceful offline mock fallbacks
    } finally {
      client?.close();
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4);
      final request = await client.postUrl(Uri.parse('$baseUrl$path'));
      
      // Inject headers
      request.headers.set('content-type', 'application/json');
      if (authToken != null) {
        request.headers.set('authorization', 'Bearer $authToken');
      } else {
        request.headers.set('authorization', 'Bearer dummy-token');
      }
      
      request.write(jsonEncode(body));
      final response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = await response.transform(utf8.decoder).join();
        return jsonDecode(resBody);
      }
      print('ApiService POST $path failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('ApiService POST $path exception: $e');
      return null;
    } finally {
      client?.close();
    }
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4);
      final request = await client.patchUrl(Uri.parse('$baseUrl$path'));
      
      // Inject headers
      request.headers.set('content-type', 'application/json');
      if (authToken != null) {
        request.headers.set('authorization', 'Bearer $authToken');
      } else {
        request.headers.set('authorization', 'Bearer dummy-token');
      }
      
      request.write(jsonEncode(body));
      final response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = await response.transform(utf8.decoder).join();
        return jsonDecode(resBody);
      }
      print('ApiService PATCH $path failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('ApiService PATCH $path exception: $e');
      return null;
    } finally {
      client?.close();
    }
  }
}
