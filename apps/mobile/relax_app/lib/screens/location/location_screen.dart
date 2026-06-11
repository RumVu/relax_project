import 'package:flutter/material.dart';
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
  String _status = 'Chưa lấy vị trí';
  bool _loading = false;
  bool _saving = false;

  Future<void> _grab() async {
    setState(() {
      _loading = true;
      _status = 'Đang lấy vị trí…';
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

  Future<void> _save() async {
    final p = _pos;
    if (p == null) return;
    setState(() => _saving = true);
    try {
      await RelaxApi.instance.patch('/users/me/preferences', body: {
        'location': {
          'lat': p.latitude,
          'lng': p.longitude,
          'accuracyM': p.accuracy,
        },
      });
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
                      LocationKvRow(
                          label: 'Độ chính xác',
                          value: '${p.accuracy.toStringAsFixed(0)} m'),
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
