class SettingsBackup {
  final int theme;
  final String accentColor;
  final bool realDark;
  final bool autoPlay;
  final bool autoUpdate;
  final int updateInterval;
  final bool downloadUsingData;
  final int cacheMax;
  final int podcastLayout;
  final int recentLayout;
  final int favLayout;
  final int downloadLayout;
  final bool autoDownloadNetwork;
  final List<String> episodePopupMenu;
  final int autoDelete;
  final bool autoSleepTimer;
  final int autoSleepTimerStart;
  final int autoSleepTimerEnd;
  final int defaultSleepTime;
  final int autoSleepTimerMode;
  final bool tapToOpenPopupMenu;
  final int fastForwardSeconds;
  final int rewindSeconds;
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
      this.tapToOpenPopupMenu,
      this.fastForwardSeconds,
      this.rewindSeconds});

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
      'tapToOpenPopupMenu': tapToOpenPopupMenu,
      'fastForwardSeconds': fastForwardSeconds,
      'rewindSeconds': rewindSeconds
    };
  }

  static SettingsBackup fromJson(Map<String, Object> json) {
    List<String> list = List.from(json['episodePopupMenu']);
    return SettingsBackup(
        theme: json['theme'] as int,
        accentColor: json['accentColor'] as String,
        realDark: json['realDark'] as bool,
        autoPlay: json['autoPlay'] as bool,
        autoUpdate: json['autoUpdate'] as bool,
        updateInterval: json['updateInterval'] as int,
        downloadUsingData: json['downloadUsingData'] as bool,
        cacheMax: json['cacheMax'] as int,
        podcastLayout: json['podcastLayout'] as int,
        recentLayout: json['recentLayout'] as int,
        favLayout: json['favLayout'] as int,
        downloadLayout: json['downloadLayout'] as int,
        autoDownloadNetwork: json['autoDownloadNetwork'] as bool,
        episodePopupMenu: list,
        autoDelete: json['autoDelete'] as int,
        autoSleepTimer: json['autoSleepTimer'] as bool,
        autoSleepTimerStart: json['autoSleepeTimerStart'] as int,
        autoSleepTimerEnd: json['autoSleepTimerEnd'] as int,
        autoSleepTimerMode: json['autoSleepTimerMode'] as int,
        tapToOpenPopupMenu: json['tapToOpenPopupMenu'] as bool,
        fastForwardSeconds: json['fastForwardSeconds'] as int,
        rewindSeconds: json['rewindSeconds'] as int);
  }
}
