part of 'package:relax_app/main.dart';

class BackendConfig {
  const BackendConfig._();

  static const defaultBaseUrl = String.fromEnvironment(
    'RELAX_API_URL',
    defaultValue: 'https://relax-backend.tail3e0c74.ts.net/v1',
  );
}

class ApiClient {
  ApiClient({
    http.Client? client,
    String baseUrl = BackendConfig.defaultBaseUrl,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl;

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<Object?> getJson(String path) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? path : '/$path'}');
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Backend trả ${response.statusCode} khi gọi ${uri.path}',
      );
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Object?;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
