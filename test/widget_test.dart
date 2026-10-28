// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rentals_app/app.dart';

void main() {
  testWidgets('Guests can browse listings and account tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Ntinda, Kampala'), findsOneWidget);

    await tester.tap(find.text('Saved').first);
    await tester.pumpAndSettle();
    expect(find.text('Sign in to save properties to your account.'), findsOneWidget);

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(find.text('Your Profile'), findsOneWidget);
  });

  testWidgets('Add tab requires sign in and returns to guest browsing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Rentals'), findsOneWidget);
    expect(find.text('Add/Edit Property'), findsNothing);

    await tester.tap(find.text('Continue browsing as guest'));
    await tester.pumpAndSettle();

    expect(find.text('Ntinda, Kampala'), findsOneWidget);
  });
}
