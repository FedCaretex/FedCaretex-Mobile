import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Chrome Web -> localhost, Android emulator -> 10.0.2.2
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000',
  );
}
