import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 20);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<dynamic> get(String path) async {
    final res = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}$path'))
        .timeout(_timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final dynamic decoded =
        res.body.isEmpty ? <String, dynamic>{} : jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 400) {
      throw ApiException(_errorMessage(decoded, res.statusCode), res.statusCode);
    }
    return decoded;
  }

  /// Backend memakai tiga bentuk `detail`:
  ///  - String            (auth: "Email atau kata sandi salah")
  ///  - {code, message}   (/fl/*: "Ronde berjalan = 5")
  ///  - List of {msg,...} (422 validasi FastAPI/pydantic)
  static String _errorMessage(dynamic decoded, int status) {
    final detail = decoded is Map ? decoded['detail'] : null;
    if (detail is String) return detail;
    if (detail is Map) {
      return (detail['message'] ?? detail['code'] ?? 'Permintaan gagal ($status)')
          .toString();
    }
    if (detail is List && detail.isNotEmpty) {
      return detail.map((e) {
        if (e is Map) {
          final loc = e['loc'];
          final field = loc is List && loc.isNotEmpty ? '${loc.last}: ' : '';
          return '$field${e['msg'] ?? e}';
        }
        return e.toString();
      }).join('; ');
    }
    return 'Permintaan gagal ($status)';
  }
}

final apiClient = ApiClient();
