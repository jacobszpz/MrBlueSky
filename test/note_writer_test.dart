import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/views/notes/create_note.dart';

import 'note_writer_test.mocks.dart';

@GenerateMocks([Note])
void main() {
  testWidgets('Note writer create', (WidgetTester tester) async {
    var title = 'Note title';
    var content = 'Note content';

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);

    await tester.pumpWidget(MaterialApp(
        home: NoteWriter(
      note: mockNote,
    )));

    expect(find.text(title), findsOneWidget);
    expect(find.text(content), findsOneWidget);
  });

  testWidgets('Note writer modify title', (WidgetTester tester) async {
    var title = 'Note title';
    var content = '';
    var newTitle = 'New title';

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);

    await tester.pumpWidget(MaterialApp(
        home: NoteWriter(
      note: mockNote,
    )));

    await tester.enterText(find.text(title), newTitle);
    expect(find.text(newTitle), findsOneWidget);
  });

  testWidgets('Note writer modify content', (WidgetTester tester) async {
    var title = '';
    var content = 'Note content';
    var newContent = 'New content';

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);

    await tester.pumpWidget(MaterialApp(
        home: NoteWriter(
      note: mockNote,
    )));

    await tester.enterText(find.text(content), newContent);
    expect(find.text(newContent), findsOneWidget);
  });

  testWidgets('Note writer clear', (WidgetTester tester) async {
    var title = 'Note title';
    var content = 'Note content';
    var clearButton = 'Clear';

    var mockNote = MockNote();
    when(mockNote.title).thenReturn(title);
    when(mockNote.content).thenReturn(content);

    await tester.pumpWidget(MaterialApp(
        home: NoteWriter(
      note: mockNote,
    )));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text(clearButton), findsOneWidget);

    await tester.tap(find.text(clearButton));
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);
    expect(find.text(content), findsNothing);
  });
}
