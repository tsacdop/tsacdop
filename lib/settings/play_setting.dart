import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/audiostate.dart';

class PlaySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Player Setting'),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text('Playlist',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        contentPadding:
                            EdgeInsets.only(left: 80.0, right: 20, bottom: 0),
                        title: Text('Autoplay'),
                        subtitle: Text('Autoplay next episode in playlist'),
                        trailing: Selector<AudioPlayerNotifier, bool>(
                          selector: (_, audio) => audio.autoPlay,
                          builder: (_, data, __) => Switch(
                              value: data,
                              onChanged: (boo) => audio.autoPlaySwitch = boo),
                        ),
                      ),
                      Divider(height: 2),
                      //       ListTile(
                      //         contentPadding:
                      //             EdgeInsets.only(left: 80.0, right: 20, bottom: 0),
                      //         title: Text('Autoadd'),
                      //         subtitle:
                      //             Text('Autoadd new updated episodes to playlist'),
                      //         trailing: Selector<AudioPlayerNotifier, bool>(
                      //           selector: (_, audio) => audio.autoAdd,
                      //           builder: (_, data, __) => Switch(
                      //               value: data,
                      //               onChanged: (boo) => audio.autoAddSwitch = boo),
                      //         ),
                      //       ),
                      //       Divider(height: 2),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
