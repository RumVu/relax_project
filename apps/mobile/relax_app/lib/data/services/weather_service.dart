import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Snapshot thời tiết hiện tại từ Open-Meteo.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperatureC,
    required this.code,
    required this.isDay,
    required this.locationLabel,
  });

  final double temperatureC;
  final int code;
  final bool isDay;
  final String locationLabel;

  /// Mô tả ngắn theo WMO weather code chuẩn.
  String get description {
    if (code == 0) return isDay ? 'Trời nắng đẹp ghê!' : 'Đêm trong, dễ ngủ ~';
    if (code == 1 || code == 2) {
      return isDay ? 'Nắng nhẹ, hơi mây xíu' : 'Đêm mát, đôi chỗ mây';
    }
    if (code == 3) return isDay ? 'Trời nhiều mây mát' : 'Đêm mây phủ êm dịu';
    if (code == 45 || code == 48) return 'Sương mù, đi cẩn thận nha';
    if (code >= 51 && code <= 57) return 'Mưa phùn nhẹ, mang theo áo khoác nha';
    if (code >= 61 && code <= 67) return 'Có mưa nhẹ ngoài kia';
    if (code >= 71 && code <= 77) return 'Có tuyết rơi';
    if (code >= 80 && code <= 82) return 'Mưa rào, nhớ che chắn nha';
    if (code >= 95 && code <= 99) return 'Có giông, ở trong nhà cho an toàn';
    return isDay ? 'Một ngày bình yên ✨' : 'Đêm yên tĩnh ✨';
  }
}

/// Lấy thời tiết hiện tại từ vị trí thiết bị, dùng Open-Meteo (miễn phí, no API key).
class WeatherService {
  WeatherService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Trả null nếu user từ chối location hoặc API lỗi (UI gracefully fallback).
  Future<WeatherSnapshot?> fetchCurrent() async {
    try {
      // 1) Xin quyền location
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      // 2) Lấy tọa độ (timeout 5s để không treo UI)
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // 3) Gọi Open-Meteo (no key)
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${pos.latitude}&longitude=${pos.longitude}'
        '&current=temperature_2m,weather_code,is_day'
        '&timezone=auto',
      );
      final res = await _http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final current = body['current'] as Map<String, dynamic>?;
      if (current == null) return null;

      return WeatherSnapshot(
        temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        code: (current['weather_code'] as num?)?.toInt() ?? 0,
        isDay: (current['is_day'] as num?)?.toInt() == 1,
        locationLabel: _formatCoord(pos.latitude, pos.longitude),
      );
    } catch (_) {
      return null;
    }
  }

  String _formatCoord(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°';
}
