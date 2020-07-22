import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'extension_helper.dart';

generalDialog(BuildContext context,
        {Widget title, Widget content, List<Widget> actions}) =>
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation animaiton,
              Animation secondaryAnimation) =>
          AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              Theme.of(context).brightness == Brightness.light
                  ? Color.fromRGBO(113, 113, 113, 1)
                  : Color.fromRGBO(15, 15, 15, 1),
        ),
        child: AlertDialog(
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: EdgeInsets.all(20),
            title: SizedBox(width: context.width - 160, child: title),
            content: content,
            actionsPadding: EdgeInsets.all(10),
            actions: actions),
      ),
    );
