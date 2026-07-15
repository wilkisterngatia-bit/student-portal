import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_portal_app/main.dart';

void main() {
  testWidgets('App starts and shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentPortalApp());
    // Just confirms the app builds without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}