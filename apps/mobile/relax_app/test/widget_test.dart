import 'package:flutter_test/flutter_test.dart';

import 'package:relax_app/main.dart';

void main() {
  testWidgets('shows the Thi Ai onboarding flow', (tester) async {
    await tester.pumpWidget(const RelaxApp());

    expect(find.text('welcome back, \${user_name}'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng kí'), findsOneWidget);
  });
}
