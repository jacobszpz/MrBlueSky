import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/models/weather_type.dart';

import 'note_container.dart';

class NoteTab extends StatefulWidget {
  const NoteTab({Key? key}) : super(key: key);

  @override
  State<NoteTab> createState() => _NoteTabState();
}

class _NoteTabState extends State<NoteTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: <Widget>[
        NoteContainer(
            note: Note("This is my first observation", "Here's some content",
                WeatherType.clearSkyDay)),
        NoteContainer(
            note: Note("This is my second one", "Here's some content",
                WeatherType.clearSkyNight)),
        NoteContainer(
            note: Note("And maybe, this will be the third",
                "Here's some content", WeatherType.brokenClouds))
      ],
    );
  }
}

/* _notes.isNotEmpty
              ? ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notes.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: Center(child: Text('Entry')),
                );
              }
              ) : const Center(child: Text("Try adding a note :)")),*/
