import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke renders text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Laras Test')),
      ),
    );

    expect(find.text('Laras Test'), findsOneWidget);
  });
}
