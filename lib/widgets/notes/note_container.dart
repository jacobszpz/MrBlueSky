import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/note.dart';

class NoteContainer extends StatefulWidget {
  const NoteContainer({Key? key, required this.note}) : super(key: key);
  final Note note;

  @override
  State<NoteContainer> createState() => _NoteContainerState();
}

class _NoteContainerState extends State<NoteContainer> {
  Note _note = Note.empty();

  @override
  Widget build(BuildContext context) {
    _note = widget.note;
    return Dismissible(
      key: ValueKey("a"),
      background: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.black,
          child: Row(
            children: const <Widget>[
              Icon(Icons.delete, color: Colors.white),
              Spacer(),
              Icon(Icons.delete, color: Colors.white)
            ],
          )),
      child: ListTile(
        onTap: () {},
        title: Text(_note.title),
        subtitle: Text(
          "2022-02-02",
          textAlign: TextAlign.right,
        ),
        leading: Icon(_note.icon),
      ),
      onDismissed: (DismissDirection direction) {
        setState(() {});
      },
    );
  }
}
