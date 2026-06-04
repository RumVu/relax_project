import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:relax_app/main.dart';

void main() {
  testWidgets('app boots into the splash route', (tester) async {
    await tester.pumpWidget(const RelaxApp());
    // Splash → CircularProgressIndicator while AuthState bootstraps.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
