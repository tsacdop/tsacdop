import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  TextSpan buildTextSpan() {
    return TextSpan(children: [
      TextSpan(text: 'Tsacdop\n',style: TextStyle(fontSize: 20)),
      TextSpan(
          text:
              'Tsacdop is a podcast client developed by flutter, is a simple, easy-use player.\n'),
      TextSpan(
          text:
              'Github https://github.com/stonga/tsacdop .\n'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text('Tsacdop'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.topLeft,
          child: Text.rich(buildTextSpan()),
        ));
  }
}
