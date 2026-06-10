import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/locale_controller.dart';
import '../core/theme.dart';

/// Hiển thị thông tin thiết bị (model, OS, version) và phiên bản app — dùng
/// khi user cần báo lỗi cho support.
class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final _rows = <(String, String)>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        _rows
          ..add(('Hệ điều hành', 'Android ${a.version.release}'))
          ..add(('Model', '${a.brand} ${a.model}'))
          ..add(('Mã thiết bị', a.id))
          ..add(('Nhà sản xuất', a.manufacturer))
          ..add(('SDK', a.version.sdkInt.toString()));
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        _rows
          ..add(('Hệ điều hành', '${i.systemName} ${i.systemVersion}'))
          ..add(('Model', i.utsname.machine))
          ..add(('Tên thiết bị', i.name))
          ..add(('Nhà sản xuất', 'Apple'));
      } else {
        _rows.add(('Hệ điều hành', Platform.operatingSystem));
      }
      _rows.add(('Phiên bản app', '1.0.0 (build 1)'));
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        _rows.add(('Lỗi', 'MissingPluginException. Vui lòng chạy "flutter clean && flutter pub get" và rebuild native project.'));
      } else {
        _rows.add(('Lỗi', e.toString()));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Thông tin thiết bị'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.fieldBorder),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _rows.length; i++) ...[
                          if (i > 0)
                            Divider(
                                height: 0,
                                color: context.fieldBorder,
                                indent: 16,
                                endIndent: 16),
                          ListTile(
                            title: Text(context.t(_rows[i].$1),
                                style: TextStyle(
                                    color: context.mutedText, fontSize: 12)),
                            subtitle: Text(context.t(_rows[i].$2),
                                style: TextStyle(
                                    color: context.appText,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t('Khi cần báo lỗi, hãy gửi kèm thông tin này để bộ phận hỗ trợ chẩn đoán nhanh hơn nha 💜'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.mutedText, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
