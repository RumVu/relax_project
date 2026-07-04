import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import 'widgets/location_kv_row.dart';
import 'widgets/location_why_card.dart';

// Cho phep user chia se vi tri GPS de app goi y thoi tiet / phong tap / quan
// ca phe phu hop. Vi tri duoc luu vao preferences tren backend.
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _pos;
  String _status = 'Đang tải…';
  bool _loading = false;
  bool _saving = false;
  String? _address;
  bool _geocoding = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    // Tu dong cap nhat vi tri moi 5 phut.
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) _grabAndSave();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Load vi tri da luu tu backend khi vao man hinh.
  Future<void> _loadSavedLocation() async {
    try {
      final res = await RelaxApi.instance.get('/user-preferences/me/preferences');
      if (!mounted) return;
      final data = res.data;
      if (data is Map) {
        final lat = data['latitude'];
        final lng = data['longitude'];
        final name = data['locationName'];
        if (lat is num && lng is num) {
          setState(() {
            _pos = Position(
              latitude: lat.toDouble(),
              longitude: lng.toDouble(),
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
            _address = name is String ? name : null;
            _status = 'Đã lấy vị trí thành công';
          });
        } else {
          setState(() => _status = 'Chưa lấy vị trí');
        }
      } else {
        setState(() => _status = 'Chưa lấy vị trí');
      }
    } catch (_) {
      if (mounted) setState(() => _status = 'Chưa lấy vị trí');
    }
  }

  Future<void> _grab() async {
    setState(() {
      _loading = true;
      _status = 'Đang lấy vị trí…';
      _address = null;
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _status = 'Hãy bật dịch vụ định vị trên thiết bị');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _status = 'Quyền truy cập vị trí bị từ chối');
        return;
      }
      final p = await Geolocator.getCurrentPosition();
      setState(() {
        _pos = p;
        _status = 'Đã lấy vị trí thành công';
      });
      // Reverse geocode ngay sau khi co toa do.
      _reverseGeocode(p.latitude, p.longitude);
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        setState(() => _status =
            'Lỗi: MissingPluginException. Vui lòng chạy "flutter clean && flutter pub get" và rebuild native project.');
      } else {
        setState(() => _status = 'Lỗi: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Lay vi tri moi va tu dong luu len backend (dung cho auto-refresh 5p).
  Future<void> _grabAndSave() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final p = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _pos = p;
        _status = 'Đã lấy vị trí thành công';
      });
      _reverseGeocode(p.latitude, p.longitude);
      // Doi geocode xong roi luu.
      await Future.delayed(const Duration(seconds: 2));
      await _saveToBackend(p.latitude, p.longitude, _address);
    } catch (_) {
      // Silent fail cho auto-refresh.
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _geocoding = true);
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final pm = placemarks.first;
        final parts = <String>[
          if (pm.street != null && pm.street!.isNotEmpty) pm.street!,
          if (pm.subLocality != null && pm.subLocality!.isNotEmpty)
            pm.subLocality!,
          if (pm.locality != null && pm.locality!.isNotEmpty) pm.locality!,
          if (pm.administrativeArea != null &&
              pm.administrativeArea!.isNotEmpty)
            pm.administrativeArea!,
          if (pm.country != null && pm.country!.isNotEmpty) pm.country!,
        ];
        setState(() => _address = parts.join(', '));
      }
    } catch (_) {
      // Geocoding fail thi chi hien toa do, khong sao.
      if (mounted) setState(() => _address = null);
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _saveToBackend(double lat, double lng, String? address) async {
    await RelaxApi.instance.patch('/user-preferences/me/preferences', body: {
      'latitude': lat,
      'longitude': lng,
      // ignore: use_null_aware_elements
      if (address != null) 'locationName': address,
    });
  }

  Future<void> _save() async {
    final p = _pos;
    if (p == null) return;
    setState(() => _saving = true);
    try {
      await _saveToBackend(p.latitude, p.longitude, _address);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Đã lưu vị trí của bạn 💜'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.t('Không lưu được:')} $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pos;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(context.t('Vị trí của bạn'),
            style:
                TextStyle(color: context.appText, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LocationWhyCard(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.fieldBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t('Trạng thái'),
                        style: TextStyle(
                            color: context.mutedText, fontSize: 12)),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (ctx) {
                        String displayStatus;
                        if (_status.startsWith('Lỗi: ')) {
                          displayStatus =
                              '${ctx.t('Lỗi:')} ${_status.substring(5)}';
                        } else {
                          displayStatus = ctx.t(_status);
                        }
                        return Text(
                          displayStatus,
                          style: TextStyle(
                            color: context.appText,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    if (p != null) ...[
                      const SizedBox(height: 12),
                      LocationKvRow(
                          label: 'Vĩ độ',
                          value: p.latitude.toStringAsFixed(5)),
                      LocationKvRow(
                          label: 'Kinh độ',
                          value: p.longitude.toStringAsFixed(5)),
                      if (p.accuracy > 0)
                        LocationKvRow(
                            label: 'Độ chính xác',
                            value: '${p.accuracy.toStringAsFixed(0)} m'),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: context.fieldBorder),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.place,
                              color: RelaxColors.violet, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t('Địa chỉ hiện tại'),
                                  style: TextStyle(
                                    color: context.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (_geocoding)
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: RelaxColors.violet,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.t('Đang xác định địa chỉ…'),
                                        style: TextStyle(
                                          color: context.mutedText,
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    _address ??
                                        context.t(
                                            'Không xác định được địa chỉ'),
                                    style: TextStyle(
                                      color: _address != null
                                          ? context.appText
                                          : context.mutedText,
                                      fontWeight: _address != null
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _grab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(context.t('Lấy vị trí hiện tại'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: (p == null || _saving) ? null : _save,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.appText,
                  side: BorderSide(color: context.fieldBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.t('Lưu vào hồ sơ'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
