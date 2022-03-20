import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';
import 'package:mr_blue_sky/views/appbar.dart';

void main() {
  testWidgets('AppBar title', (WidgetTester tester) async {
    var appTitle = 'My App Title';
    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: const [Text(''), Text(''), Text('')]),
            appBar: MyAppBar(
              title: appTitle,
              tabController: tabController,
            ))));

    expect(find.text(appTitle), findsOneWidget);
  });

  testWidgets('AppBar tab titles', (WidgetTester tester) async {
    var weatherTabTitle = 'WEATHER';
    var citiesTabTitle = 'MY CITIES';
    var notesTabTitle = 'MY NOTES';

    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: const [Text(''), Text(''), Text('')]),
            appBar: MyAppBar(
              title: '',
              tabController: tabController,
            ))));

    expect(find.text(weatherTabTitle), findsOneWidget);
    expect(find.text(citiesTabTitle), findsOneWidget);
    expect(find.text(notesTabTitle), findsOneWidget);
  });

  testWidgets('AppBar onSearch callback', (WidgetTester tester) async {
    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());
    final completer = Completer<void>();

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: const [Text(''), Text(''), Text('')]),
            appBar: MyAppBar(
              onSearch: () {
                completer.complete();
              },
              title: '',
              tabController: tabController,
            ))));

    await tester.tap(find.byIcon(Icons.search));
    expect(completer.isCompleted, isTrue);
  });

  testWidgets('AppBar no sort menu on first tab', (WidgetTester tester) async {
    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: const [Text(''), Text(''), Text('')]),
            appBar: MyAppBar(
              title: '',
              tabController: tabController,
            ))));

    await tester.tap(find.byType(PopupMenuButton<SortingOrder>));
    await tester.pumpAndSettle();
    expect(find.text('Alphabetically'), findsNothing);
  });

  testWidgets('AppBar first tab contents', (WidgetTester tester) async {
    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());
    var firstTab = 'FIRST';
    var secondTab = 'SECOND';
    var thirdTab = 'THIRD';

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: [Text(firstTab), Text(secondTab), Text(thirdTab)]),
            appBar: MyAppBar(
              title: '',
              tabController: tabController,
            ))));

    expect(find.text(firstTab), findsOneWidget);
    expect(find.text(secondTab), findsNothing);
    expect(find.text(thirdTab), findsNothing);
  });

  testWidgets('AppBar second tab contents', (WidgetTester tester) async {
    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());
    var firstTab = 'FIRST';
    var secondTab = 'SECOND';
    var thirdTab = 'THIRD';

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: [Text(firstTab), Text(secondTab), Text(thirdTab)]),
            appBar: MyAppBar(
              title: '',
              tabController: tabController,
            ))));

    await tester.tap(find.text('MY CITIES'));
    await tester.pumpAndSettle();
    expect(find.text(firstTab), findsNothing);
    expect(find.text(secondTab), findsOneWidget);
    expect(find.text(thirdTab), findsNothing);
  });

  testWidgets('AppBar third tab contents', (WidgetTester tester) async {
    TabController tabController =
        TabController(length: 3, vsync: const TestVSync());
    var firstTab = 'FIRST';
    var secondTab = 'SECOND';
    var thirdTab = 'THIRD';

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TabBarView(
                controller: tabController,
                children: [Text(firstTab), Text(secondTab), Text(thirdTab)]),
            appBar: MyAppBar(
              title: '',
              tabController: tabController,
            ))));
    await tester.tap(find.text('MY NOTES'));
    await tester.pumpAndSettle();
    expect(find.text(firstTab), findsNothing);
    expect(find.text(secondTab), findsNothing);
    expect(find.text(thirdTab), findsOneWidget);
  });
}
