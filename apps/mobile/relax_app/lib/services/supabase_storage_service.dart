part of 'package:relax_app/main.dart';

/// Upload ảnh / file trực tiếp lên Supabase Storage (avatar, journal media)
/// dùng anon key.
///
/// Lưu ý: ở client em **chỉ** dùng anon key + bucket public hoặc bucket có
/// policy cho phép insert qua role 'authenticated'. KHÔNG nhúng service_role
/// key vào app — backend giữ key đó.
///
/// Endpoint chuẩn: `POST {SUPABASE_URL}/storage/v1/object/{bucket}/{path}`.
class SupabaseStorageService {
  SupabaseStorageService({
    http.Client? client,
    String? supabaseUrl,
    String? anonKey,
  })  : _client = client ?? http.Client(),
        _supabaseUrl = supabaseUrl ?? Env.supabaseUrl,
        _anonKey = anonKey ?? Env.supabaseAnonKey;

  final http.Client _client;
  final String _supabaseUrl;
  final String _anonKey;

  bool get configured => _supabaseUrl.isNotEmpty && _anonKey.isNotEmpty;

  /// Upload `bytes` vào `{bucket}/{path}` và trả về public URL.
  /// Throws nếu Env chưa cấu hình hoặc Supabase trả lỗi.
  ///
  /// `upsert = true` cho phép ghi đè nếu path đã tồn tại — tiện cho avatar.
  Future<String> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
    String? userAccessToken,
    bool upsert = true,
  }) async {
    if (!configured) {
      throw const ApiException(
        'Supabase chưa được cấu hình. Truyền --dart-define=SUPABASE_URL và '
        'SUPABASE_ANON_KEY khi build.',
      );
    }
    final uri = Uri.parse('$_supabaseUrl/storage/v1/object/$bucket/$path');
    // Khi user đã login, gắn thêm Authorization để Supabase RLS thấy là
    // role 'authenticated'. Nếu chưa, vẫn dùng anon (bucket public).
    final headers = <String, String>{
      'apikey': _anonKey,
      'Authorization': 'Bearer ${userAccessToken ?? _anonKey}',
      'Content-Type': contentType,
      'x-upsert': upsert ? 'true' : 'false',
    };
    final res = await _client.post(uri, headers: headers, body: bytes);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'Supabase upload thất bại (${res.statusCode}): ${res.body}',
      );
    }
    // Trả URL public — chỉ đúng với bucket public. Với bucket private,
    // caller phải dùng signed URL endpoint.
    return '$_supabaseUrl/storage/v1/object/public/$bucket/$path';
  }
}
