import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutApp extends StatelessWidget {
  TextSpan buildTextSpan() {
    return TextSpan(children: [
      TextSpan(text: 'Tsacdop\n', style: TextStyle(fontSize: 20)),
      TextSpan(
          text:
              'Tsacdop is a podcast client developed by flutter, is a simple, easy-use player.\n'),
      TextSpan(text: 'Github https://github.com/stonga/tsacdop .\n'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
       statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor, 
      ),
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Tsacdop'),
              centerTitle: true,
            ),
            body: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.topLeft,
              child: Text.rich(buildTextSpan()),
            )),
      ),
    );
  }
}
