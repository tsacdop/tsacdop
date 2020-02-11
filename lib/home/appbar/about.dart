import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  TextSpan buildTextSpan() {
    return TextSpan(children: [
      TextSpan(text: 'About Dopcast Player\n',style: TextStyle(fontSize: 20)),
      TextSpan(
          text:
              'Dopcast Player is a podcast client developed by flutter, is a simple, easy-use player.\n'),
      TextSpan(
          text:
              'Github https://github.com/stonga .\n'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text('About'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.topLeft,
          child: Text.rich(buildTextSpan()),
        ));
  }
}
