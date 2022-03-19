import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/note.dart';

import 'note_container.dart';

class NoteTab extends StatelessWidget {
  const NoteTab({Key? key, required this.notes, this.onTap, this.onDismissed})
      : super(key: key);
  final List<Note> notes;
  final Function(int index)? onTap;
  final Function(int index)? onDismissed;

  @override
  Widget build(BuildContext context) {
    return notes.isNotEmpty
        ? ListView.separated(
            padding: const EdgeInsets.all(0),
            itemCount: notes.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 1,
                height: 1,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              Note note = notes.elementAt(index);
              return NoteContainer(
                note: Note.fromExisting(note.title, note.content, note.weather,
                    note.editTimestamp, note.creationTimestamp, note.uuid),
                onTap: () {
                  final _onTap = onTap;
                  if (_onTap != null) {
                    _onTap(index);
                  }
                },
                onDismissed: () {
                  final _onDismissed = onDismissed;
                  if (_onDismissed != null) {
                    _onDismissed(index);
                  }
                },
              );
            })
        : const Center(child: Text("Try adding a note :)"));
  }
}
