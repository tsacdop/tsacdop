import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../util/extension_helper.dart';

class SecondPage extends StatefulWidget {
  SecondPage({Key? key}) : super(key: key);

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 200,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(40, context.paddingTop + 20, 40, 20),
              child: Text(
                context.s!.introSecondPage,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            SizedBox(
                height: context.width * 3 / 4,
                child: FlareActor(
                  'assets/add.flr',
                  isPaused: false,
                  alignment: Alignment.center,
                  animation: 'add',
                  fit: BoxFit.cover,
                )),
          ],
        ),
      ),
    );
  }
}
