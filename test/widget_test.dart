// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:watcho/main.dart';
import 'package:watcho/core/handlers/deep_link_handler.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Create a mock deep link handler for testing
    final deepLinkHandler = DeepLinkHandler();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(deepLinkHandler: deepLinkHandler));

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
