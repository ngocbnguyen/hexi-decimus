import 'package:flutter/foundation.dart';

class AppConfig {
  static String get authApiUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/auth';
    }
    return 'http://localhost:8080/api/auth';
  }

  static String get jobsApiUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/job-applications';
    }
    return 'http://localhost:8080/api/job-applications';
  }

  static String get documentsApiUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/documents';
    }
    return 'http://localhost:8080/api/documents';
  }

  static String get alertsApiUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/alerts';
    }
    return 'http://localhost:8080/api/alerts';
  }
}

