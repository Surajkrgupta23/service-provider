import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Centralized Dio HTTP Client
/// Follows SOP Section 7 ("Centralized base URL, Timeout configuration, Error handling")
class ApiClient {
  static Dio get dio {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // Auth Session Management
  static const String _keyToken = 'auth_token';
  static const String _keyProvider = 'provider_data';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyProvider);
  }
}
