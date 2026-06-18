import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_card/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryCardApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
