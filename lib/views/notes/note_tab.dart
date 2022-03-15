import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/note.dart';

import 'note_container.dart';

class NoteTab extends StatefulWidget {
  const NoteTab({Key? key, required this.notes, this.onTap, this.onDismissed})
      : super(key: key);
  final List<Note> notes;
  final Function(int index)? onTap;
  final Function(int index)? onDismissed;

  @override
  State<NoteTab> createState() => _NoteTabState();
}

class _NoteTabState extends State<NoteTab> {
  List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    notes = widget.notes;

    return notes.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              Note note = notes.elementAt(index);
              return NoteContainer(
                note: Note.fromExisting(note.title, note.content, note.weather,
                    note.editTimestamp, note.creationTimestamp, note.uuid),
                onTap: () {
                  widget.onTap!(index);
                },
                onDismissed: () {
                  setState(() {
                    widget.onDismissed!(index);
                  });
                },
              );
            })
        : const Center(child: Text("Try adding a note :)"));
  }
}
