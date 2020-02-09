import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'class/importompl.dart';

class Import extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImportOmpl>(
        builder: (context, importOmpl, _) => Container(
            child: importOmpl.importState == ImportState.start
                ? Container(
                    height: 20.0,
                    alignment: Alignment.center,
                    child: Text('Start'),
                  )
                : importOmpl.importState == ImportState.import
                    ? Container(
                        height: 20.0,
                        alignment: Alignment.center,
                        child: Text('Importing'+(importOmpl.rsstitle)))
                    : importOmpl.importState == ImportState.complete
                        ? Container(
                            height: 20.0,
                            alignment: Alignment.center,
                            child: Text('Complete'),
                          )
                        : importOmpl.importState == ImportState.stop
                            ? Center()
                            : Center()));
  }
}
