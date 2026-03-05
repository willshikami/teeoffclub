// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:teeoffclub/main.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TeeOffClubApp());

    // Verify that our home screen text exists.
    expect(find.text('Hello, Golfer!'), findsOneWidget);
    expect(find.text('What are we going\nto do today?'), findsOneWidget);
  });
}
