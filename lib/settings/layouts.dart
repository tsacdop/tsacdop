import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/state/setting_state.dart';

import '../local_storage/key_value_storage.dart';
import '../service/search_api.dart';
import '../state/audio_state.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_widget.dart';
import '../widgets/episodegrid.dart';
import '../.env.dart';
import 'popup_menu.dart';

class LayoutSetting extends StatefulWidget {
  const LayoutSetting({Key? key}) : super(key: key);

  @override
  _LayoutSettingState createState() => _LayoutSettingState();
}

class _LayoutSettingState extends State<LayoutSetting> {
  final _hideDiscoveyStorage = KeyValueStorage(hidePodcastDiscoveryKey);
  Future<Layout> _getLayout(String key) async {
    final keyValueStorage = KeyValueStorage(key);
    final layout = await keyValueStorage.getInt();
    return Layout.values[layout];
  }

  Future<bool> _getHideDiscovery() async {
    return await _hideDiscoveyStorage.getBool(defaultValue: false);
  }

  Future<void> _saveHideDiscovery(bool boo) async {
    await _hideDiscoveyStorage.saveBool(boo);
    if (mounted) setState(() {});
  }

  Future<bool> _hideListened() async {
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    var hideListened = await hideListenedStorage.getBool(defaultValue: false);
    return hideListened;
  }

  Future<void> _saveHideListened(bool boo) async {
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    await hideListenedStorage.saveBool(boo);
    if (mounted) setState(() {});
  }

  Future<SearchEngine> _getSearchEngine() async {
    final storage = KeyValueStorage(searchEngineKey);
    final index = await storage.getInt();
    return SearchEngine.values[index];
  }

  Future<void> _saveSearchEngine(SearchEngine engine) async {
    final storage = KeyValueStorage(searchEngineKey);
    await storage.saveInt(engine.index);
    if (mounted) setState(() {});
  }

  String _getHeightString(PlayerHeight? mode) {
    final s = context.s;
    switch (mode) {
      case PlayerHeight.short:
        return s.playerHeightShort;
      case PlayerHeight.mid:
        return s.playerHeightMed;
      case PlayerHeight.tall:
        return s.playerHeightTall;
      default:
        return '';
    }
  }

