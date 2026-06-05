import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:relax_app/main.dart';

void main() {
  test('maps backend relax catalog and attached resources', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://example.test/v1/relax-activities',
      );
      return http.Response(
        jsonEncode([
          {
            'type': 'MUSIC',
            'title': 'Nhạc',
            'subtitle': 'Giai điệu nhẹ nhàng',
            'description': 'Nghe nhạc để dịu nhịp cảm xúc.',
            'defaultDurationMinutes': 25,
            'resources': [
              {
                'id': 'track-1',
                'title': 'A Blue Day',
                'category': 'CHILL',
                'soundUrl': 'https://cdn.example.test/a-blue-day.mp3',
                'duration': 200,
              },
            ],
          },
        ]),
        200,
        headers: const {'content-type': 'application/json'},
      );
    });

    final service = RelaxCatalogService(
      apiClient: ApiClient(client: client, baseUrl: 'https://example.test/v1'),
    );

    final activities = await service.fetchActivities();

    expect(activities, hasLength(1));
    expect(activities.single.type, 'MUSIC');
    expect(activities.single.resources, hasLength(1));
    expect(activities.single.resources.single.title, 'A Blue Day');
    expect(activities.single.resources.single.durationLabel, '3:20');
  });
}
