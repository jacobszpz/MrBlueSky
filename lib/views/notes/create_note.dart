import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:share_plus/share_plus.dart';

class NoteWriter extends StatefulWidget {
  const NoteWriter({Key? key, required this.note, this.urlGetter})
      : super(key: key);
  final Note note;
  final Function()? urlGetter;
  @override
  State<NoteWriter> createState() => _NoteWriterState();
}

class _NoteWriterState extends State<NoteWriter> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  Uint8List? noteImage;

  // Desperation :/
  // Could not reach provider from here for some reason
  final _storage = FirebaseStorage.instance;
  static const usersBucketPath = 'users';
  static const attachmentsPath = 'attachments';

  User? firebaseUser;

  Reference _userFolderRef(String userUID) {
    return _storage.ref(usersBucketPath).child(userUID).child(attachmentsPath);
  }

  Future<String> getImageURL(String uuid) async {
    String url = '';
    final user = firebaseUser;

    if (user != null) {
      try {
        url =
            await _userFolderRef(user.uid).child('$uuid.jpg').getDownloadURL();
      } on FirebaseException catch (e) {
        // No good
      }
    }

    return url;
  }

  @override
  initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;

    FirebaseAuth.instance.authStateChanges().listen((userStream) {
      firebaseUser = userStream;
    });
  }

  void clear(String value) {
    titleController.clear();
    contentController.clear();

    setState(() {
      noteImage = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  _chooseImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (image != null) {
      GallerySaver.saveImage(image.path);
      var imageBytes = await image.readAsBytes();
      setState(() {
        noteImage = imageBytes;
      });
    }
  }

  Future _showNoteImage() async {
    final imageBytes = noteImage;
    Widget imgWidget = const Placeholder();
    bool showImg = false;

    if (imageBytes != null) {
      imgWidget = Image.memory(imageBytes);
      showImg = true;
    } else if (widget.note.hasCloudCopy) {
      String imgURL = await getImageURL(widget.note.uuid);

      if (imgURL.isNotEmpty) {
        imgWidget = Image.network(imgURL);
        showImg = true;
      }
    }

    if (showImg) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: imgWidget,
                  ))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _noteImage = noteImage;

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
                  widget.note.uuid,
                  noteImage,
                  widget.note.hasCloudCopy));
          return false;
        },
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: _chooseImage,
              child: const Icon(Icons.image),
            ),
            appBar: AppBar(actions: <Widget>[
              if (_noteImage != null || widget.note.hasCloudCopy)
                IconButton(
                    onPressed: _showNoteImage,
                    icon: const Icon(Icons.attachment)),
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