  Widget _gridOptions(BuildContext context,
          {required String key,
          Layout? layout,
          Layout? option,
          double? scale,
          BorderRadiusGeometry? borderRadius}) =>
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: InkWell(
          onTap: () async {
            var storage = KeyValueStorage(key);
            await storage.saveInt(option!.index);
            setState(() {});
          },
          borderRadius: borderRadius as BorderRadius?,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: 30,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: layout == option
                  ? context.accentColor
                  : context.primaryColorDark,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              height: 10,
              width: 30,
              child: CustomPaint(
                painter: LayoutPainter(
                    scale,
                    layout == option
                        ? Colors.white
                        : context.textTheme.bodyText1!.color),
              ),
            ),
          ),
        ),
      );

  Widget _setDefaultGrid(BuildContext context, {required String key}) {
    return FutureBuilder<Layout>(
        future: _getLayout(key),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _gridOptions(
                      context,
                      key: key,
                      layout: snapshot.data,
                      option: Layout.one,
                      scale: 4,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          topLeft: Radius.circular(5)),
                    ),
                    _gridOptions(
                      context,
                      key: key,
                      layout: snapshot.data,
                      option: Layout.two,
                      scale: 1,
                    ),
                    _gridOptions(context,
                        key: key,
                        layout: snapshot.data,
                        option: Layout.three,
                        scale: 0,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(5),
                            topRight: Radius.circular(5))),
                  ],
                )
              : Center();
        });
  }

  Widget _setDefaultGridView(BuildContext context,
      {String? text, required String key}) {
    return Padding(
      padding: EdgeInsets.only(left: 70.0, right: 20, bottom: 10),
      child: context.width > 360
          ? Row(
              children: [
                Text(
                  text!,
                ),
                Spacer(),
                _setDefaultGrid(context, key: key),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text!,
                ),
                _setDefaultGrid(context, key: key),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: context.primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
          appBar: AppBar(
            title: Text(s.settingsLayout),
            leading: CustomBackButton(),
            elevation: 0,
            backgroundColor: context.primaryColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Container(
                  height: 30.0,
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  alignment: Alignment.centerLeft,
                  child: Text(s.settingsPopupMenu,
                      style: context.textTheme.bodyText1!
                          .copyWith(color: context.accentColor)),
                ),
                ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PopupMenuSetting())),
                  contentPadding: EdgeInsets.only(left: 70.0, right: 20),
                  title: Text(s.settingsPopupMenu),
                  subtitle: Text(s.settingsPopupMenuDes),
                ),
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  alignment: Alignment.centerLeft,
                  child: Text(s.player,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Theme.of(context).accentColor)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.fromLTRB(70, 10, 10, 10),
                  title: Text(s.settingsPlayerHeight),
                  subtitle: Text(s.settingsPlayerHeightDes),
                  trailing: Selector<AudioPlayerNotifier, PlayerHeight?>(
                    selector: (_, audio) => audio.playerHeight,
                    builder: (_, data, __) => MyDropdownButton(
                        hint: Text(_getHeightString(data)),
                        underline: Center(),
                        elevation: 1,
                        value: data!.index,
                        items: <int>[0, 1, 2].map<DropdownMenuItem<int>>((e) {
                          return DropdownMenuItem<int>(
                              value: e,
                              child: Text(
                                  _getHeightString(PlayerHeight.values[e])));
                        }).toList(),
                        onChanged: (dynamic index) =>
                            audio.setPlayerHeight = PlayerHeight.values[index]),
                  ),
                ),
                if (environment['apiKey'] != '') Divider(height: 1),
                if (environment['apiKey'] != '')
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                if (environment['apiKey'] != '')
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    alignment: Alignment.centerLeft,
                    child: Text(s.search,
                        style: context.textTheme.bodyText1!
                            .copyWith(color: context.accentColor)),
                  ),
                if (environment['apiKey'] != '')
                  FutureBuilder<bool>(
                    future: _getHideDiscovery(),
                    initialData: false,
                    builder: (context, snapshot) => ListTile(
                      contentPadding: EdgeInsets.fromLTRB(70, 10, 10, 10),
                      onTap: () => _saveHideDiscovery(!snapshot.data!),
                      title: Text(s.hidePodcastDiscovery),
                      subtitle: Text(s.hidePodcastDiscoveryDes),
                      trailing: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                            value: snapshot.data!,
                            onChanged: _saveHideDiscovery),
                      ),
                    ),
                  ),
                if (environment['apiKey'] != '')
                  FutureBuilder(
                    future: _getSearchEngine(),
                    initialData: SearchEngine.listenNotes,
                    builder: (context, snapshot) => ListTile(
                      contentPadding: EdgeInsets.fromLTRB(70, 10, 10, 10),
                      title: Text(s.defaultSearchEngine),
                      subtitle: Text(s.defaultSearchEngineDes),
                      trailing: MyDropdownButton(
                          hint: Text(''),
                          underline: Center(),
                          elevation: 1,
                          value: snapshot.data,
                          items: [
                            DropdownMenuItem<SearchEngine>(
                                value: SearchEngine.podcastIndex,
                                child: Text('Podcastindex')),
                            DropdownMenuItem<SearchEngine>(
                                value: SearchEngine.listenNotes,
                                child: Text('ListenNotes')),
                          ],
                          onChanged: (dynamic value) =>
                              _saveSearchEngine(value)),
                    ),
                  ),
                Divider(height: 1),
                SizedBox(height: 20),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  alignment: Alignment.centerLeft,
                  child: Text('Default page',
                      style: context.textTheme.bodyText1!
                          .copyWith(color: context.accentColor)),
                ),
                Selector<SettingState, bool?>(
                  selector: (_, setting) => setting.openPlaylistDefault,
                  builder: (_, data, __) {
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(70, 10, 10, 10),
                      onTap: () => context
                          .read<SettingState>()
                          .openPlaylistDefault = !data!,
                      title: Text('Open playlist page by default'),
                      subtitle: Text(
                          'Open playlist page instead of homepage by default'),
                      trailing: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                            value: data!,
                            onChanged: (boo) => context
                                .read<SettingState>()
                                .openPlaylistDefault = boo),
                      ),
                    );
                  },
                ),
                Selector<SettingState, bool?>(
                  selector: (_, setting) => setting.openAllPodcastDefalt,
                  builder: (_, data, __) {
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(70, 10, 10, 10),
                      onTap: () => context
                          .read<SettingState>()
                          .openAllPodcastDefault = !data!,
                      title: Text('Open all podcasts page by default'),
                      subtitle: Text(
                          'Open all podcasts page instead of group page by default'),
                      trailing: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                            value: data!,
                            onChanged: (boo) => context
                                .read<SettingState>()
                                .openAllPodcastDefault = boo),
                      ),
                    );
                  },
                ),
                Divider(height: 1),
                SizedBox(height: 20),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  alignment: Alignment.centerLeft,
                  child: Text(s.settingsDefaultGrid,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Theme.of(context).accentColor)),
                ),
                ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      FutureBuilder<bool>(
                        future: _hideListened(),
                        initialData: false,
                        builder: (context, snapshot) => ListTile(
                          contentPadding: EdgeInsets.only(left: 70, right: 10),
                          onTap: () => _saveHideListened(!snapshot.data!),
                          title: Text('Hide listened'),
                          subtitle: Text('Hide listened episodes by default'),
                          trailing: Transform.scale(
                            scale: 0.9,
                            child: Switch(
                                value: snapshot.data!,
                                onChanged: _saveHideListened),
                          ),
                        ),
                      ),
                      _setDefaultGridView(context,
                          text: s.settingsDefaultGridPodcast,
                          key: podcastLayoutKey),
                      _setDefaultGridView(context,
                          text: s.settingsDefaultGridRecent,
                          key: recentLayoutKey),
                      _setDefaultGridView(context,
                          text: s.settingsDefaultGridFavorite,
                          key: favLayoutKey),
                      _setDefaultGridView(context,
                          text: s.settingsDefaultGridDownload,
                          key: downloadLayoutKey),
                    ]),
                Divider(height: 1),
              ],
            ),
          )),
    );
  }
}
