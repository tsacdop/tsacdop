import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class SecondPage extends StatefulWidget {
  SecondPage({Key key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(77, 145, 190, 1),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              alignment: Alignment.center,
              padding: EdgeInsets.all(40),
              child: Text(
                'Subscribe podcast via search or import OMPL file.',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            Container(
                height: 400,
                // color: Colors.red,
                child: FlareActor(
                  'assets/add.flr',
                  isPaused: false,
                  alignment: Alignment.center,
                  animation: 'add',
                  fit: BoxFit.cover,
                )),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
