import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

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
                padding: EdgeInsets.all(100),
              ),
              Container(
                  height: 400,
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
