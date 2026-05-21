import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/main.dart';

void main() {
  testWidgets('App Boots Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame inside ProviderScope.
    await tester.pumpWidget(
      const ProviderScope(
        child: AuraStudyApp(),
      ),
    );

    // Verify splash screen rendering starts successfully
    expect(find.byType(AuraStudyApp), findsOneWidget);

    // Pump a short duration to let initial frames draw
    await tester.pump(const Duration(milliseconds: 100));

    // Force disposal of the widget tree to clean up active timers and tickers
    await tester.pumpWidget(const SizedBox());
  });
}
