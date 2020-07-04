// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hans locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_Hans';

  static m0(groupName, count) => "{count, plural, zero{} other{{group Name}分组${count}集节目添加到播放列表}}";

  static m1(count) => "${Intl.plural(count, zero: '', other: '${count}集节目添加到播放列表')}";

  static m2(host) => "平台 ${host}";

  static m3(count) => "${Intl.plural(count, zero: '', other: '${count} 小时')}";

  static m4(count) => "${Intl.plural(count, zero: '', other: '${count}分钟')}";

  static m5(title) => "获取数据 ${title}";

  static m6(title) => "订阅失败，网络错误 ${title}";

  static m7(title) => "订阅${title}";

  static m8(title) => "订阅失败，播客已存在 ${title}";

  static m9(title) => "订阅成功 ${title}";

  static m10(title) => "更新 ${title}";

  static m11(title) => "更新失败 ${title}";

  static m12(time) => "上次播放${time}";

  static m13(time) => "剩余 ${time}";

  static m14(count) => "${Intl.plural(count, zero: '未有更新', other: '更新 ${count} 集节目')}";

  static m15(version) => "版本：${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("订阅"),
    "addEpisodeGroup" : m0,
    "addNewEpisodeAll" : m1,
    "addNewEpisodeTooltip" : MessageLookupByLibrary.simpleMessage("添加更新节目到播放列表"),
    "addSomeGroups" : MessageLookupByLibrary.simpleMessage("请添加分组"),
    "all" : MessageLookupByLibrary.simpleMessage("全部"),
    "back" : MessageLookupByLibrary.simpleMessage("返回"),
    "buffering" : MessageLookupByLibrary.simpleMessage("缓冲"),
    "cancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "changeLayout" : MessageLookupByLibrary.simpleMessage("修改布局"),
    "changelog" : MessageLookupByLibrary.simpleMessage("更新日志"),
    "chooseA" : MessageLookupByLibrary.simpleMessage("选择"),
    "clear" : MessageLookupByLibrary.simpleMessage("清除"),
    "color" : MessageLookupByLibrary.simpleMessage("颜色"),
    "confirm" : MessageLookupByLibrary.simpleMessage("确认"),
    "darkMode" : MessageLookupByLibrary.simpleMessage("夜晚模式"),
    "delete" : MessageLookupByLibrary.simpleMessage("删除"),
    "developer" : MessageLookupByLibrary.simpleMessage("关于我"),
    "dismiss" : MessageLookupByLibrary.simpleMessage("忽略"),
    "download" : MessageLookupByLibrary.simpleMessage("下载"),
    "downloaded" : MessageLookupByLibrary.simpleMessage("已下载"),
    "editName" : MessageLookupByLibrary.simpleMessage("修改组名"),
    "endOfEpisode" : MessageLookupByLibrary.simpleMessage("节目结束"),
    "featureDiscoveryEpisode" : MessageLookupByLibrary.simpleMessage("节目界面"),
    "featureDiscoveryEpisodeDes" : MessageLookupByLibrary.simpleMessage("您可以长按播放节目或者添加节目到播放列表。"),
    "featureDiscoveryEpisodeTitle" : MessageLookupByLibrary.simpleMessage("您可以长按快速播放节目"),
    "featureDiscoveryOMPL" : MessageLookupByLibrary.simpleMessage("点击导入 OMPL"),
    "featureDiscoveryOMPLDes" : MessageLookupByLibrary.simpleMessage("在这里您可以导入OMPL文件，打开设置页面，或者刷新所有播客。"),
    "featureDiscoveryPlaylist" : MessageLookupByLibrary.simpleMessage("点击打开播放列表"),
    "featureDiscoveryPlaylistDes" : MessageLookupByLibrary.simpleMessage("您可以添加节目到播放列表，节目在播放后将会从播放列表自动移除。"),
    "featureDiscoveryPodcast" : MessageLookupByLibrary.simpleMessage("播客界面"),
    "featureDiscoveryPodcastDes" : MessageLookupByLibrary.simpleMessage("您可以点击“查看所有”新增或管理分组。"),
    "featureDiscoveryPodcastTitle" : MessageLookupByLibrary.simpleMessage("您可以通过上下滑动切换分组"),
    "featureDiscoverySearch" : MessageLookupByLibrary.simpleMessage("点击搜索播客"),
    "featureDiscoverySearchDes" : MessageLookupByLibrary.simpleMessage("您可以通过搜索播客名称、关键字或者RSS链接订阅播客。"),
    "feedbackEmail" : MessageLookupByLibrary.simpleMessage("发送邮件"),
    "feedbackGithub" : MessageLookupByLibrary.simpleMessage("提交Issue"),
    "feedbackPlay" : MessageLookupByLibrary.simpleMessage("Play评价"),
    "feedbackTelegram" : MessageLookupByLibrary.simpleMessage("加入小组"),
    "from" : MessageLookupByLibrary.simpleMessage("自"),
    "goodNight" : MessageLookupByLibrary.simpleMessage("晚安"),
    "groupFilter" : MessageLookupByLibrary.simpleMessage("分组"),
    "groups" : MessageLookupByLibrary.simpleMessage("分组"),
    "homeGroupsSeeAll" : MessageLookupByLibrary.simpleMessage("查看全部"),
    "homeMenuPlaylist" : MessageLookupByLibrary.simpleMessage("播放列表"),
    "homeSubMenuLikeData" : MessageLookupByLibrary.simpleMessage("添加日期"),
    "homeSubMenuSortBy" : MessageLookupByLibrary.simpleMessage("排序"),
    "homeSubMenuUpdateDate" : MessageLookupByLibrary.simpleMessage("更新日期"),
    "homeTabMenuFavotite" : MessageLookupByLibrary.simpleMessage("收藏"),
    "homeTabMenuRecent" : MessageLookupByLibrary.simpleMessage("最近更新"),
    "homeToprightMenuAbout" : MessageLookupByLibrary.simpleMessage("关于"),
    "homeToprightMenuImportOMPL" : MessageLookupByLibrary.simpleMessage("导入OMPL"),
    "homeToprightMenuRefreshAll" : MessageLookupByLibrary.simpleMessage("全部刷新"),
    "homeToprightMenuSettings" : MessageLookupByLibrary.simpleMessage("设置"),
    "hostedOn" : m2,
    "hoursCount" : m3,
    "later" : MessageLookupByLibrary.simpleMessage("稍后"),
    "lightMode" : MessageLookupByLibrary.simpleMessage("明亮模式"),
    "like" : MessageLookupByLibrary.simpleMessage("喜欢"),
    "likeDate" : MessageLookupByLibrary.simpleMessage("收藏日期"),
    "liked" : MessageLookupByLibrary.simpleMessage("已收藏"),
    "listen" : MessageLookupByLibrary.simpleMessage("收听"),
    "listened" : MessageLookupByLibrary.simpleMessage("已收听"),
    "loadMore" : MessageLookupByLibrary.simpleMessage("加载更多"),
    "markConfirm" : MessageLookupByLibrary.simpleMessage("确认标记"),
    "markConfirmContent" : MessageLookupByLibrary.simpleMessage("是否确认标记全部节目为已收听？"),
    "markListened" : MessageLookupByLibrary.simpleMessage("标记已收听"),
    "menu" : MessageLookupByLibrary.simpleMessage("菜单"),
    "menuAllPodcasts" : MessageLookupByLibrary.simpleMessage("所有订阅"),
    "menuMarkAllListened" : MessageLookupByLibrary.simpleMessage("标记所有已收听"),
    "menuViewRSS" : MessageLookupByLibrary.simpleMessage("查看 RSS"),
    "menuVisitSite" : MessageLookupByLibrary.simpleMessage("访问网站"),
    "minsCount" : m4,
    "network" : MessageLookupByLibrary.simpleMessage("网络"),
    "newGroup" : MessageLookupByLibrary.simpleMessage("创建分组"),
    "newestFirst" : MessageLookupByLibrary.simpleMessage("由新到旧"),
    "noEpisodeDownload" : MessageLookupByLibrary.simpleMessage("暂无下载节目"),
    "noEpisodeFavorite" : MessageLookupByLibrary.simpleMessage("暂无收藏节目"),
    "noEpisodeRecent" : MessageLookupByLibrary.simpleMessage("暂无节目"),
    "noPodcastGroup" : MessageLookupByLibrary.simpleMessage("分组无播客"),
    "notificaitonFatch" : m5,
    "notificationNetworkError" : m6,
    "notificationSubscribe" : m7,
    "notificationSubscribeExisted" : m8,
    "notificationSuccess" : m9,
    "notificationUpdate" : m10,
    "notificationUpdateError" : m11,
    "oldestFirst" : MessageLookupByLibrary.simpleMessage("由旧到新"),
    "play" : MessageLookupByLibrary.simpleMessage("播放"),
    "playing" : MessageLookupByLibrary.simpleMessage("正在播放"),
    "podcastSubscribed" : MessageLookupByLibrary.simpleMessage("播客已订阅"),
    "popupMenuDownloadDes" : MessageLookupByLibrary.simpleMessage("下载节目"),
    "popupMenuLaterDes" : MessageLookupByLibrary.simpleMessage("添加到播放列表"),
    "popupMenuLikeDes" : MessageLookupByLibrary.simpleMessage("添加到收藏"),
    "popupMenuMarkDes" : MessageLookupByLibrary.simpleMessage("设置为已收听"),
    "popupMenuPlayDes" : MessageLookupByLibrary.simpleMessage("播放节目"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("隐私条款"),
    "remove" : MessageLookupByLibrary.simpleMessage("移除"),
    "schedule" : MessageLookupByLibrary.simpleMessage("定时"),
    "searchInvalidRss" : MessageLookupByLibrary.simpleMessage("RSS 链接错误"),
    "searchPodcast" : MessageLookupByLibrary.simpleMessage("搜索播客"),
    "settingStorage" : MessageLookupByLibrary.simpleMessage("储存空间"),
    "settingsAccentColor" : MessageLookupByLibrary.simpleMessage("次要颜色"),
    "settingsAccentColorDes" : MessageLookupByLibrary.simpleMessage("包括溢出颜色"),
    "settingsAppIntro" : MessageLookupByLibrary.simpleMessage("引导页"),
    "settingsAppearance" : MessageLookupByLibrary.simpleMessage("界面"),
    "settingsAppearanceDes" : MessageLookupByLibrary.simpleMessage("颜色与主题"),
    "settingsAudioCache" : MessageLookupByLibrary.simpleMessage("播放缓存"),
    "settingsAudioCacheDes" : MessageLookupByLibrary.simpleMessage("播放缓存设置"),
    "settingsAutoDelete" : MessageLookupByLibrary.simpleMessage("自动删除下载节目"),
    "settingsAutoDeleteDes" : MessageLookupByLibrary.simpleMessage("默认 30 天"),
    "settingsAutoPlayDes" : MessageLookupByLibrary.simpleMessage("自动播放下一节目"),
    "settingsDefaultGrid" : MessageLookupByLibrary.simpleMessage("默认布局"),
    "settingsDefaultGridDownload" : MessageLookupByLibrary.simpleMessage("下载页"),
    "settingsDefaultGridFavorite" : MessageLookupByLibrary.simpleMessage("收藏页"),
    "settingsDefaultGridPodcast" : MessageLookupByLibrary.simpleMessage("播客页"),
    "settingsDefaultGridRecent" : MessageLookupByLibrary.simpleMessage("最近页"),
    "settingsDiscovery" : MessageLookupByLibrary.simpleMessage("再次功能介绍"),
    "settingsEnableSyncing" : MessageLookupByLibrary.simpleMessage("开启自动更新"),
    "settingsEnableSyncingDes" : MessageLookupByLibrary.simpleMessage("在后台更新所有订阅播客"),
    "settingsExport" : MessageLookupByLibrary.simpleMessage("导出"),
    "settingsExportDes" : MessageLookupByLibrary.simpleMessage("导出 OMPL 文件"),
    "settingsFeedback" : MessageLookupByLibrary.simpleMessage("反馈"),
    "settingsFeedbackDes" : MessageLookupByLibrary.simpleMessage("意见与建议"),
    "settingsHistory" : MessageLookupByLibrary.simpleMessage("历史记录"),
    "settingsHistoryDes" : MessageLookupByLibrary.simpleMessage("播放日期"),
    "settingsInfo" : MessageLookupByLibrary.simpleMessage("信息"),
    "settingsInterface" : MessageLookupByLibrary.simpleMessage("界面"),
    "settingsLayout" : MessageLookupByLibrary.simpleMessage("布局"),
    "settingsLayoutDes" : MessageLookupByLibrary.simpleMessage("应用布局"),
    "settingsLibraries" : MessageLookupByLibrary.simpleMessage("开源"),
    "settingsLibrariesDes" : MessageLookupByLibrary.simpleMessage("使用开源项目"),
    "settingsManageDownload" : MessageLookupByLibrary.simpleMessage("下载管理"),
    "settingsManageDownloadDes" : MessageLookupByLibrary.simpleMessage("管理下载节目文件"),
    "settingsMenuAutoPlay" : MessageLookupByLibrary.simpleMessage("自动播放下一节目"),
    "settingsNetworkCellular" : MessageLookupByLibrary.simpleMessage("蜂窝数据确认"),
    "settingsNetworkCellularAuto" : MessageLookupByLibrary.simpleMessage("是否用蜂窝数据自动下载"),
    "settingsNetworkCellularAutoDes" : MessageLookupByLibrary.simpleMessage("你可以在分组管理页面设置自动下载"),
    "settingsNetworkCellularDes" : MessageLookupByLibrary.simpleMessage("在使用蜂窝数据下载前确认"),
    "settingsPlayDes" : MessageLookupByLibrary.simpleMessage("播放列表和播放器"),
    "settingsPopupMenu" : MessageLookupByLibrary.simpleMessage("节目弹出菜单"),
    "settingsPopupMenuDes" : MessageLookupByLibrary.simpleMessage("修改节目弹出菜单"),
    "settingsPrefrence" : MessageLookupByLibrary.simpleMessage("首选项"),
    "settingsRealDark" : MessageLookupByLibrary.simpleMessage("真的黑"),
    "settingsRealDarkDes" : MessageLookupByLibrary.simpleMessage("如果夜不够黑，请开启"),
    "settingsSTAuto" : MessageLookupByLibrary.simpleMessage("自动睡眠模式"),
    "settingsSTAutoDes" : MessageLookupByLibrary.simpleMessage("定期开启睡眠模式"),
    "settingsSTDefaultTime" : MessageLookupByLibrary.simpleMessage("默认时长"),
    "settingsSTDefautTimeDes" : MessageLookupByLibrary.simpleMessage("睡眠模式默认时长"),
    "settingsSTMode" : MessageLookupByLibrary.simpleMessage("自动睡眠模式默认时长"),
    "settingsStorageDes" : MessageLookupByLibrary.simpleMessage("管理缓存和下载空间"),
    "settingsSyncing" : MessageLookupByLibrary.simpleMessage("同步"),
    "settingsSyncingDes" : MessageLookupByLibrary.simpleMessage("在后台更新播客"),
    "settingsTheme" : MessageLookupByLibrary.simpleMessage("主题"),
    "settingsUpdateInterval" : MessageLookupByLibrary.simpleMessage("更新频率"),
    "settingsUpdateIntervalDes" : MessageLookupByLibrary.simpleMessage("默认 24 小时"),
    "size" : MessageLookupByLibrary.simpleMessage("大小"),
    "sleepTimer" : MessageLookupByLibrary.simpleMessage("睡眠模式"),
    "subscribe" : MessageLookupByLibrary.simpleMessage("订阅"),
    "systemDefault" : MessageLookupByLibrary.simpleMessage("系统默认"),
    "timeLastPlayed" : m12,
    "timeLeft" : m13,
    "to" : MessageLookupByLibrary.simpleMessage("到"),
    "toastAddPlaylist" : MessageLookupByLibrary.simpleMessage("添加到播放列表"),
    "toastDescovery" : MessageLookupByLibrary.simpleMessage("重启应用后可查看"),
    "toastFileError" : MessageLookupByLibrary.simpleMessage("文件错误，导入失败"),
    "toastFileNotVilid" : MessageLookupByLibrary.simpleMessage("文件错误"),
    "toastReadFile" : MessageLookupByLibrary.simpleMessage("读取文件成功"),
    "toastRemovePlaylist" : MessageLookupByLibrary.simpleMessage("从播放列表移除"),
    "understood" : MessageLookupByLibrary.simpleMessage("了解"),
    "unlike" : MessageLookupByLibrary.simpleMessage("取消喜欢"),
    "unliked" : MessageLookupByLibrary.simpleMessage("从收藏移除"),
    "updateDate" : MessageLookupByLibrary.simpleMessage("更新日期"),
    "updateEpisodesCount" : m14,
    "updateFailed" : MessageLookupByLibrary.simpleMessage("更新失败"),
    "version" : m15
  };
}
