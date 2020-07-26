import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../home/home.dart';
import '../state/setting_state.dart';
import '../util/extension_helper.dart';
import '../util/pageroute.dart';
import 'firstpage.dart';
import 'fourthpage.dart';
import 'secondpage.dart';
import 'thirdpage.dart';

enum Goto { home, settings }

class SlideIntro extends StatefulWidget {
  final Goto goto;
  SlideIntro({this.goto, Key key}) : super(key: key);

  @override
  _SlideIntroState createState() => _SlideIntroState();
}

class _SlideIntroState extends State<SlideIntro> {
  final List<BoxShadow> _customShadow = [
    BoxShadow(blurRadius: 2, offset: Offset(-2, -2), color: Colors.white54),
    BoxShadow(
        blurRadius: 8,
        offset: Offset(2, 2),
        color: Colors.grey[600].withOpacity(0.4))
  ];
  PageController _controller;
  double _position;
  @override
  void initState() {
    super.initState();
    _position = 0;
    _controller = PageController()
      ..addListener(() {
        setState(() {
          _position = _controller.page;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Container(
          child: Stack(
            children: <Widget>[
              PageView(
                physics: const PageScrollPhysics(),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  FirstPage(),
                  SecondPage(),
                  ThirdPage(),
                  FourthPage(),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  color: Colors.grey[100].withOpacity(0.5),
                  width: MediaQuery.of(context).size.width,
                  //   alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 40, right: 20, bottom: 30, top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: _position < 0.2
                                    ? Text(
                                        '1',
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                35, 204, 198, 1)),
                                      )
                                    : Center(),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: _position > 1
                                    ? 10
                                    : (1 - _position) * 10 + 10,
                                width: _position > 1
                                    ? 10
                                    : (1 - _position) * 10 + 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: _customShadow),
                              ),
                              Container(
                                child: _position < 1.2 && _position > 0.8
                                    ? Text('2',
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                77, 145, 190, 1)))
                                    : Center(),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: _position > 2
                                    ? 10
                                    : 20 - (_position - 1).abs() * 10,
                                width: _position > 2
                                    ? 10
                                    : 20 - (_position - 1).abs() * 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: _customShadow),
                              ),
                              Container(
                                child: _position < 2.2 && _position > 1.8
                                    ? Text('3',
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                35, 204, 198, 1)))
                                    : Center(),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: _position < 1
                                    ? 10
                                    : 20 - (_position - 2).abs() * 10,
                                width: _position < 1
                                    ? 10
                                    : 20 - (_position - 2).abs() * 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: _customShadow),
                              ),
                              Container(
                                child: _position > 2.8
                                    ? Text(
                                        '4',
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                77, 145, 190, 1)),
                                      )
                                    : Center(),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: _position < 2
                                    ? 10
                                    : 20 - (3 - _position) * 10,
                                width: _position < 2
                                    ? 10
                                    : 20 - (3 - _position) * 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: _customShadow),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                          boxShadow: _customShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: _position < 2.5
                              ? InkWell(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  onTap: () => _controller.animateToPage(
                                      _position.toInt() + 1,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.bounceIn),
                                  child: SizedBox(
                                      height: 40,
                                      width: 80,
                                      child: Center(
                                          child: Text(context.s.next,
                                              style: TextStyle(
                                                  color: Colors.black)))))
                              : InkWell(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  onTap: () {
                                    if (widget.goto == Goto.home) {
                                      Navigator.push(context,
                                          SlideLeftRoute(page: Home()));
                                      Provider.of<SettingState>(context,
                                              listen: false)
                                          .saveShowIntro(1);
                                    } else if (widget.goto == Goto.settings) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: SizedBox(
                                      height: 40,
                                      width: 80,
                                      child: Center(
                                          child: Text(context.s.done,
                                              style: TextStyle(
                                                  color: Colors.black))))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
