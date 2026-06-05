import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:relax_app/main.dart';

void main() {
  testWidgets('shows splash, onboarding and login flow copy', (tester) async {
    await tester.pumpWidget(
      const RelaxApp(
        catalogRepository: StaticRelaxCatalogRepository([]),
        contentRepository: StaticMobileContentRepository(
          MobileContentSnapshot(),
        ),
      ),
    );

    expect(find.text('Thi Ai Chill'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('chào mừng trở lại, \${user_name}'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng kí'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('welcome back, \${user_name}'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    final loginButton = find.widgetWithText(FilledButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng quay lại ~'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
  });
}
