import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/note.dart';

class NoteContainer extends StatefulWidget {
  const NoteContainer(
      {Key? key, required this.note, this.onTap, this.onDismissed})
      : super(key: key);
  final Note note;
  final Function()? onTap;
  final Function()? onDismissed;

  @override
  State<NoteContainer> createState() => _NoteContainerState();
}

class _NoteContainerState extends State<NoteContainer> {
  Note _note = Note.empty();

  @override
  Widget build(BuildContext context) {
    _note = widget.note;
    return Dismissible(
      key: UniqueKey(),
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
        onTap: () {
          widget.onTap!();
        },
        title: Text(_note.title),
        subtitle: Text(
          _note.timestampMessage,
          textAlign: TextAlign.right,
        ),
        leading: Icon(_note.icon),
      ),
      onDismissed: (DismissDirection direction) {
        setState(() {
          widget.onDismissed!();
        });
      },
    );
  }
}
