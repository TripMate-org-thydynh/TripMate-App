// This is a basic Flutter widget test for TripMate.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tripmate/main.dart';

void main() {
  testWidgets('TripMate smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our welcome message is displayed.
    expect(find.text('Hey Wanderer,'), findsOneWidget);
    expect(find.text('Explore the World'), findsOneWidget);

    // Verify the bottom navigation bar is present.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
