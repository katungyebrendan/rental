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
  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Inbox').first);
    await tester.pumpAndSettle();
    expect(find.text('Chats'), findsOneWidget);

    await tester.tap(find.text('Activity').first);
    await tester.pumpAndSettle();
    expect(find.text('No saved properties yet'), findsOneWidget);

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);

    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(find.text('HomeSet'), findsWidgets);
  });

  testWidgets('Add tab opens property flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(find.text('Add/Edit Property'), findsOneWidget);
  });
}
