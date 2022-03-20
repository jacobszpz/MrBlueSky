import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key, required this.title}) : super(key: key);
  final String title;
  static const String author = 'Jacob Sánchez';
  static const String url = 'https://github.com/jacobszpz/MrBlueSky';

  _launchGitHubRepository() async {
    try {
      await launch(url);
    } catch (error) {
      // Error
    }
  }

  @override
  Widget build(BuildContext context) {
    var headline6 = Theme.of(context).textTheme.headline6;

    return Scaffold(
      appBar: AppBar(title: Text('About $title')),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/sunny.png',
            width: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: headline6,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('An air quality and weather monitoring app'),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text('by $author'),
          ),
          OutlinedButton(
              onPressed: _launchGitHubRepository,
              child: const Text('View at GitHub'))
        ],
      )),
    );
  }
}
