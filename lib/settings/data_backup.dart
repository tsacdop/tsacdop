import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../service/gpodder_api.dart';
import '../service/opml_build.dart';
import '../state/podcast_group.dart';
import '../state/setting_state.dart';
import '../type/settings_backup.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';

class DataBackup extends StatefulWidget {
  const DataBackup({super.key});

  @override
  _DataBackupState createState() => _DataBackupState();
}

class _DataBackupState extends State<DataBackup> {
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: context.iconBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: context.brightness,
      ),
      child: Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(
          elevation: 0,
          title: Text(s.settingsBackup),
          leading: CustomBackButton(),
          backgroundColor: context.primaryColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              height: 30.0,
              padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
              alignment: Alignment.centerLeft,
              child: Text(
                s.subscribe,
                style: context.textTheme.bodyLarge!.copyWith(
                  color: context.accentColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 70.0,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Text(s.subscribeExportDes),
            ),
            Padding(
              padding: EdgeInsets.only(left: 70.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LineIcons.save,
                            color: Colors.green[700],
                            size: context.textTheme.titleLarge!.fontSize,
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.save,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        final file = await _exportOmpl(context);
                        await _saveFile(file);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            size: context.textTheme.titleLarge!.fontSize,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.share,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var file = await _exportOmpl(context);
                        await _shareFile(file);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Divider(height: 1),
            ),
            Container(
              height: 30.0,
              padding: EdgeInsets.symmetric(horizontal: 70),
              alignment: Alignment.centerLeft,
              child: Text(
                s.settings,
                style: context.textTheme.bodyLarge!.copyWith(
                  color: context.accentColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 70.0,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Text(s.settingsExportDes),
            ),
            Padding(
              padding: EdgeInsets.only(left: 70.0, right: 10),
              child: Wrap(
                children: [
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LineIcons.save,
                            color: Colors.green[700],
                            size: context.textTheme.titleLarge!.fontSize,
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.save,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var file = await _exportSetting(context);
                        await _saveFile(file);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            size: context.textTheme.titleLarge!.fontSize,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.share,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var file = await _exportSetting(context);
                        await _shareFile(file);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LineIcons.paperclip,
                            size: context.textTheme.titleLarge!.fontSize,
                            color: Colors.red[700],
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.import,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _getFilePath(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Divider(height: 1),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _exportOmpl(BuildContext context) async {
    final groups = context.read<GroupList>().groups;
    final opml = PodcastsBackup(groups).omplBuilder();
    final tempdir = await getTemporaryDirectory();
    final now = DateTime.now();
    final datePlus =
        now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    final file = File(path.join(tempdir.path, 'tsacdop_opml_$datePlus.xml'));
    await file.writeAsString(opml.toXmlString());
    return file;
  }

  Future<void> _saveFile(File file) async {
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain')],
        fileNameOverrides: [file.path.split('/').last],
      ),
    );
  }

  Future<File> _exportSetting(BuildContext context) async {
    var settings = context.read<SettingState>();
    var settingsBack = await settings.backup();
    var json = settingsBack.toJson();
    var tempdir = await getTemporaryDirectory();
    var now = DateTime.now();
    var datePlus =
        now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    var file = File(path.join(tempdir.path, 'tsacdop_settings_$datePlus.json'));
    await file.writeAsString(jsonEncode(json));
    return file;
  }

  Future<void> _importSetting(String path, BuildContext context) async {
    final s = context.s;
    var settings = context.read<SettingState>();
    var file = File(path);
    try {
      var json = file.readAsStringSync();
      var backup = SettingsBackup.fromJson(jsonDecode(json));
      await settings.restore(backup);
      Fluttertoast.showToast(
        msg: s.toastImportSettingsSuccess,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      developer.log(e.toString(), name: 'Import settings');
      Fluttertoast.showToast(
        msg: s.toastFileError,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _getFilePath(BuildContext context) async {
    final s = context.s;
    try {
      final pickedFiles = await FilePicker.pickFiles(type: FileType.any);
      if (pickedFiles.isEmpty) {
        return;
      }
      Fluttertoast.showToast(
        msg: s.toastReadFile,
        gravity: ToastGravity.BOTTOM,
      );
      final filePath = pickedFiles.first.path!;
      _importSetting(filePath, context);
    } on PlatformException catch (e) {
      developer.log(e.toString(), name: 'Get file path');
    }
  }
}

class _OpenEye extends StatefulWidget {
  const _OpenEye();

  @override
  __OpenEyeState createState() => __OpenEyeState();
}

class __OpenEyeState extends State<_OpenEye>
    with SingleTickerProviderStateMixin {
  double _radius = 0.0;
  late Animation _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _radius = _animation.value;
          });
        }
      });
    _controller.forward();
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(Duration(milliseconds: 400));
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DotIndicator(radius: 8 * _radius + 0.5, color: Colors.white);
  }
}

enum LoginStatus { none, error, start, syncing, complete }

class _LoginGpodder extends StatefulWidget {
  const _LoginGpodder();

  @override
  __LoginGpodderState createState() => __LoginGpodderState();
}

class __LoginGpodderState extends State<_LoginGpodder> {
  String? _username = '';
  var _password = '';
  LoginStatus? _loginStatus;
  late ConfettiController _controller;

  @override
  void initState() {
    _loginStatus = LoginStatus.none;
    _controller = ConfettiController(duration: Duration(seconds: 3));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _gpodder = Gpodder();

  Future<void> _handleLogin() async {
    setState(() => _loginStatus = LoginStatus.start);
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      final status = await _gpodder.login(
        username: _username,
        password: _password,
      );
      if (status == 200) {
        final updateDevice = await _gpodder.updateDevice(_username);
        if (updateDevice == 200) {
          if (mounted) {
            setState(() {
              _loginStatus = LoginStatus.syncing;
            });
          }
          final uploadStatus = await _gpodder.uploadSubscriptions();
          await _getSubscriptions(_gpodder);
          if (uploadStatus == 200) {
            if (mounted) {
              setState(() {
                _loginStatus = LoginStatus.complete;
                _controller.play();
              });
            }
          }
        } else {
          if (mounted) setState(() => _loginStatus = LoginStatus.error);
          Fluttertoast.showToast(
            msg: context.s.loginFailed,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        if (mounted) setState(() => _loginStatus = LoginStatus.error);
        Fluttertoast.showToast(
          msg: context.s.loginFailed,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      if (mounted) setState(() => _loginStatus = LoginStatus.none);
    }
  }

  Future<void> _getSubscriptions(Gpodder gpodder) async {
    var subscribeWorker = context.read<GroupList>();
    var rssExp = RegExp(r'^(https?):\/\/(.*)');
    final opml = await gpodder.getAllPodcast();
    if (opml != '') {
      final data = PodcastsBackup.parseOPML(opml!);
      for (var entry in data.entries) {
        var list = entry.value.reversed;
        for (var rss in list) {
          var rssLink = rssExp.stringMatch(rss.xmlUrl!);
          if (rssLink != null) {
            final dbHelper = DBHelper();
            final exist = await dbHelper.checkPodcast(rssLink);
            if (exist == '') {
              var item = SubscribeItem(
                rssLink,
                rss.text == '' ? rssLink : rss.text,
                group: 'Home',
              );
              await subscribeWorker.setSubscribeItem(item, syncGpodder: false);
              await Future.delayed(Duration(milliseconds: 200));
            }
          }
        }
      }
    }
    await subscribeWorker.cancelWork();
    subscribeWorker.setWorkManager();
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return context.s.usernameRequired;
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return context.s.invalidName;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final passwordField = _passwordFieldKey.currentState!;
    if (passwordField.value == null || passwordField.value!.isEmpty) {
      return context.s.passwdRequired;
    }
    return null;
  }

  Widget _loginStatusButton() {
    switch (_loginStatus) {
      case LoginStatus.none:
        return Text(context.s.login, style: TextStyle(color: Colors.white));
      case LoginStatus.syncing:
        return Text(
          context.s.settingsSyncing,
          style: TextStyle(color: Colors.white),
        );
      case LoginStatus.start:
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      default:
        return Text(context.s.login, style: TextStyle(color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: context.iconBrightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: Colors.white),
                elevation: 0,
                leading: CustomBackButton(),
                backgroundColor: context.accentColor,
                expandedHeight: 200,
                flexibleSpace: Container(
                  height: 200,
                  width: double.infinity,
                  color: context.accentColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Hero(
                        tag: 'gpodder.net',
                        child: CircleAvatar(
                          minRadius: 50,
                          backgroundColor: context.primaryColor.withValues(
                            alpha: 0.3,
                          ),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: Image.asset('assets/gpodder.png'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          s.intergateWith('gpodder.net'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              _loginStatus == LoginStatus.complete
                  ? SliverList(
                      delegate: SliverChildListDelegate([
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                40.0,
                                50,
                                40,
                                100,
                              ),
                              child: Text(
                                s.gpodderLoginDes,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium!.copyWith(
                                  height: 2,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: ConfettiWidget(
                                confettiController: _controller,
                                blastDirectionality:
                                    BlastDirectionality.explosive,
                                emissionFrequency: 0.05,
                                maximumSize: Size(20, 10),
                                shouldLoop: false,
                                colors: const [
                                  Colors.green,
                                  Colors.blue,
                                  Colors.pink,
                                  Colors.orange,
                                  Colors.purple,
                                ],
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.accentColor),
                            ),
                            child: Text(s.back),
                          ),
                        ),
                      ]),
                    )
                  : Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: AutofillGroup(
                        child: SliverList(
                          delegate: SliverChildListDelegate([
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                40,
                                20,
                                40,
                                10,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: context.accentColor,
                                  ),
                                  focusColor: context.accentColor,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: context.accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: context.accentColor,
                                    ),
                                  ),
                                  labelText: s.username,
                                ),
                                maxLines: 1,
                                autofocus: true,
                                validator: _validateName,
                                autofillHints: [AutofillHints.username],
                                onSaved: (value) {
                                  setState(() => _username = value);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                40,
                                10,
                                40,
                                20,
                              ),
                              child: PasswordField(
                                fieldKey: _passwordFieldKey,
                                labelText: s.password,
                                validator: _validatePassword,
                                onSaved: (value) {
                                  if (value == null) {
                                    return setState(() {
                                      _password = value!;
                                    });
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                40,
                                10,
                                40,
                                20,
                              ),
                              child: InkWell(
                                onTap: () {
                                  _handleLogin();
                                },
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  height: 40,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: context.accentColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(child: _loginStatusButton()),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            ),
                          ]),
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

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      autofillHints: [AutofillHints.password],
      maxLength: 100,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: context.accentColor),
        labelStyle: TextStyle(color: context.accentColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.accentColor, width: 2),
        ),
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: context.accentColor,
            semanticLabel: _obscureText ? 'Show' : 'Hide',
          ),
        ),
      ),
    );
  }
}

class _GpodderInfo extends StatefulWidget {
  const _GpodderInfo();

  @override
  __GpodderInfoState createState() => __GpodderInfoState();
}

class __GpodderInfoState extends State<_GpodderInfo> {
  final _gpodder = Gpodder();
  final _gpodderUrl = "https://gpodder.net";

  Future<List<String>?> _getLoginInfo() async {
    final storage = KeyValueStorage(gpodderApiKey);
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final deviceInfo = await storage.getStringList();
    deviceInfo.add("Tsacdop on ${androidInfo.model}");
    return deviceInfo;
  }

  Future<void> _fullSync() async {
    final uploadStatus = await _gpodder.uploadSubscriptions();
    if (uploadStatus == 200) {
      var subscribeWorker = context.read<GroupList>();
      var rssExp = RegExp(r'^(https?):\/\/(.*)');
      final opml = await _gpodder.getAllPodcast();
      if (opml != '') {
        final data = PodcastsBackup.parseOPML(opml!);
        for (var entry in data.entries) {
          var list = entry.value.reversed;
          for (var rss in list) {
            var rssLink = rssExp.stringMatch(rss.xmlUrl!);
            if (rssLink != null) {
              final dbHelper = DBHelper();
              final exist = await dbHelper.checkPodcast(rssLink);
              if (exist == '') {
                var item = SubscribeItem(
                  rssLink,
                  rss.text == '' ? rssLink : rss.text,
                  group: 'Home',
                );
                await subscribeWorker.setSubscribeItem(
                  item,
                  syncGpodder: false,
                );
                await Future.delayed(Duration(milliseconds: 200));
              }
            }
          }
        }
      }
    }
    //await _syncNow();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: context.iconBrightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: Colors.white),
                leading: CustomBackButton(),
                elevation: 0,
                backgroundColor: context.accentColor,
                expandedHeight: 200,
                flexibleSpace: Container(
                  height: 200,
                  width: double.infinity,
                  color: context.accentColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        minRadius: 50,
                        backgroundColor: context.primaryColor.withValues(
                          alpha: 0.3,
                        ),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset('assets/gpodder.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'gpodder.net',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  FutureBuilder<List<String>?>(
                    future: _getLoginInfo(),
                    initialData: [],
                    builder: (context, snapshot) {
                      final deviceId = snapshot.data!.isNotEmpty
                          ? snapshot.data![1]
                          : '';
                      final deviceName = snapshot.data!.isNotEmpty
                          ? snapshot.data![3]
                          : '';
                      return Column(
                        children: [
                          ListTile(
                            title: Text('Device id'),
                            subtitle: Text(deviceId),
                          ),
                          ListTile(
                            title: Text('Device name'),
                            subtitle: Text(deviceName),
                          ),
                        ],
                      );
                    },
                  ),
                  ListTile(
                    onTap: () => _gpodderUrl.launchUrl,
                    title: Text('Visit gpodder.net'),
                    subtitle: Text('Manage subscriptions online'),
                  ),
                  ListTile(
                    onTap: _fullSync,
                    title: Text('Full sync'),
                    subtitle: Text('If error happened when syncing'),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
