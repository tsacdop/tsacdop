import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../util/extension_helper.dart';

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
              padding:
                  EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
              child: Text(
                context.s.introSecondPage,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            Container(
                height: context.width * 3 / 4,
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
