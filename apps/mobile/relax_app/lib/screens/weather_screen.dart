import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/weather_chart.dart';

/// Màn thời tiết: gọi /weather/me/current + /weather/me/forecast. Tách hai
/// call để nếu forecast lỗi thì current vẫn hiện (rút kinh nghiệm từ bug
/// nuốt lỗi bên web).
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _current;
  List<Map<String, dynamic>> _forecast = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/weather/me/current'),
        RelaxApi.instance
            .get('/weather/me/forecast', query: {'forecastDays': 7}),
      ]);
      _current =
          results[0].data is Map ? Map<String, dynamic>.from(results[0].data) : null;
      final fc = results[1].data is Map ? results[1].data['forecast'] : null;
      _forecast = (fc is List)
          ? fc.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cur = _current?['current'] as Map?;
    final loc = _current?['location'] as Map?;
    final temp = (cur?['temperature'] as num?)?.round();
    final feels = (cur?['apparentTemperature'] as num?)?.round();
    final humidity = (cur?['humidity'] as num?)?.round();
    final wind = (cur?['windSpeed'] as num?)?.round();
    final locName = loc?['name'] as String?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Thời tiết',
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : RefreshIndicator(
                color: RelaxColors.violet,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RelaxColors.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: RelaxColors.coral),
                        ),
                        child: Text(
                          'Không tải được thời tiết: $_error',
                          style: const TextStyle(
                              color: RelaxColors.coral, fontSize: 12),
                        ),
                      ),
                    // Current hero
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [RelaxColors.violet, RelaxColors.plum],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (locName != null)
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  locName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Text(
                            temp != null ? '$temp°' : '—',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (feels != null)
                            Text(
                              'Cảm giác như $feels°',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.water_drop_outlined,
                            label: 'Độ ẩm',
                            value: humidity != null ? '$humidity%' : '—',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.air,
                            label: 'Gió',
                            value: wind != null ? '$wind km/h' : '—',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    WeatherForecastChart(forecast: _forecast),
                    const SizedBox(height: 24),
                    const Text(
                      'Dự báo 7 ngày',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (_forecast.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Chưa có dữ liệu dự báo.',
                          style: TextStyle(color: RelaxColors.slate),
                        ),
                      )
                    else
                      ..._forecast.map(_buildDay),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDay(Map<String, dynamic> d) {
    final date = (d['date'] as String?) ?? '';
    final max = (d['temperatureMax'] as num?)?.round();
    final min = (d['temperatureMin'] as num?)?.round();
    final rain = (d['precipitationProbability'] as num?)?.round();
    final title = (d['title'] as String?) ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.appText,
                ),
              ),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(
                      color: RelaxColors.slate, fontSize: 11),
                ),
            ],
          ),
          const Spacer(),
          if (rain != null) ...[
            const Icon(Icons.water_drop, size: 14, color: RelaxColors.violet),
            const SizedBox(width: 2),
            Text(
              '$rain%',
              style: const TextStyle(
                color: RelaxColors.violet,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 14),
          ],
          Text(
            '${min ?? '—'}° / ${max ?? '—'}°',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RelaxColors.violet, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: RelaxColors.slate, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: context.appText,
            ),
          ),
        ],
      ),
    );
  }
}
