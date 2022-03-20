import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/views/notes/note_tab.dart';

import 'note_tab_test.mocks.dart';

@GenerateMocks([DateTime, Note])
void main() {
  testWidgets('Note tab empty list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: NoteTab(
      notes: [],
    )));

    expect(find.text('Try adding a note :)'), findsOneWidget);
  });

  testWidgets('Note tab with single note', (WidgetTester tester) async {
    var title = 'Note title';
    var content = 'Note content';
    var uuid = 'unique';
    var weatherType = WeatherType.mist;
    var timeMsg = 'This is the message';
    var icon = Icons.android;

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);
    when(mockNote.uuid).thenReturn(uuid);
    when(mockNote.weather).thenReturn(weatherType);
    when(mockNote.timestampMessage).thenReturn(timeMsg);
    when(mockNote.creationTimestamp).thenReturn(MockDateTime());
    when(mockNote.editTimestamp).thenReturn(MockDateTime());
    when(mockNote.icon).thenReturn(icon);

    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NoteTab(notes: [mockNote]))));

    expect(find.text(title), findsOneWidget);
    expect(find.text(timeMsg), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
    expect(find.text(content), findsNothing);
  });

  testWidgets('Note tab onTap callback', (WidgetTester tester) async {
    var title = 'Note title';
    var content = 'Note content';
    var uuid = 'unique';
    var weatherType = WeatherType.mist;
    var timeMsg = 'This is the message';
    var icon = Icons.android;
    final completer = Completer<int>();

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);
    when(mockNote.uuid).thenReturn(uuid);
    when(mockNote.weather).thenReturn(weatherType);
    when(mockNote.timestampMessage).thenReturn(timeMsg);
    when(mockNote.creationTimestamp).thenReturn(MockDateTime());
    when(mockNote.editTimestamp).thenReturn(MockDateTime());
    when(mockNote.icon).thenReturn(icon);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: NoteTab(
      notes: [mockNote],
      onTap: ((int index) {
        completer.complete(index);
      }),
    ))));

    await tester.tap(find.text(title));
    expect(completer.isCompleted, isTrue);
  });

  testWidgets('Note tab onDismiss callback', (WidgetTester tester) async {
    var title = 'Note title';
    var content = 'Note content';
    var uuid = 'unique';
    var weatherType = WeatherType.mist;
    var timeMsg = 'This is the message';
    var icon = Icons.android;
    final completer = Completer<int>();

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);
    when(mockNote.uuid).thenReturn(uuid);
    when(mockNote.weather).thenReturn(weatherType);
    when(mockNote.timestampMessage).thenReturn(timeMsg);
    when(mockNote.creationTimestamp).thenReturn(MockDateTime());
    when(mockNote.editTimestamp).thenReturn(MockDateTime());
    when(mockNote.icon).thenReturn(icon);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: NoteTab(
      notes: [mockNote],
      onDismissed: ((int index) {
        completer.complete(index);
      }),
    ))));

    await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();
    expect(completer.isCompleted, isTrue);
  });
}
