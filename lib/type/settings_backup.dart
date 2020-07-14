class SettingsBackup {
  final int theme;
  final String accentColor;
  final int realDark;
  final int autoPlay;
  final int autoUpdate;
  final int updateInterval;
  final int downloadUsingData;
  final int cacheMax;
  final int podcastLayout;
  final int recentLayout;
  final int favLayout;
  final int downloadLayout;
  final int autoDownloadNetwork;
  final List<String> episodePopupMenu;
  final int autoDelete;
  final int autoSleepTimer;
  final int autoSleepTimerStart;
  final int autoSleepTimerEnd;
  final int defaultSleepTime;
  final int autoSleepTimerMode;
  final int tapToOpenPopupMenu;
  SettingsBackup(
      {this.theme,
      this.accentColor,
      this.realDark,
      this.autoPlay,
      this.autoUpdate,
      this.updateInterval,
      this.downloadUsingData,
      this.cacheMax,
      this.podcastLayout,
      this.recentLayout,
      this.favLayout,
      this.downloadLayout,
      this.autoDownloadNetwork,
      this.episodePopupMenu,
      this.autoDelete,
      this.autoSleepTimer,
      this.autoSleepTimerStart,
      this.autoSleepTimerEnd,
      this.defaultSleepTime,
      this.autoSleepTimerMode,
      this.tapToOpenPopupMenu});

  Map<String, Object> toJson() {
    return {
      'theme': theme,
      'accentColor': accentColor,
      'realDark': realDark,
      'autoPlay': autoPlay,
      'autoUpdate': autoUpdate,
      'updateInterval': updateInterval,
      'downloadUsingData': downloadUsingData,
      'cacheMax': cacheMax,
      'podcastLayout': podcastLayout,
      'recentLayout': recentLayout,
      'favLayout': favLayout,
      'downloadLayout': downloadLayout,
      'autoDownloadNetwork': autoDownloadNetwork,
      'episodePopupMenu': episodePopupMenu,
      'autoDelete': autoDelete,
      'autoSleepTimer': autoSleepTimer,
      'autoSleepTimerStart': autoSleepTimerStart,
      'autoSleepTimerEnd': autoSleepTimerEnd,
      'autoSleepTimerMode': autoSleepTimerMode,
      'tapToOpenPopupMenu': tapToOpenPopupMenu
    };
  }

  static SettingsBackup fromJson(Map<String, Object> json) {
    List<String> list = List.from(json['episodePopupMenu']);
    return SettingsBackup(
        theme: json['theme'] as int,
        accentColor: json['accentColor'] as String,
        realDark: json['realDark'] as int,
        autoPlay: json['autoPlay'] as int,
        autoUpdate: json['autoUpdate'] as int,
        updateInterval: json['updateInterval'] as int,
        downloadUsingData: json['downloadUsingData'] as int,
        cacheMax: json['cacheMax'] as int,
        podcastLayout: json['podcastLayout'] as int,
        recentLayout: json['recentLayout'] as int,
        favLayout: json['favLayout'] as int,
        downloadLayout: json['downloadLayout'] as int,
        autoDownloadNetwork: json['autoDownloadNetwork'] as int,
        episodePopupMenu: list,
        autoDelete: json['autoDelete'] as int,
        autoSleepTimer: json['autoSleepTimer'] as int,
        autoSleepTimerStart: json['autoSleepeTimerStart'] as int,
        autoSleepTimerEnd: json['autoSleepTimerEnd'] as int,
        autoSleepTimerMode: json['autoSleepTimerMode'] as int,
        tapToOpenPopupMenu: json['tapToOpenPopupMenu'] as int);
  }
}
