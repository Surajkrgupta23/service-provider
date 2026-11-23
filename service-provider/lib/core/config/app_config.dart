import 'package:flutter/foundation.dart';

/// Centralized Application Configuration
/// Follows SOP Section 5 ("Avoid hardcoded API URLs. Separate environment configurations.")
class AppConfig {
  static const String appName = 'Cooperative Clap';
  static const String appTagline = 'आपका विश्वसनीय सेवा साथी';
  static const String appVersion = '2.0.0';

  // Environments: 'dev', 'staging', 'production'
  static const String environment = 'dev';

  // Central Server IP / Domain
  // Change this ONE variable to switch entire app between localhost, Wi-Fi LAN IP, or Live Domain!
  static const String serverHost = '192.168.1.35';
  static const String apiPath = '/CP-APPP/service-provider/backend/api/index.php';

  /// Dynamically resolves the Base API URL
  static String get baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      // When running on Flutter Web dev server (e.g. localhost:56637), route to Apache port 80
      if (origin.contains('localhost:') || origin.contains('127.0.0.1:')) {
        return 'http://localhost$apiPath';
      }
      return '$origin$apiPath';
    }
    
    // For Android/iOS:
    // When using Android Emulator, can use 'http://10.0.2.2$apiPath'
    // For real physical device testing on Wi-Fi:
    return 'http://$serverHost$apiPath';
  }

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
