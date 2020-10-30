import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/extension_helper.dart';

Future generalDialog(BuildContext context,
        {Widget title, Widget content, List<Widget> actions}) async =>
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animaiton, secondaryAnimation) =>
          AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: context.brightness == Brightness.light
              ? Color.fromRGBO(113, 113, 113, 1)
              : Color.fromRGBO(15, 15, 15, 1),
        ),
        child: AlertDialog(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            titlePadding: EdgeInsets.all(20),
            title: SizedBox(width: context.width - 120, child: title),
            content: content,
            contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            actions: actions),
      ),
    );

Future generalSheet(BuildContext context, {Widget child, String title}) async =>
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      elevation: 2,
      context: context,
      builder: (context) {
        final statusHeight = MediaQuery.of(context).padding.top;
        return SafeArea(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: context.height - statusHeight - 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 25,
                  margin: EdgeInsets.only(top: 10.0, bottom: 2.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      color: context.primaryColorDark),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 50, right: 50, top: 6.0, bottom: 15),
                  child: Text(
                    title,
                    style: context.textTheme.headline6,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Divider(height: 1),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        );
      },
    );
