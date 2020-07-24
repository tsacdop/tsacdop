// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(groupName, count) => "${Intl.plural(count, zero: '', one: '${count} episode in ${groupName} added to playlist', other: '${count} episodes in ${groupName} added to playlist')}";

  static m1(count) => "${Intl.plural(count, zero: '', one: '${count} episode added to playlist', other: '${count} episodes added to playlist')}";

  static m2(count) => "${Intl.plural(count, zero: 'Today', one: '${count} day ago', other: '${count} days ago')}";

  static m3(count) => "${Intl.plural(count, zero: 'Never', one: '${count} day', other: '${count} days')}";

  static m4(count) => "${Intl.plural(count, zero: '', one: 'Episode', other: 'Episodes')}";

  static m5(time) => "From ${time}";

  static m6(count) => "${Intl.plural(count, zero: 'Group', one: 'Group', other: 'Groups')}";

  static m7(host) => "Hosted on ${host}";

  static m8(count) => "${Intl.plural(count, zero: 'In an hour', one: '${count} hour ago', other: '${count} hours ago')}";

  static m9(count) => "${Intl.plural(count, zero: '0 hour', one: '${count} hour', other: '${count} hours')}";

  static m10(count) => "${Intl.plural(count, zero: 'Just now', one: '${count} minute ago', other: '${count} minutes ago')}";

  static m11(count) => "${Intl.plural(count, zero: '0 min', one: '${count} min', other: '${count} mins')}";

  static m12(title) => "Fetch data ${title}";

  static m13(title) => "Subscribe failed, network error ${title}";

  static m14(title) => "Subscribe ${title}";

  static m15(title) => "Subscribe failed, podcast existed ${title}";

  static m16(title) => "Subscribe success ${title}";

  static m17(title) => "Update ${title}";

  static m18(title) => "Update error ${title}";

  static m19(count) => "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcasts')}";

  static m20(date) => "Published at ${date}";

  static m21(date) => "Removed at ${date}";

  static m22(count) => "${Intl.plural(count, zero: 'Just now', one: '${count} second ago', other: '${count} seconds ago')}";

  static m23(time) => "Last time ${time}";

  static m24(time) => "${time} Left";

  static m25(time) => "To ${time}";

  static m26(count) => "${Intl.plural(count, zero: 'No update', one: 'Updated ${count} episode', other: 'Updated ${count} episodes')}";

  static m27(version) => "Version : ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addEpisodeGroup" : m0,
    "addNewEpisodeAll" : m1,
    "addNewEpisodeTooltip" : MessageLookupByLibrary.simpleMessage("Add new episodes to playlist"),
    "addSomeGroups" : MessageLookupByLibrary.simpleMessage("Add some groups"),
    "all" : MessageLookupByLibrary.simpleMessage("All"),
    "autoDownload" : MessageLookupByLibrary.simpleMessage("Auto download"),
    "back" : MessageLookupByLibrary.simpleMessage("Back"),
    "buffering" : MessageLookupByLibrary.simpleMessage("Buffering"),
    "cancel" : MessageLookupByLibrary.simpleMessage("CANCEL"),
    "changeLayout" : MessageLookupByLibrary.simpleMessage("Change layout"),
    "changelog" : MessageLookupByLibrary.simpleMessage("Changelog"),
    "chooseA" : MessageLookupByLibrary.simpleMessage("Choose a"),
    "clear" : MessageLookupByLibrary.simpleMessage("Clear"),
    "color" : MessageLookupByLibrary.simpleMessage("color"),
    "confirm" : MessageLookupByLibrary.simpleMessage("CONFIRM"),
    "darkMode" : MessageLookupByLibrary.simpleMessage("Dark mode"),
    "daysAgo" : m2,
    "daysCount" : m3,
    "delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "developer" : MessageLookupByLibrary.simpleMessage("Developer"),
    "dismiss" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "done" : MessageLookupByLibrary.simpleMessage("Done"),
    "download" : MessageLookupByLibrary.simpleMessage("Download"),
    "downloaded" : MessageLookupByLibrary.simpleMessage("Downloaded"),
    "editGroupName" : MessageLookupByLibrary.simpleMessage("Edit group name"),
    "endOfEpisode" : MessageLookupByLibrary.simpleMessage("End of Episode"),
    "episode" : m4,
    "featureDiscoveryEditGroup" : MessageLookupByLibrary.simpleMessage("Tap to edit group"),
    "featureDiscoveryEditGroupDes" : MessageLookupByLibrary.simpleMessage("You can change group name or delete group here, but home group can not be edited or deleted"),
    "featureDiscoveryEpisode" : MessageLookupByLibrary.simpleMessage("Episode view"),
    "featureDiscoveryEpisodeDes" : MessageLookupByLibrary.simpleMessage("You can long tap to play episode or add episode to playlist."),
    "featureDiscoveryEpisodeTitle" : MessageLookupByLibrary.simpleMessage("Long tap to play episode instantly"),
    "featureDiscoveryGroup" : MessageLookupByLibrary.simpleMessage("Tap to add group"),
    "featureDiscoveryGroupDes" : MessageLookupByLibrary.simpleMessage("Default group is home for new podcast, you can create new group and move podcast to new group, podcast can be added to multi-groups."),
    "featureDiscoveryGroupPodcast" : MessageLookupByLibrary.simpleMessage("Long tap to reorder podcast"),
    "featureDiscoveryGroupPodcastDes" : MessageLookupByLibrary.simpleMessage("You can tap to see more options, or long tap to reorder podcast in group."),
    "featureDiscoveryOMPL" : MessageLookupByLibrary.simpleMessage("Tap to import OMPL"),
    "featureDiscoveryOMPLDes" : MessageLookupByLibrary.simpleMessage("You can import OMPL file, open setting or refresh all podcast at once here."),
    "featureDiscoveryPlaylist" : MessageLookupByLibrary.simpleMessage("Tap to open playlist"),
    "featureDiscoveryPlaylistDes" : MessageLookupByLibrary.simpleMessage("You can add episode to playlist by yourself. Episode will be auto removed from playlist when played."),
    "featureDiscoveryPodcast" : MessageLookupByLibrary.simpleMessage("Podcast view"),
    "featureDiscoveryPodcastDes" : MessageLookupByLibrary.simpleMessage("You can tap See All to add groups or manage podcasts."),
    "featureDiscoveryPodcastTitle" : MessageLookupByLibrary.simpleMessage("Scroll vertically to switch groups"),
    "featureDiscoverySearch" : MessageLookupByLibrary.simpleMessage("Tap to search podcast"),
    "featureDiscoverySearchDes" : MessageLookupByLibrary.simpleMessage("You can search podcast title , key word or RSS link to subscribe new podcast."),
    "feedbackEmail" : MessageLookupByLibrary.simpleMessage("Write to me"),
    "feedbackGithub" : MessageLookupByLibrary.simpleMessage("Submit issue"),
    "feedbackPlay" : MessageLookupByLibrary.simpleMessage("Rate on Play"),
    "feedbackTelegram" : MessageLookupByLibrary.simpleMessage("Join group"),
    "filter" : MessageLookupByLibrary.simpleMessage("Filter"),
    "fonts" : MessageLookupByLibrary.simpleMessage("Fonts"),
    "from" : m5,
    "goodNight" : MessageLookupByLibrary.simpleMessage("Good Night"),
    "groupExisted" : MessageLookupByLibrary.simpleMessage("Group existed"),
    "groupFilter" : MessageLookupByLibrary.simpleMessage("Group filter"),
    "groupRemoveConfirm" : MessageLookupByLibrary.simpleMessage("Are you sure you want to delete this group? Podcasts will be moved to Home group."),
    "groups" : m6,
    "homeGroupsSeeAll" : MessageLookupByLibrary.simpleMessage("See All"),
    "homeMenuPlaylist" : MessageLookupByLibrary.simpleMessage("Playlist"),
    "homeSubMenuSortBy" : MessageLookupByLibrary.simpleMessage("Sort by"),
    "homeTabMenuFavotite" : MessageLookupByLibrary.simpleMessage("Favorite"),
    "homeTabMenuRecent" : MessageLookupByLibrary.simpleMessage("Recent"),
    "homeToprightMenuAbout" : MessageLookupByLibrary.simpleMessage("About"),
    "homeToprightMenuImportOMPL" : MessageLookupByLibrary.simpleMessage("Import OMPL"),
    "homeToprightMenuRefreshAll" : MessageLookupByLibrary.simpleMessage("Refresh all"),
    "hostedOn" : m7,
    "hoursAgo" : m8,
    "hoursCount" : m9,
    "import" : MessageLookupByLibrary.simpleMessage("Import"),
    "introFourthPage" : MessageLookupByLibrary.simpleMessage("You can long press on episode card for quick actions."),
    "introSecondPage" : MessageLookupByLibrary.simpleMessage("Subscribe podcast via search or import OMPL file."),
    "introThirdPage" : MessageLookupByLibrary.simpleMessage("You can create new group for podcasts."),
    "later" : MessageLookupByLibrary.simpleMessage("Later"),
    "lightMode" : MessageLookupByLibrary.simpleMessage("Light mode"),
    "like" : MessageLookupByLibrary.simpleMessage("Like"),
    "likeDate" : MessageLookupByLibrary.simpleMessage("Like date"),
    "liked" : MessageLookupByLibrary.simpleMessage("Liked"),
    "listen" : MessageLookupByLibrary.simpleMessage("Listen"),
    "listened" : MessageLookupByLibrary.simpleMessage("Listened"),
    "loadMore" : MessageLookupByLibrary.simpleMessage("Load more"),
    "mark" : MessageLookupByLibrary.simpleMessage("Mark"),
    "markConfirm" : MessageLookupByLibrary.simpleMessage("Mark confirm"),
    "markConfirmContent" : MessageLookupByLibrary.simpleMessage("Confirm mark all episodes listened?"),
    "markListened" : MessageLookupByLibrary.simpleMessage("Mark listened"),
    "menu" : MessageLookupByLibrary.simpleMessage("Menu"),
    "menuAllPodcasts" : MessageLookupByLibrary.simpleMessage("All podcasts"),
    "menuMarkAllListened" : MessageLookupByLibrary.simpleMessage("Mark All Listened"),
    "menuViewRSS" : MessageLookupByLibrary.simpleMessage("Visit RSS Feed"),
    "menuVisitSite" : MessageLookupByLibrary.simpleMessage("Visit Site"),
    "minsAgo" : m10,
    "minsCount" : m11,
    "network" : MessageLookupByLibrary.simpleMessage("Network"),
    "newGroup" : MessageLookupByLibrary.simpleMessage("Create new group"),
    "newestFirst" : MessageLookupByLibrary.simpleMessage("Newest first"),
    "next" : MessageLookupByLibrary.simpleMessage("Next"),
    "noEpisodeDownload" : MessageLookupByLibrary.simpleMessage("No episode downloaded yet"),
    "noEpisodeFavorite" : MessageLookupByLibrary.simpleMessage("No episode collected yet"),
    "noEpisodeRecent" : MessageLookupByLibrary.simpleMessage("No episode received yet"),
    "noPodcastGroup" : MessageLookupByLibrary.simpleMessage("No podcast in this group"),
    "noShownote" : MessageLookupByLibrary.simpleMessage("Still no show notes received for this episode."),
    "notificaitonFatch" : m12,
    "notificationNetworkError" : m13,
    "notificationSubscribe" : m14,
    "notificationSubscribeExisted" : m15,
    "notificationSuccess" : m16,
    "notificationUpdate" : m17,
    "notificationUpdateError" : m18,
    "oldestFirst" : MessageLookupByLibrary.simpleMessage("Oldest first"),
    "play" : MessageLookupByLibrary.simpleMessage("Play"),
    "playing" : MessageLookupByLibrary.simpleMessage("Playing"),
    "plugins" : MessageLookupByLibrary.simpleMessage("Plugins"),
    "podcast" : m19,
    "podcastSubscribed" : MessageLookupByLibrary.simpleMessage("Podcast subscribed"),
    "popupMenuDownloadDes" : MessageLookupByLibrary.simpleMessage("Download episode"),
    "popupMenuLaterDes" : MessageLookupByLibrary.simpleMessage("Add episode to playlist"),
    "popupMenuLikeDes" : MessageLookupByLibrary.simpleMessage("Add episode to favorite"),
    "popupMenuMarkDes" : MessageLookupByLibrary.simpleMessage("Mark episode as listened"),
    "popupMenuPlayDes" : MessageLookupByLibrary.simpleMessage("Play the episode"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "published" : m20,
    "publishedDaily" : MessageLookupByLibrary.simpleMessage("Published daily"),
    "publishedMonthly" : MessageLookupByLibrary.simpleMessage("Published monthly"),
    "publishedWeekly" : MessageLookupByLibrary.simpleMessage("Published weekly"),
    "publishedYearly" : MessageLookupByLibrary.simpleMessage("Published yearly"),
    "recoverSubscribe" : MessageLookupByLibrary.simpleMessage("Recover subscribe"),
    "refreshArtwork" : MessageLookupByLibrary.simpleMessage("Update artwork"),
    "remove" : MessageLookupByLibrary.simpleMessage("Remove"),
    "removeConfirm" : MessageLookupByLibrary.simpleMessage("Remove confirm"),
    "removePodcastDes" : MessageLookupByLibrary.simpleMessage("Are you sure you want to unsubscribe?"),
    "removedAt" : m21,
    "save" : MessageLookupByLibrary.simpleMessage("Save"),
    "schedule" : MessageLookupByLibrary.simpleMessage("Schedule"),
    "search" : MessageLookupByLibrary.simpleMessage("Search"),
    "searchEpisode" : MessageLookupByLibrary.simpleMessage("Search episode"),
    "searchInvalidRss" : MessageLookupByLibrary.simpleMessage("Invalid RSS link"),
    "searchPodcast" : MessageLookupByLibrary.simpleMessage("Search podcast"),
    "secondsAgo" : m22,
    "settingStorage" : MessageLookupByLibrary.simpleMessage("Storage"),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsAccentColor" : MessageLookupByLibrary.simpleMessage("Accent color"),
    "settingsAccentColorDes" : MessageLookupByLibrary.simpleMessage("Include the ovelay color"),
    "settingsAppIntro" : MessageLookupByLibrary.simpleMessage("App Intro"),
    "settingsAppearance" : MessageLookupByLibrary.simpleMessage("Appearance"),
    "settingsAppearanceDes" : MessageLookupByLibrary.simpleMessage("Colors and themes"),
    "settingsAudioCache" : MessageLookupByLibrary.simpleMessage("Audio cache"),
    "settingsAudioCacheDes" : MessageLookupByLibrary.simpleMessage("Audio cache max size"),
    "settingsAutoDelete" : MessageLookupByLibrary.simpleMessage("Auto delete downloads after"),
    "settingsAutoDeleteDes" : MessageLookupByLibrary.simpleMessage("Default 30 days"),
    "settingsAutoPlayDes" : MessageLookupByLibrary.simpleMessage("Auto play next episode in playlist"),
    "settingsBackup" : MessageLookupByLibrary.simpleMessage("Backup"),
    "settingsBackupDes" : MessageLookupByLibrary.simpleMessage("Backup app data"),
    "settingsDefaultGrid" : MessageLookupByLibrary.simpleMessage("Default grid view"),
    "settingsDefaultGridDownload" : MessageLookupByLibrary.simpleMessage("Download tab"),
    "settingsDefaultGridFavorite" : MessageLookupByLibrary.simpleMessage("Favorite tab"),
    "settingsDefaultGridPodcast" : MessageLookupByLibrary.simpleMessage("Podcast page"),
    "settingsDefaultGridRecent" : MessageLookupByLibrary.simpleMessage("Recent tab"),
    "settingsDiscovery" : MessageLookupByLibrary.simpleMessage("Discovery Features Again"),
    "settingsEnableSyncing" : MessageLookupByLibrary.simpleMessage("Enable syncing"),
    "settingsEnableSyncingDes" : MessageLookupByLibrary.simpleMessage("Refresh all podcasts in the background to get leatest episodes"),
    "settingsExportDes" : MessageLookupByLibrary.simpleMessage("Export and import app settings"),
    "settingsFeedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "settingsFeedbackDes" : MessageLookupByLibrary.simpleMessage("Bugs and features request"),
    "settingsHistory" : MessageLookupByLibrary.simpleMessage("History"),
    "settingsHistoryDes" : MessageLookupByLibrary.simpleMessage("Listen data"),
    "settingsInfo" : MessageLookupByLibrary.simpleMessage("Info"),
    "settingsInterface" : MessageLookupByLibrary.simpleMessage("Interface"),
    "settingsLanguages" : MessageLookupByLibrary.simpleMessage("Languages"),
    "settingsLanguagesDes" : MessageLookupByLibrary.simpleMessage("Change language"),
    "settingsLayout" : MessageLookupByLibrary.simpleMessage("Layout"),
    "settingsLayoutDes" : MessageLookupByLibrary.simpleMessage("App layout"),
    "settingsLibraries" : MessageLookupByLibrary.simpleMessage("Libraries"),
    "settingsLibrariesDes" : MessageLookupByLibrary.simpleMessage("Open source libraries used in app"),
    "settingsManageDownload" : MessageLookupByLibrary.simpleMessage("Manage download"),
    "settingsManageDownloadDes" : MessageLookupByLibrary.simpleMessage("Manage downloaded audio files"),
    "settingsMenuAutoPlay" : MessageLookupByLibrary.simpleMessage("Auto play next"),
    "settingsNetworkCellular" : MessageLookupByLibrary.simpleMessage("Ask before using cellular data"),
    "settingsNetworkCellularAuto" : MessageLookupByLibrary.simpleMessage("Auto download using cellular data"),
    "settingsNetworkCellularAutoDes" : MessageLookupByLibrary.simpleMessage("You can set podcast auto download in group manage page"),
    "settingsNetworkCellularDes" : MessageLookupByLibrary.simpleMessage("Ask to confirm when using cellular data to download episodes"),
    "settingsPlayDes" : MessageLookupByLibrary.simpleMessage("Playlist and player"),
    "settingsPopupMenu" : MessageLookupByLibrary.simpleMessage("Episodes popup menu"),
    "settingsPopupMenuDes" : MessageLookupByLibrary.simpleMessage("Change the popup menu of episode"),
    "settingsPrefrence" : MessageLookupByLibrary.simpleMessage("Prefrence"),
    "settingsRealDark" : MessageLookupByLibrary.simpleMessage("Real dark"),
    "settingsRealDarkDes" : MessageLookupByLibrary.simpleMessage("Turn on if you think the night is not dark enough"),
    "settingsSTAuto" : MessageLookupByLibrary.simpleMessage("Auto turn on sleep timer"),
    "settingsSTAutoDes" : MessageLookupByLibrary.simpleMessage("Auto start sleep timer at scheduled time"),
    "settingsSTDefaultTime" : MessageLookupByLibrary.simpleMessage("Default time"),
    "settingsSTDefautTimeDes" : MessageLookupByLibrary.simpleMessage("Default time for sleep timer"),
    "settingsSTMode" : MessageLookupByLibrary.simpleMessage("Auto sleep timer mode"),
    "settingsStorageDes" : MessageLookupByLibrary.simpleMessage("Manage cache and download storage"),
    "settingsSyncing" : MessageLookupByLibrary.simpleMessage("Syncing"),
    "settingsSyncingDes" : MessageLookupByLibrary.simpleMessage("Refresh podcasts in the background"),
    "settingsTapToOpenPopupMenu" : MessageLookupByLibrary.simpleMessage("Tap to open popup menu"),
    "settingsTapToOpenPopupMenuDes" : MessageLookupByLibrary.simpleMessage("You need to long press to open episode page"),
    "settingsTheme" : MessageLookupByLibrary.simpleMessage("Theme"),
    "settingsUpdateInterval" : MessageLookupByLibrary.simpleMessage("Update interval"),
    "settingsUpdateIntervalDes" : MessageLookupByLibrary.simpleMessage("Default 24 hours"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "size" : MessageLookupByLibrary.simpleMessage("Size"),
    "skipSecondsAtStart" : MessageLookupByLibrary.simpleMessage("Skip seconds at start"),
    "sleepTimer" : MessageLookupByLibrary.simpleMessage("Sleep timer"),
    "subscribe" : MessageLookupByLibrary.simpleMessage("Subscribe"),
    "subscribeExportDes" : MessageLookupByLibrary.simpleMessage("Export OMPL file of all podcasts"),
    "systemDefault" : MessageLookupByLibrary.simpleMessage("System default"),
    "timeLastPlayed" : m23,
    "timeLeft" : m24,
    "to" : m25,
    "toastAddPlaylist" : MessageLookupByLibrary.simpleMessage("Added to playlist"),
    "toastDiscovery" : MessageLookupByLibrary.simpleMessage("Discovery feature reopened, pleast restart the app"),
    "toastFileError" : MessageLookupByLibrary.simpleMessage("File error, subscribe failed"),
    "toastFileNotValid" : MessageLookupByLibrary.simpleMessage("File not valid"),
    "toastHomeGroupNotSupport" : MessageLookupByLibrary.simpleMessage("Home group is not supported"),
    "toastImportSettingsSuccess" : MessageLookupByLibrary.simpleMessage("Import settings successfully"),
    "toastOneGroup" : MessageLookupByLibrary.simpleMessage("At least select one group"),
    "toastPodcastRecovering" : MessageLookupByLibrary.simpleMessage("Recovering, wait for a moment"),
    "toastReadFile" : MessageLookupByLibrary.simpleMessage("Read file successfully"),
    "toastRecoverFailed" : MessageLookupByLibrary.simpleMessage("Podcast recover failed"),
    "toastRemovePlaylist" : MessageLookupByLibrary.simpleMessage("Episode removed from playlist"),
    "toastSettingSaved" : MessageLookupByLibrary.simpleMessage("Setting saved"),
    "toastTimeEqualEnd" : MessageLookupByLibrary.simpleMessage("Time is equal to end time"),
    "toastTimeEqualStart" : MessageLookupByLibrary.simpleMessage("Time is equal to start time"),
    "translators" : MessageLookupByLibrary.simpleMessage("Translators"),
    "understood" : MessageLookupByLibrary.simpleMessage("Understood"),
    "undo" : MessageLookupByLibrary.simpleMessage("UNDO"),
    "unlike" : MessageLookupByLibrary.simpleMessage("Unlike"),
    "unliked" : MessageLookupByLibrary.simpleMessage("Episode removed from favorite"),
    "updateDate" : MessageLookupByLibrary.simpleMessage("Update date"),
    "updateEpisodesCount" : m26,
    "updateFailed" : MessageLookupByLibrary.simpleMessage("Update failed, network error"),
    "version" : m27
  };
}
