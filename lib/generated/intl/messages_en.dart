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

  static m2(host) => "Hosted on ${host}";

  static m3(count) => "${Intl.plural(count, zero: '', one: '${count} hour', other: '${count} hours')}";

  static m4(count) => "${Intl.plural(count, zero: '', one: '${count} min', other: '${count} mins')}";

  static m5(title) => "Fetch data ${title}";

  static m6(title) => "Subscribe failed, network error ${title}";

  static m7(title) => "Subscribe ${title}";

  static m8(title) => "Subscribe failed, podcast existed ${title}";

  static m9(title) => "Subscribe success ${title}";

  static m10(title) => "Update ${title}";

  static m11(title) => "Update error ${title}";

  static m12(time) => "Last time ${time}";

  static m13(time) => "${time} Left";

  static m14(count) => "${Intl.plural(count, zero: 'No Update', one: 'Updated ${count} Episode', other: 'Updated ${count} Episodes')}";

  static m15(version) => "Version : ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addEpisodeGroup" : m0,
    "addNewEpisodeAll" : m1,
    "addNewEpisodeTooltip" : MessageLookupByLibrary.simpleMessage("Add new episodes to playlist"),
    "addSomeGroups" : MessageLookupByLibrary.simpleMessage("Add some groups"),
    "all" : MessageLookupByLibrary.simpleMessage("All"),
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
    "delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "developer" : MessageLookupByLibrary.simpleMessage("Developer"),
    "dismiss" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "download" : MessageLookupByLibrary.simpleMessage("Download"),
    "downloaded" : MessageLookupByLibrary.simpleMessage("Downloaded"),
    "editName" : MessageLookupByLibrary.simpleMessage("Edit name"),
    "endOfEpisode" : MessageLookupByLibrary.simpleMessage("End of Episode"),
    "featureDiscoveryEpisode" : MessageLookupByLibrary.simpleMessage("Episode view"),
    "featureDiscoveryEpisodeDes" : MessageLookupByLibrary.simpleMessage("You can long tap to play episode or add episode to playlist."),
    "featureDiscoveryEpisodeTitle" : MessageLookupByLibrary.simpleMessage("Long tap to play episode instantly"),
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
    "from" : MessageLookupByLibrary.simpleMessage("From"),
    "goodNight" : MessageLookupByLibrary.simpleMessage("Good Night"),
    "groupFilter" : MessageLookupByLibrary.simpleMessage("Group filter"),
    "groups" : MessageLookupByLibrary.simpleMessage("Groups"),
    "homeGroupsSeeAll" : MessageLookupByLibrary.simpleMessage("See All"),
    "homeMenuPlaylist" : MessageLookupByLibrary.simpleMessage("Playlist"),
    "homeSubMenuLikeData" : MessageLookupByLibrary.simpleMessage("Like Date"),
    "homeSubMenuSortBy" : MessageLookupByLibrary.simpleMessage("Sort by"),
    "homeSubMenuUpdateDate" : MessageLookupByLibrary.simpleMessage("Update Date"),
    "homeTabMenuFavotite" : MessageLookupByLibrary.simpleMessage("Favorite"),
    "homeTabMenuRecent" : MessageLookupByLibrary.simpleMessage("Recent"),
    "homeToprightMenuAbout" : MessageLookupByLibrary.simpleMessage("About"),
    "homeToprightMenuImportOMPL" : MessageLookupByLibrary.simpleMessage("Import OMPL"),
    "homeToprightMenuRefreshAll" : MessageLookupByLibrary.simpleMessage("Refresh all"),
    "homeToprightMenuSettings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "hostedOn" : m2,
    "hoursCount" : m3,
    "later" : MessageLookupByLibrary.simpleMessage("Later"),
    "lightMode" : MessageLookupByLibrary.simpleMessage("Light mode"),
    "like" : MessageLookupByLibrary.simpleMessage("Like"),
    "likeDate" : MessageLookupByLibrary.simpleMessage("Like date"),
    "liked" : MessageLookupByLibrary.simpleMessage("Liked"),
    "listen" : MessageLookupByLibrary.simpleMessage("Listen"),
    "listened" : MessageLookupByLibrary.simpleMessage("Listened"),
    "loadMore" : MessageLookupByLibrary.simpleMessage("Load more"),
    "markConfirm" : MessageLookupByLibrary.simpleMessage("Mark confirm"),
    "markConfirmContent" : MessageLookupByLibrary.simpleMessage("Confirm mark all episodes listened?"),
    "markListened" : MessageLookupByLibrary.simpleMessage("Mark listened"),
    "menu" : MessageLookupByLibrary.simpleMessage("Menu"),
    "menuAllPodcasts" : MessageLookupByLibrary.simpleMessage("All podcasts"),
    "menuMarkAllListened" : MessageLookupByLibrary.simpleMessage("Mark All Listened"),
    "menuViewRSS" : MessageLookupByLibrary.simpleMessage("Visit RSS Feed"),
    "menuVisitSite" : MessageLookupByLibrary.simpleMessage("Visit Site"),
    "minsCount" : m4,
    "network" : MessageLookupByLibrary.simpleMessage("Network"),
    "newGroup" : MessageLookupByLibrary.simpleMessage("Create new group"),
    "newestFirst" : MessageLookupByLibrary.simpleMessage("Newest first"),
    "noEpisodeDownload" : MessageLookupByLibrary.simpleMessage("No episode downloaded yet"),
    "noEpisodeFavorite" : MessageLookupByLibrary.simpleMessage("No episode collected yet"),
    "noEpisodeRecent" : MessageLookupByLibrary.simpleMessage("No episode received yet"),
    "noPodcastGroup" : MessageLookupByLibrary.simpleMessage("No podcast in this group"),
    "notificaitonFatch" : m5,
    "notificationNetworkError" : m6,
    "notificationSubscribe" : m7,
    "notificationSubscribeExisted" : m8,
    "notificationSuccess" : m9,
    "notificationUpdate" : m10,
    "notificationUpdateError" : m11,
    "oldestFirst" : MessageLookupByLibrary.simpleMessage("Oldest first"),
    "play" : MessageLookupByLibrary.simpleMessage("Play"),
    "playing" : MessageLookupByLibrary.simpleMessage("Playing"),
    "podcastSubscribed" : MessageLookupByLibrary.simpleMessage("Podcast subscribed"),
    "popupMenuDownloadDes" : MessageLookupByLibrary.simpleMessage("Download episode"),
    "popupMenuLaterDes" : MessageLookupByLibrary.simpleMessage("Add episode to playlist"),
    "popupMenuLikeDes" : MessageLookupByLibrary.simpleMessage("Add episode to favorite"),
    "popupMenuMarkDes" : MessageLookupByLibrary.simpleMessage("Mark episode as listened"),
    "popupMenuPlayDes" : MessageLookupByLibrary.simpleMessage("Play the episode"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "remove" : MessageLookupByLibrary.simpleMessage("Remove"),
    "schedule" : MessageLookupByLibrary.simpleMessage("Schedule"),
    "searchInvalidRss" : MessageLookupByLibrary.simpleMessage("Invalid RSS link"),
    "searchPodcast" : MessageLookupByLibrary.simpleMessage("Search podcast"),
    "settingStorage" : MessageLookupByLibrary.simpleMessage("Storage"),
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
    "settingsDefaultGrid" : MessageLookupByLibrary.simpleMessage("Default grid view"),
    "settingsDefaultGridDownload" : MessageLookupByLibrary.simpleMessage("Download tab"),
    "settingsDefaultGridFavorite" : MessageLookupByLibrary.simpleMessage("Favorite tab"),
    "settingsDefaultGridPodcast" : MessageLookupByLibrary.simpleMessage("Podcast page"),
    "settingsDefaultGridRecent" : MessageLookupByLibrary.simpleMessage("Recent tab"),
    "settingsDiscovery" : MessageLookupByLibrary.simpleMessage("Discovery Features Again"),
    "settingsEnableSyncing" : MessageLookupByLibrary.simpleMessage("Enable Syncing"),
    "settingsEnableSyncingDes" : MessageLookupByLibrary.simpleMessage("Refresh all podcasts in the background to get leatest episodes"),
    "settingsExport" : MessageLookupByLibrary.simpleMessage("Export"),
    "settingsExportDes" : MessageLookupByLibrary.simpleMessage("Export OMPL file of all podcasts"),
    "settingsFeedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "settingsFeedbackDes" : MessageLookupByLibrary.simpleMessage("Bugs and feature request"),
    "settingsHistory" : MessageLookupByLibrary.simpleMessage("History"),
    "settingsHistoryDes" : MessageLookupByLibrary.simpleMessage("Listen date"),
    "settingsInfo" : MessageLookupByLibrary.simpleMessage("Info"),
    "settingsInterface" : MessageLookupByLibrary.simpleMessage("Interface"),
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
    "settingsNetworkCellularDes" : MessageLookupByLibrary.simpleMessage("Ask to confirm when using cellulae data to download episodes"),
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
    "settingsStorageDes" : MessageLookupByLibrary.simpleMessage("Manange cache and download storage"),
    "settingsSyncing" : MessageLookupByLibrary.simpleMessage("Syncing"),
    "settingsSyncingDes" : MessageLookupByLibrary.simpleMessage("Refresh podcasts in the background"),
    "settingsTheme" : MessageLookupByLibrary.simpleMessage("Theme"),
    "settingsUpdateInterval" : MessageLookupByLibrary.simpleMessage("Update interval"),
    "settingsUpdateIntervalDes" : MessageLookupByLibrary.simpleMessage("Default 24 hours"),
    "size" : MessageLookupByLibrary.simpleMessage("Size"),
    "sleepTimer" : MessageLookupByLibrary.simpleMessage("Sleep timer"),
    "subscribe" : MessageLookupByLibrary.simpleMessage("Subscribe"),
    "systemDefault" : MessageLookupByLibrary.simpleMessage("System default"),
    "timeLastPlayed" : m12,
    "timeLeft" : m13,
    "to" : MessageLookupByLibrary.simpleMessage("To"),
    "toastAddPlaylist" : MessageLookupByLibrary.simpleMessage("Added to playlist"),
    "toastDescovery" : MessageLookupByLibrary.simpleMessage("Discovery feature reopened, pleast restart the app"),
    "toastFileError" : MessageLookupByLibrary.simpleMessage("File error, Subscribe failed"),
    "toastFileNotVilid" : MessageLookupByLibrary.simpleMessage("File not vilid"),
    "toastReadFile" : MessageLookupByLibrary.simpleMessage("Read file successfully"),
    "toastRemovePlaylist" : MessageLookupByLibrary.simpleMessage("Removed from playlist"),
    "understood" : MessageLookupByLibrary.simpleMessage("Understood"),
    "unlike" : MessageLookupByLibrary.simpleMessage("Unlike"),
    "unliked" : MessageLookupByLibrary.simpleMessage("Removed from favorite"),
    "updateDate" : MessageLookupByLibrary.simpleMessage("Update date"),
    "updateEpisodesCount" : m14,
    "updateFailed" : MessageLookupByLibrary.simpleMessage("Update failed, network error"),
    "version" : m15
  };
}
