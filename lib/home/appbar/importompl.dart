import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/importompl.dart';

class Import extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImportOmpl>(
      builder: (context, importOmpl, _) => Container(
          color: Colors.grey[300],
          child: importOmpl.importState == ImportState.start
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                      SizedBox(height: 2.0, child: LinearProgressIndicator()),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        height: 20.0,
                        alignment: Alignment.centerLeft,
                        child: Text('Read file successful'),
                      ),
                    ])
              : importOmpl.importState == ImportState.import
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 2.0, child: LinearProgressIndicator()),
                        Container(
                            height: 20.0,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Connetting:  ' + (importOmpl.rsstitle))),
                      ],
                    )
                  : importOmpl.importState == ImportState.parse
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                                height: 2.0, child: LinearProgressIndicator()),
                            Container(
                              height: 20.0,
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              alignment: Alignment.centerLeft,
                              child: Text('Fatch:  ' + (importOmpl.rsstitle)),
                            ),
                          ],
                        )
                      : importOmpl.importState == ImportState.error
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                    height: 2.0,
                                    child: LinearProgressIndicator()),
                                Container(
                                  height: 20.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text('Error:  ' + (importOmpl.rsstitle)),
                                ),
                              ],
                            )
                          : Center()),
    );
  }
}
