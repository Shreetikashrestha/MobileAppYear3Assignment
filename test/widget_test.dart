import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/app.dart';

void main() {
  testWidgets('MyApp should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for all pending timers to complete (splash screen has 2 second delay)
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
