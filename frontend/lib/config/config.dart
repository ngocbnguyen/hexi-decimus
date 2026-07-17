import 'package:flutter/foundation.dart';

class AppConfig {
  static String get authApiUrl {
    // If running inside an Android emulator, localhost is mapped to 10.0.2.2.
    // Otherwise (Chrome web, iOS simulator, macOS desktop), localhost is 127.0.0.1/localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/auth';
    }
    return 'http://localhost:8080/api/auth';
  }
}
