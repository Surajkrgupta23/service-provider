import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Cooperative Clap';
  static const String appTagline = 'आपका विश्वसनीय सेवा साथी';
  static const String appVersion = '2.0.0';
  static const String environment = 'dev';

  static const String serverHost = '192.168.1.35';
  static const String apiPath = '/CP-APPP/service-provider/backend/api/index.php';

  static String get baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.contains('localhost:') || origin.contains('127.0.0.1:')) {
        return 'http://localhost$apiPath';
      }
      return '$origin$apiPath';
    }
    return 'http://$serverHost$apiPath';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
