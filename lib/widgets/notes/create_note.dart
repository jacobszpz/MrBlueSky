import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoteWriter extends StatefulWidget {
  const NoteWriter({Key? key}) : super(key: key);

  @override
  State<NoteWriter> createState() => _NoteWriterState();
}

class _NoteWriterState extends State<NoteWriter> {
  void clear(String value) {
    log('no way dude');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: <Widget>[
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
                maxLines: 1,
                maxLength: 64,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "Write a title...",
                ),
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline4?.fontSize),
              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.only(top: 15),
                    child: TextFormField(
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
        )));
  }
}

Route createNoteWriterRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const NoteWriter(),
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
