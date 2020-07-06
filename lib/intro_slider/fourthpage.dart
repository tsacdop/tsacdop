import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../util/context_extension.dart';

class FourthPage extends StatefulWidget {
  FourthPage({Key key}) : super(key: key);

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
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
                context.s.introFourthPage,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            Container(
                height: context.width * 3 / 4,
                // color: Colors.red,
                child: FlareActor(
                  'assets/longtap.flr',
                  alignment: Alignment.center,
                  animation: 'longtap',
                  fit: BoxFit.cover,
                )),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
