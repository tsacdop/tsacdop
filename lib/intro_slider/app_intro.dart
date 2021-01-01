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
  //final List<BoxShadow> _customShadow = [
  //  BoxShadow(blurRadius: 2, offset: Offset(-2, -2), color: Colors.white54),
  //  BoxShadow(
  //      blurRadius: 8,
  //      offset: Offset(2, 2),
  //      color: Colors.grey[600].withOpacity(0.4))
  //];
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

  Widget _indicatorWidget(int index) {
    final distance = (_position - index).abs();
    final size = distance > 1 ? 10.0 : 10 * (2 - distance);
    return Center(
      child: Container(
        alignment: Alignment.center,
        child: distance < 0.2
            ? Text(
                (index + 1).toString(),
                style: TextStyle(color: Color.fromRGBO(35, 204, 198, 1)),
              )
            : Center(),
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
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
                  width: context.width,
                  padding:
                      EdgeInsets.only(left: 40, right: 20, bottom: 30, top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: context.width / 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _indicatorWidget(0),
                            _indicatorWidget(1),
                            _indicatorWidget(2),
                            _indicatorWidget(3)
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          //boxShadow: _customShadow,
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
                                      curve: Curves.linear),
                                  child: SizedBox(
                                      height: 40,
                                      width: 80,
                                      child: Center(
                                          child: Text(context.s.next,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.bold)))))
                              : InkWell(
                                  borderRadius: BorderRadius.circular(20),
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
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.bold))))),
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
