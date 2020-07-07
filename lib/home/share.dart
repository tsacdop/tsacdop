import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/home/preview.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:tuple/tuple.dart';

import '../state/audio_state.dart';
import '../util/context_extension.dart';
import '../util/customslider.dart';
import '../util/pageroute.dart';

final List<BoxShadow> _customShadow = [
  BoxShadow(blurRadius: 26, offset: Offset(-6, -6), color: Colors.white),
  BoxShadow(
      blurRadius: 8,
      offset: Offset(2, 2),
      color: Colors.grey[600].withOpacity(0.4))
];

final List<BoxShadow> _customShadowNight = [
  BoxShadow(
      blurRadius: 6,
      offset: Offset(-1, -1),
      color: Colors.grey[100].withOpacity(0.3)),
  BoxShadow(blurRadius: 8, offset: Offset(2, 2), color: Colors.black)
];

String _stringForSeconds(int seconds) {
  if (seconds == null) return null;
  return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
}

class ShareClip extends StatefulWidget {
  ShareClip({Key key}) : super(key: key);

  @override
  _ShareClipState createState() => _ShareClipState();
}

class _ShareClipState extends State<ShareClip> {
  int _durationSelected;
  int _startPosition;
  bool _startConfirm;
  List<int> _durationToSelect = [30, 60, 90, 120];
  Widget _animatedWidget;
  Widget _toastWidget;

  @override
  void initState() {
    super.initState();
    _durationSelected = 60;
    _startPosition = 0;
    _startConfirm = false;
    _animatedWidget = Center();
    _toastWidget = Center();
  }

  _formatSeconds(int s) {
    switch (s) {
      case 30:
        return "30sec";
        break;
      case 60:
        return "1min";
        break;
      case 90:
        return "90sec";
        break;
      case 120:
        return "2min";
        break;
      default:
        return '';
        break;
    }
  }

