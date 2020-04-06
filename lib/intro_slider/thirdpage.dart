import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class ThirdPage extends StatefulWidget {
  ThirdPage({Key key}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(35, 204, 198, 1),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              alignment: Alignment.center,
              padding: EdgeInsets.all(40),
              child: Text('Swipe on podcast list to change group.', style: TextStyle(
                fontSize: 30,
                color: Colors.white
              ),),
            ),
            Container(
                height: 400,
                // color: Colors.red,
                child: FlareActor(
                  'assets/swipe.flr',
                  alignment: Alignment.center,
                  animation: 'swipe',
                  fit: BoxFit.cover,
                )),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
