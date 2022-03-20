import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_blue_sky/views/fab.dart';

void main() {
  testWidgets('FAB Icons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
      floatingActionButton:
          MyFloatingActionButton(showShareIcon: false, showFab: true),
    )));

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.share), findsOneWidget);
  });

  testWidgets('FAB onTap', (WidgetTester tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      floatingActionButton: MyFloatingActionButton(
          showShareIcon: true,
          showFab: true,
          onFabPress: () {
            completer.complete();
          }),
    )));

    await tester.tap(find.byType(FloatingActionButton));
    expect(completer.isCompleted, isTrue);
  });
}