  _setShareButton(ShareStatus status, String filePath) {
    switch (status) {
      case ShareStatus.generate:
        _animatedWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
            ),
            Text('Clipping'),
          ],
        );
        _toastWidget = Text('May take one minute',
            style: TextStyle(color: const Color(0xff67727d)));
        break;
      case ShareStatus.download:
        _animatedWidget = Text('Loading');
        break;
      case ShareStatus.complete:
        _animatedWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.share),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
            ),
            Text('Share'),
          ],
        );
        _toastWidget = Row(
          children: [
            Text('Preview'),
            IconButton(
                icon: Icon(LineIcons.play_solid),
                onPressed: () {
                  if (filePath != '')
                    Navigator.push(
                      context,
                      SlideLeftRoute(
                          page: ClipPreview(
                        filePath: filePath,
                      )),
                    );
                }),
          ],
        );
        break;
      case ShareStatus.undefined:
        _animatedWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LineIcons.cut_solid),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
            ),
            Text('Clip')
          ],
        );
        _toastWidget = Center();
        break;
      case ShareStatus.error:
        _animatedWidget = Text('Retry');
        _toastWidget = Text('Something wrong happened');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Container(
      height: 300,
      width: double.infinity,
      color: context.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            height: 60.0,
            // color: context.primaryColorDark,
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  height: 20.0,
                  // color: context.primaryColorDark,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Share Clip',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Spacer(),
                Selector<AudioPlayerNotifier, Tuple2<ShareStatus, String>>(
                  selector: (_, audio) =>
                      Tuple2(audio.shareStatus, audio.shareFile ?? ''),
                  builder: (_, data, __) {
                    _setShareButton(data.item1, data.item2);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            duration: Duration(milliseconds: 500),
                            child: _toastWidget),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                              color: context.primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black12
                                      : Colors.white10,
                                  width: 1),
                              boxShadow: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? _customShadowNight
                                  : _customShadow),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              onTap: () async {
                                if (data.item1 == ShareStatus.undefined ||
                                    data.item1 ==
                                        ShareStatus.error) if (_startConfirm)
                                  audio.shareClip(
                                      _startPosition, _durationSelected);
                                else
                                  Fluttertoast.showToast(
                                    msg: 'Please confirm start position',
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                else if (data.item1 == ShareStatus.complete) {
                                  File file = File(data.item2);
                                  final Uint8List bytes =
                                      await file.readAsBytes();
                                  await WcFlutterShare.share(
                                      sharePopupTitle: 'share Clip',
                                      fileName: data.item2.split('/').last,
                                      mimeType: 'video/mp4',
                                      bytesOfFile: bytes.buffer.asUint8List());
                                  audio.setShareStatue = ShareStatus.undefined;
                                }
                              },
                              child: SizedBox(
                                height: 40,
                                width: 100,
                                child: Center(
                                    child: AnimatedSwitcher(
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                                scale: animation, child: child),
                                        duration: Duration(milliseconds: 700),
                                        child: _animatedWidget)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer<AudioPlayerNotifier>(builder: (_, data, __) {
            return Container(
              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.black38
                          : Colors.grey[400],
                  inactiveTrackColor: Theme.of(context).primaryColorDark,
                  trackHeight: 20.0,
                  trackShape: MyRectangularTrackShape(),
                  thumbColor: Theme.of(context).accentColor,
                  thumbShape: MyRoundSliderThumpShape(
                      enabledThumbRadius: 10.0,
                      disabledThumbRadius: 10.0,
                      thumbCenterColor: context.accentColor),
                  overlayColor: Theme.of(context).accentColor.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 4.0),
                ),
                child: Slider(
                    value: data.seekSliderValue,
                    onChanged: (double val) {
                      audio.sliderSeek(val);
                    }),
              ),
            );
          }),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: Selector<AudioPlayerNotifier, int>(
                        selector: (_, audio) => audio.backgroundAudioPosition,
                        builder: (_, position, __) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text.rich(
                                  TextSpan(
                                      text: 'Start at \n',
                                      style:
                                          TextStyle(color: context.accentColor),
                                      children: [
                                        TextSpan(
                                            text: !_startConfirm
                                                ? _stringForSeconds(
                                                    position ~/ 1000)
                                                : _stringForSeconds(
                                                    _startPosition),
                                            style: context.textTheme.headline5
                                                .copyWith(
                                                    color: _startConfirm
                                                        ? context.accentColor
                                                        : null)),
                                      ]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      onPressed: () => audio.forwardAudio(-30),
                                      iconSize: 25.0,
                                      icon: Icon(Icons.replay_30),
                                      color: Colors.grey[500]),
                                  InkWell(
                                    onTap: () => setState(() {
                                      if (!_startConfirm)
                                        _startPosition = position ~/ 1000;
                                      _startConfirm = !_startConfirm;
                                    }),
                                    child: Container(
                                      margin: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          boxShadow: !_startConfirm
                                              ? (context.brightness ==
                                                      Brightness.dark)
                                                  ? _customShadowNight
                                                  : _customShadow
                                              : null,
                                          color: _startConfirm
                                              ? Theme.of(context).accentColor
                                              : Theme.of(context).primaryColor,
                                          shape: BoxShape.circle),
                                      alignment: Alignment.center,
                                      width: 40,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            LineIcons.thumbtack_solid,
                                            color: _startConfirm
                                                ? Colors.white
                                                : null,
                                          )),
                                    ),
                                  ),
                                  IconButton(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      onPressed: () => audio.forwardAudio(10),
                                      iconSize: 25.0,
                                      icon: Icon(Icons.forward_10),
                                      color: Colors.grey[500]),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  width: 2,
                  color: context.primaryColorDark,
                ),
                SizedBox(
                  height: 150,
                  width: 200,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: _durationToSelect
                              .map<Widget>((e) => InkWell(
                                    onTap: () =>
                                        setState(() => _durationSelected = e),
                                    child: Container(
                                      margin: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        boxShadow: e != _durationSelected
                                            ? (context.brightness ==
                                                    Brightness.dark)
                                                ? _customShadowNight
                                                : _customShadow
                                            : null,
                                        color: (e == _durationSelected)
                                            ? Theme.of(context).accentColor
                                            : Theme.of(context).primaryColor,
                                      ),
                                      alignment: Alignment.center,
                                      width: 70,
                                      height: 30,
                                      child: Text(_formatSeconds(e),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: (e == _durationSelected)
                                                  ? Colors.white
                                                  : null)),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )),
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('experimental'),
                  Icon(
                    LineIcons.info_circle_solid,
                    size: 20.0,
                    color: context.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
