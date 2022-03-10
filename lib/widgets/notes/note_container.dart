import 'package:flutter/material.dart';

class NoteContainer extends StatefulWidget {
  const NoteContainer({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<NoteContainer> createState() => _NoteContainerState();
}

class _NoteContainerState extends State<NoteContainer> {
  @override
  Widget build(BuildContext context) {
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
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 80,
        child: Row(
          children: <Widget>[
            Icon(Icons.wb_cloudy),
            Spacer(),
            Flexible(
              child: Column(
                children: const <Widget>[
                  Text("This is an observation"),
                  Spacer(),
                  Text("2022-09-01", textAlign: TextAlign.right),
                ],
              ),
            ),
          ],
        ),
      ),
      onDismissed: (DismissDirection direction) {
        setState(() {});
      },
    );
  }
}
