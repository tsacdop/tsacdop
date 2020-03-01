import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/class/audiostate.dart';

class PlayedHistory extends StatefulWidget{
  @override
  _PlayedHistoryState createState() => _PlayedHistoryState();
}

class _PlayedHistoryState extends State<PlayedHistory> {

  Future<List<PlayHistory>> gerPlayHistory() async{
    DBHelper dbHelper =  DBHelper();
    List<PlayHistory> playHistory;
    playHistory = await dbHelper.getPlayHistory();
    await Future.forEach(playHistory, (playHistory) async{
        await playHistory.getEpisode();
    });
    return playHistory;
  }
 static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
     return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('History'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: FutureBuilder<List<PlayHistory>>(
            future: gerPlayHistory(),
            builder: (context, snapshot) {
              return 
              snapshot.hasData ?
               ListView.builder(
                 shrinkWrap: true,
                 scrollDirection: Axis.vertical,
                 itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index){
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(snapshot.data[index].title),
                          subtitle: Text(_stringForSeconds(snapshot.data[index].seconds)),
                        ),
                        Divider(height: 2),
                      ],
                    );
                }
                )
                : Center(
                  child: CircularProgressIndicator(),
                );
            },
          ),
        ),
      ),
      );
  }
}