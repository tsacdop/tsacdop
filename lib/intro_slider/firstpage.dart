import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../util/extension_helper.dart';

class FirstPage extends StatefulWidget {
  FirstPage({Key key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(35, 204, 198, 1),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
              ),
              Container(
                  height: context.width * 3 / 4,
                  // color: Colors.red,
                  child: FlareActor(
                    'assets/splash.flr',
                    alignment: Alignment.center,
                    animation: 'logo',
                    fit: BoxFit.cover,
                  )),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
