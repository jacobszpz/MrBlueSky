import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:share_plus/share_plus.dart';

class NoteWriter extends StatefulWidget {
  const NoteWriter({Key? key, required this.note}) : super(key: key);
  final Note note;
  @override
  State<NoteWriter> createState() => _NoteWriterState();
}

class _NoteWriterState extends State<NoteWriter> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void clear(String value) {
    titleController.clear();
    contentController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;

    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(
              context,
              Note.fromExisting(
                  titleController.text,
                  contentController.text,
                  widget.note.weather,
                  DateTime.now(),
                  widget.note.creationTimestamp,
                  widget.note.uuid));
          return false;
        },
        child: Scaffold(
            appBar: AppBar(actions: <Widget>[
              IconButton(
                  onPressed: (() {
                    Share.share(
                        '${titleController.text}\n\n${contentController.text}');
                  }),
                  icon: const Icon(Icons.share)),
              PopupMenuButton<String>(
                  onSelected: clear,
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuItem<String>>[
                      const PopupMenuItem<String>(
                        value: 'Clear',
                        child: Text('Clear'),
                      )
                    ];
                  })
            ]),
            body: Form(
                child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: titleController,
                    maxLines: 1,
                    maxLength: 64,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: "Write a title...",
                    ),
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline4?.fontSize),
                  ),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.only(top: 15),
                        child: TextFormField(
                            controller: contentController,
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.fontSize),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: "Make an observation :)",
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ))),
                  ),
                ],
              ),
            ))));
  }
}

Route createNoteWriterRoute(Note note) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        NoteWriter(note: note),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCirc;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );
      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}
