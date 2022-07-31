class SettingsBackup {
  final int? theme;
  final String? accentColor;
  final bool? realDark;
  final bool? useWallpaperTheme;
  final bool? autoPlay;
  final bool? autoUpdate;
  final int? updateInterval;
  final bool? downloadUsingData;
  final int? cacheMax;
  final int? podcastLayout;
  final int? recentLayout;
  final int? favLayout;
  final int? downloadLayout;
  final bool? autoDownloadNetwork;
  final List<String>? episodePopupMenu;
  final int? autoDelete;
  final bool? autoSleepTimer;
  final int? autoSleepTimerStart;
  final int? autoSleepTimerEnd;
  final int? defaultSleepTime;
  final int? autoSleepTimerMode;
  final bool? tapToOpenPopupMenu;
  final int? fastForwardSeconds;
  final int? rewindSeconds;
  final int? playerHeight;
  final String? locale;
  final bool? hideListened;
  final int? notificationLayout;
  final int? showNotesFont;
  final List<String?>? speedList;
  final bool? hidePodcastDiscovery;
  final bool? markListenedAfterSkip;
  final bool? deleteAfterPlayed;
  final bool? openPlaylistDefault;
  final bool? openAllPodcastDefault;

  SettingsBackup(
      {this.theme,
      this.accentColor,
      this.realDark,
      this.useWallpaperTheme,
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
      this.rewindSeconds,
      this.playerHeight,
      this.locale,
      this.hideListened,
      this.notificationLayout,
      this.showNotesFont,
      this.speedList,
      this.hidePodcastDiscovery,
      this.markListenedAfterSkip,
      this.deleteAfterPlayed,
      this.openPlaylistDefault,
      this.openAllPodcastDefault});

  Map<String, Object?> toJson() {
    return {
      'theme': theme,
      'accentColor': accentColor,
      'realDark': realDark,
      'useWallpaperTheme': useWallpaperTheme,
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
      'rewindSeconds': rewindSeconds,
      'playerHeight': playerHeight,
      'locale': locale,
      'hideListened': hideListened,
      'notificationLayout': notificationLayout,
      'showNotesFont': showNotesFont,
      'speedList': speedList,
      'hidePodcastDiscovery': hidePodcastDiscovery,
      'markListenedAfterSkip': markListenedAfterSkip,
      'deleteAfterPlayed': deleteAfterPlayed,
      'openPlaylistDefault': openPlaylistDefault,
      'openAllPodcastDefault': openAllPodcastDefault
    };
  }

  static SettingsBackup fromJson(Map<String, Object> json) {
    final menuList =
        List<String>.from(json['episodePopupMenu'] as Iterable<dynamic>);
    final speedList = List<String>.from(json['speedList'] as Iterable<dynamic>);
    return SettingsBackup(
        theme: json['theme'] as int?,
        accentColor: json['accentColor'] as String?,
        realDark: json['realDark'] as bool?,
        useWallpaperTheme: json['useWallpaperTheme'] as bool?,
        autoPlay: json['autoPlay'] as bool?,
        autoUpdate: json['autoUpdate'] as bool?,
        updateInterval: json['updateInterval'] as int?,
        downloadUsingData: json['downloadUsingData'] as bool?,
        cacheMax: json['cacheMax'] as int?,
        podcastLayout: json['podcastLayout'] as int?,
        recentLayout: json['recentLayout'] as int?,
        favLayout: json['favLayout'] as int?,
        downloadLayout: json['downloadLayout'] as int?,
        autoDownloadNetwork: json['autoDownloadNetwork'] as bool?,
        episodePopupMenu: menuList,
        autoDelete: json['autoDelete'] as int?,
        autoSleepTimer: json['autoSleepTimer'] as bool?,
        autoSleepTimerStart: json['autoSleepeTimerStart'] as int?,
        autoSleepTimerEnd: json['autoSleepTimerEnd'] as int?,
        autoSleepTimerMode: json['autoSleepTimerMode'] as int?,
        tapToOpenPopupMenu: json['tapToOpenPopupMenu'] as bool?,
        fastForwardSeconds: json['fastForwardSeconds'] as int?,
        rewindSeconds: json['rewindSeconds'] as int?,
        playerHeight: json['playerHeight'] as int?,
        locale: json['locale'] as String?,
        hideListened: json['hideListened'] as bool?,
        notificationLayout: json['notificationLayout'] as int?,
        showNotesFont: json['showNotesFont'] as int?,
        speedList: speedList,
        hidePodcastDiscovery: json['hidePodcastDiscovery'] as bool?,
        markListenedAfterSkip: json['markListenedAfterSkip'] as bool?,
        deleteAfterPlayed: json['deleteAfterPlayed'] as bool?,
        openPlaylistDefault: json['openPlaylistDefaullt'] as bool?,
        openAllPodcastDefault: json['openAllPodcastDefault'] as bool?);
  }
}
