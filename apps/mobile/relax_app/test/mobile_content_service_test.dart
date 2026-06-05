import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:relax_app/main.dart';

void main() {
  test('loads public mobile content snapshot from backend endpoints', () async {
    final client = MockClient((request) async {
      final path = request.url.path;
      final query = request.url.query;
      final body = switch ('$path?$query') {
        '/v1/mood-checkins/options?' => [
          {
            'mood': 'HAPPY',
            'label': 'Vui vẻ',
            'description': 'Năng lượng sáng.',
            'companionLine': 'Giữ mood này nha.',
            'recommendedActions': ['JOURNAL', 'MUSIC'],
          },
        ],
        '/v1/cozy-quotes/random?' => {
          'content': 'Hít thở thêm một nhịp nữa nha.',
          'mood': 'CALM',
        },
        '/v1/companion-messages/random?' => {
          'content': 'Tạm dừng là nút save game của cơ thể.',
          'companionMood': 'CHILL',
        },
        '/v1/companion-assets/default?' => {
          'name': 'Chinese Zodiac Lucky Pig',
          'description': 'Linh thú cá nhân hoá.',
          'previewImageUrl': 'https://cdn.example.test/pig.png',
        },
        '/v1/app-themes/default?' => {
          'name': 'Night Train Soft',
          'mode': 'DARK',
          'primaryColor': '#9CC9FF',
          'accentColor': '#F4B860',
        },
        '/v1/breathing-exercises?limit=8' => {
          'items': [
            {
              'title': 'Thở 4-4-4',
              'description': 'Bài thở đều.',
              'inhaleSeconds': 4,
              'holdSeconds': 4,
              'exhaleSeconds': 4,
              'cycles': 10,
              'duration': 120,
            },
          ],
        },
        '/v1/billing/plans?' => [
          {
            'name': 'CHILL_PLUS',
            'title': 'Chill Plus',
            'description': 'Gói mở rộng.',
            'effectivePrice': 49000,
            'currency': 'VND',
            'billingCycle': 'MONTHLY',
          },
        ],
        _ => throw StateError('Unexpected path: ${request.url}'),
      };

      return http.Response(
        jsonEncode(body),
        200,
        headers: const {'content-type': 'application/json'},
      );
    });

    final service = MobileContentService(
      apiClient: ApiClient(client: client, baseUrl: 'https://example.test/v1'),
    );

    final snapshot = await service.fetchSnapshot();

    expect(snapshot.loadedSections, 7);
    expect(snapshot.moodOptions.single.label, 'Vui vẻ');
    expect(snapshot.quote?.content, contains('Hít thở'));
    expect(snapshot.companionAsset?.name, 'Chinese Zodiac Lucky Pig');
    expect(snapshot.appTheme?.name, 'Night Train Soft');
    expect(snapshot.breathingExercises.single.patternLabel, '4-4-4');
    expect(snapshot.billingPlans.single.priceLabel, '49k VND/tháng');
  });
}
