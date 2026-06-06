import '../../core/api_client.dart';

/// Update profile thật qua PATCH /v1/users/me.
/// Backend chấp nhận các field: name, phone, gender, avatar, birthYear, socialUrl.
class UsersService {
  UsersService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<Map<String, dynamic>> updateMe({
    required String accessToken,
    String? name,
    String? phone,
    String? gender,
    String? socialUrl,
    String? avatar,
    int? birthYear,
  }) async {
    final payload = <String, Object?>{};
    if (name != null && name.isNotEmpty) payload['name'] = name;
    if (phone != null) payload['phone'] = phone;
    if (gender != null && gender.isNotEmpty) payload['gender'] = gender;
    if (socialUrl != null) payload['socialUrl'] = socialUrl;
    if (avatar != null && avatar.isNotEmpty) payload['avatar'] = avatar;
    if (birthYear != null) payload['birthYear'] = birthYear;

    final body = await _client.patchJson(
      '/users/me',
      payload,
      accessToken: accessToken,
    );
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    throw const ApiException('Backend không trả profile sau khi cập nhật.');
  }

  /// Xóa tài khoản vĩnh viễn.
  Future<void> deleteMe({required String accessToken}) async {
    await _client.delete('/users/me', accessToken: accessToken);
  }
}
