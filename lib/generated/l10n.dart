// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: 'Subscribe new podcast',
      args: [],
    );
  }

  /// `{count, plural, zero{} one{{count} episode in {groupName} added to playlist} other{{count} episodes in {groupName} added to playlist}}`
  String addEpisodeGroup(Object groupName, num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '$count episode in $groupName added to playlist',
      other: '$count episodes in $groupName added to playlist',
      name: 'addEpisodeGroup',
      desc: '',
      args: [groupName, count],
    );
  }

  /// `{count, plural, zero{} one{{count} episode added to playlist} other{{count} episodes added to playlist}}`
  String addNewEpisodeAll(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '$count episode added to playlist',
      other: '$count episodes added to playlist',
      name: 'addNewEpisodeAll',
      desc: '',
      args: [count],
    );
  }

  /// `Add new episodes to playlist`
  String get addNewEpisodeTooltip {
    return Intl.message(
      'Add new episodes to playlist',
      name: 'addNewEpisodeTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Add some groups`
  String get addSomeGroups {
    return Intl.message(
      'Add some groups',
      name: 'addSomeGroups',
      desc: 'Please add new groups',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Auto download`
  String get autoDownload {
    return Intl.message(
      'Auto download',
      name: 'autoDownload',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Buffering`
  String get buffering {
    return Intl.message(
      'Buffering',
      name: 'buffering',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get cancel {
    return Intl.message(
      'CANCEL',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Change layout`
  String get changeLayout {
    return Intl.message(
      'Change layout',
      name: 'changeLayout',
      desc: '',
      args: [],
    );
  }

  /// `Changelog`
  String get changelog {
    return Intl.message(
      'Changelog',
      name: 'changelog',
      desc: '',
      args: [],
    );
  }

  /// `Choose a`
  String get chooseA {
    return Intl.message(
      'Choose a',
      name: 'chooseA',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `color`
  String get color {
    return Intl.message(
      'color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM`
  String get confirm {
    return Intl.message(
      'CONFIRM',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message(
      'Dark mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{Today} one{{count} day ago} other{{count} days ago}}`
  String daysAgo(num count) {
    return Intl.plural(
      count,
      zero: 'Today',
      one: '$count day ago',
      other: '$count days ago',
      name: 'daysAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, zero{Never} one{{count} day} other{{count} days}}`
  String daysCount(num count) {
    return Intl.plural(
      count,
      zero: 'Never',
      one: '$count day',
      other: '$count days',
      name: 'daysCount',
      desc: '',
      args: [count],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Developer`
  String get developer {
    return Intl.message(
      'Developer',
      name: 'developer',
      desc: 'Can also translate to About me',
      args: [],
    );
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get downloaded {
    return Intl.message(
      'Downloaded',
      name: 'downloaded',
      desc: '',
      args: [],
    );
  }

  /// `Edit group name`
  String get editGroupName {
    return Intl.message(
      'Edit group name',
      name: 'editGroupName',
      desc: '',
      args: [],
    );
  }

  /// `End of Episode`
  String get endOfEpisode {
    return Intl.message(
      'End of Episode',
      name: 'endOfEpisode',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{} one{Episode} other{Episodes}}`
  String episode(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: 'Episode',
      other: 'Episodes',
      name: 'episode',
      desc: '',
      args: [count],
    );
  }

  /// `Tap to edit group`
  String get featureDiscoveryEditGroup {
    return Intl.message(
      'Tap to edit group',
      name: 'featureDiscoveryEditGroup',
      desc: '',
      args: [],
    );
  }

  /// `You can change group name or delete group here, but home group can not be edited or deleted`
  String get featureDiscoveryEditGroupDes {
    return Intl.message(
      'You can change group name or delete group here, but home group can not be edited or deleted',
      name: 'featureDiscoveryEditGroupDes',
      desc: '',
      args: [],
    );
  }

  /// `Episode view`
  String get featureDiscoveryEpisode {
    return Intl.message(
      'Episode view',
      name: 'featureDiscoveryEpisode',
      desc: '',
      args: [],
    );
  }

  /// `You can long tap to play episode or add episode to playlist.`
  String get featureDiscoveryEpisodeDes {
    return Intl.message(
      'You can long tap to play episode or add episode to playlist.',
      name: 'featureDiscoveryEpisodeDes',
      desc: '',
      args: [],
    );
  }

  /// `Long tap to play episode instantly`
  String get featureDiscoveryEpisodeTitle {
    return Intl.message(
      'Long tap to play episode instantly',
      name: 'featureDiscoveryEpisodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap to add group`
  String get featureDiscoveryGroup {
    return Intl.message(
      'Tap to add group',
      name: 'featureDiscoveryGroup',
      desc: '',
      args: [],
    );
  }

  /// `Default group is home for new podcast, you can create new group and move podcast to new group, podcast can be added to multi-groups.`
  String get featureDiscoveryGroupDes {
    return Intl.message(
      'Default group is home for new podcast, you can create new group and move podcast to new group, podcast can be added to multi-groups.',
      name: 'featureDiscoveryGroupDes',
      desc: '',
      args: [],
    );
  }

  /// `Long tap to reorder podcast`
  String get featureDiscoveryGroupPodcast {
    return Intl.message(
      'Long tap to reorder podcast',
      name: 'featureDiscoveryGroupPodcast',
      desc: '',
      args: [],
    );
  }

  /// `You can tap to see more options, or long tap to reorder podcast in group.`
  String get featureDiscoveryGroupPodcastDes {
    return Intl.message(
      'You can tap to see more options, or long tap to reorder podcast in group.',
      name: 'featureDiscoveryGroupPodcastDes',
      desc: '',
      args: [],
    );
  }

  /// `Tap to import OMPL`
  String get featureDiscoveryOMPL {
    return Intl.message(
      'Tap to import OMPL',
      name: 'featureDiscoveryOMPL',
      desc: '',
      args: [],
    );
  }

  /// `You can import OMPL file, open setting or refresh all podcast at once here.`
  String get featureDiscoveryOMPLDes {
    return Intl.message(
      'You can import OMPL file, open setting or refresh all podcast at once here.',
      name: 'featureDiscoveryOMPLDes',
      desc: '',
      args: [],
    );
  }

  /// `Tap to open playlist`
  String get featureDiscoveryPlaylist {
    return Intl.message(
      'Tap to open playlist',
      name: 'featureDiscoveryPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `You can add episode to playlist by yourself. Episode will be auto removed from playlist when played.`
  String get featureDiscoveryPlaylistDes {
    return Intl.message(
      'You can add episode to playlist by yourself. Episode will be auto removed from playlist when played.',
      name: 'featureDiscoveryPlaylistDes',
      desc: '',
      args: [],
    );
  }

  /// `Podcast view`
  String get featureDiscoveryPodcast {
    return Intl.message(
      'Podcast view',
      name: 'featureDiscoveryPodcast',
      desc: '',
      args: [],
    );
  }

  /// `You can tap See All to add groups or manage podcasts.`
  String get featureDiscoveryPodcastDes {
    return Intl.message(
      'You can tap See All to add groups or manage podcasts.',
      name: 'featureDiscoveryPodcastDes',
      desc: '',
      args: [],
    );
  }

  /// `Scroll vertically to switch groups`
  String get featureDiscoveryPodcastTitle {
    return Intl.message(
      'Scroll vertically to switch groups',
      name: 'featureDiscoveryPodcastTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap to search podcast`
  String get featureDiscoverySearch {
    return Intl.message(
      'Tap to search podcast',
      name: 'featureDiscoverySearch',
      desc: '',
      args: [],
    );
  }

  /// `You can search podcast title , key word or RSS link to subscribe new podcast.`
  String get featureDiscoverySearchDes {
    return Intl.message(
      'You can search podcast title , key word or RSS link to subscribe new podcast.',
      name: 'featureDiscoverySearchDes',
      desc: '',
      args: [],
    );
  }

  /// `Write to me`
  String get feedbackEmail {
    return Intl.message(
      'Write to me',
      name: 'feedbackEmail',
      desc: '',
      args: [],
    );
  }

  /// `Submit issue`
  String get feedbackGithub {
    return Intl.message(
      'Submit issue',
      name: 'feedbackGithub',
      desc: '',
      args: [],
    );
  }

  /// `Rate on Play`
  String get feedbackPlay {
    return Intl.message(
      'Rate on Play',
      name: 'feedbackPlay',
      desc: '',
      args: [],
    );
  }

  /// `Join group`
  String get feedbackTelegram {
    return Intl.message(
      'Join group',
      name: 'feedbackTelegram',
      desc: '',
      args: [],
    );
  }

  /// `Fonts`
  String get fonts {
    return Intl.message(
      'Fonts',
      name: 'fonts',
      desc: '',
      args: [],
    );
  }

  /// `From {time}`
  String from(Object time) {
    return Intl.message(
      'From $time',
      name: 'from',
      desc: '',
      args: [time],
    );
  }

  /// `Good Night`
  String get goodNight {
    return Intl.message(
      'Good Night',
      name: 'goodNight',
      desc: '',
      args: [],
    );
  }

  /// `Group existed`
  String get groupExisted {
    return Intl.message(
      'Group existed',
      name: 'groupExisted',
      desc: '',
      args: [],
    );
  }

  /// `Group filter`
  String get groupFilter {
    return Intl.message(
      'Group filter',
      name: 'groupFilter',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this group? Podcasts will be moved to Home group.`
  String get groupRemoveConfirm {
    return Intl.message(
      'Are you sure you want to delete this group? Podcasts will be moved to Home group.',
      name: 'groupRemoveConfirm',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{Group} one{Group} other{Groups}}`
  String groups(num count) {
    return Intl.plural(
      count,
      zero: 'Group',
      one: 'Group',
      other: 'Groups',
      name: 'groups',
      desc: '',
      args: [count],
    );
  }

  /// `See All`
  String get homeGroupsSeeAll {
    return Intl.message(
      'See All',
      name: 'homeGroupsSeeAll',
      desc: '',
      args: [],
    );
  }

  /// `Playlist`
  String get homeMenuPlaylist {
    return Intl.message(
      'Playlist',
      name: 'homeMenuPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get homeSubMenuSortBy {
    return Intl.message(
      'Sort by',
      name: 'homeSubMenuSortBy',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get homeTabMenuFavotite {
    return Intl.message(
      'Favorite',
      name: 'homeTabMenuFavotite',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get homeTabMenuRecent {
    return Intl.message(
      'Recent',
      name: 'homeTabMenuRecent',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get homeToprightMenuAbout {
    return Intl.message(
      'About',
      name: 'homeToprightMenuAbout',
      desc: '',
      args: [],
    );
  }

  /// `Import OMPL`
  String get homeToprightMenuImportOMPL {
    return Intl.message(
      'Import OMPL',
      name: 'homeToprightMenuImportOMPL',
      desc: '',
      args: [],
    );
  }

  /// `Refresh all`
  String get homeToprightMenuRefreshAll {
    return Intl.message(
      'Refresh all',
      name: 'homeToprightMenuRefreshAll',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get homeToprightMenuSettings {
    return Intl.message(
      'Settings',
      name: 'homeToprightMenuSettings',
      desc: '',
      args: [],
    );
  }

  /// `Hosted on {host}`
  String hostedOn(Object host) {
    return Intl.message(
      'Hosted on $host',
      name: 'hostedOn',
      desc: '',
      args: [host],
    );
  }

  /// `{count, plural, zero{In an hour} one{{count} hour ago} other{{count} hours ago}}`
  String hoursAgo(num count) {
    return Intl.plural(
      count,
      zero: 'In an hour',
      one: '$count hour ago',
      other: '$count hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, zero{} one{{count} hour} other{{count} hours}}`
  String hoursCount(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '$count hour',
      other: '$count hours',
      name: 'hoursCount',
      desc: '',
      args: [count],
    );
  }

  /// `Long press on episode card for quick actions.`
  String get introFourthPage {
    return Intl.message(
      'Long press on episode card for quick actions.',
      name: 'introFourthPage',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe podcast via search or import OMPL file.`
  String get introSecondPage {
    return Intl.message(
      'Subscribe podcast via search or import OMPL file.',
      name: 'introSecondPage',
      desc: '',
      args: [],
    );
  }

  /// `You can create new group for podcasts, swipe on podcast list to change group.`
  String get introThirdPage {
    return Intl.message(
      'You can create new group for podcasts, swipe on podcast list to change group.',
      name: 'introThirdPage',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get later {
    return Intl.message(
      'Later',
      name: 'later',
      desc: '',
      args: [],
    );
  }

  /// `Light mode`
  String get lightMode {
    return Intl.message(
      'Light mode',
      name: 'lightMode',
      desc: '',
      args: [],
    );
  }

  /// `Like`
  String get like {
    return Intl.message(
      'Like',
      name: 'like',
      desc: '',
      args: [],
    );
  }

  /// `Liked`
  String get liked {
    return Intl.message(
      'Liked',
      name: 'liked',
      desc: '',
      args: [],
    );
  }

  /// `Like date`
  String get likeDate {
    return Intl.message(
      'Like date',
      name: 'likeDate',
      desc: '',
      args: [],
    );
  }

  /// `Listen`
  String get listen {
    return Intl.message(
      'Listen',
      name: 'listen',
      desc: '',
      args: [],
    );
  }

  /// `Listened`
  String get listened {
    return Intl.message(
      'Listened',
      name: 'listened',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get loadMore {
    return Intl.message(
      'Load more',
      name: 'loadMore',
      desc: '',
      args: [],
    );
  }

  /// `Mark`
  String get mark {
    return Intl.message(
      'Mark',
      name: 'mark',
      desc: 'The short the best',
      args: [],
    );
  }

  /// `Mark confirm`
  String get markConfirm {
    return Intl.message(
      'Mark confirm',
      name: 'markConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Confirm mark all episodes listened?`
  String get markConfirmContent {
    return Intl.message(
      'Confirm mark all episodes listened?',
      name: 'markConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `Mark listened`
  String get markListened {
    return Intl.message(
      'Mark listened',
      name: 'markListened',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
  }

  /// `All podcasts`
  String get menuAllPodcasts {
    return Intl.message(
      'All podcasts',
      name: 'menuAllPodcasts',
      desc: '',
      args: [],
    );
  }

  /// `Mark All Listened`
  String get menuMarkAllListened {
    return Intl.message(
      'Mark All Listened',
      name: 'menuMarkAllListened',
      desc: '',
      args: [],
    );
  }

  /// `Visit RSS Feed`
  String get menuViewRSS {
    return Intl.message(
      'Visit RSS Feed',
      name: 'menuViewRSS',
      desc: '',
      args: [],
    );
  }

  /// `Visit Site`
  String get menuVisitSite {
    return Intl.message(
      'Visit Site',
      name: 'menuVisitSite',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{} one{{count} minute ago} other{{count} minutes ago}}`
  String minsAgo(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '$count minute ago',
      other: '$count minutes ago',
      name: 'minsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, zero{} one{{count} min} other{{count} mins}}`
  String minsCount(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '$count min',
      other: '$count mins',
      name: 'minsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Network`
  String get network {
    return Intl.message(
      'Network',
      name: 'network',
      desc: '',
      args: [],
    );
  }

  /// `Newest first`
  String get newestFirst {
    return Intl.message(
      'Newest first',
      name: 'newestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Create new group`
  String get newGroup {
    return Intl.message(
      'Create new group',
      name: 'newGroup',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `No episode downloaded yet`
  String get noEpisodeDownload {
    return Intl.message(
      'No episode downloaded yet',
      name: 'noEpisodeDownload',
      desc: '',
      args: [],
    );
  }

  /// `No episode collected yet`
  String get noEpisodeFavorite {
    return Intl.message(
      'No episode collected yet',
      name: 'noEpisodeFavorite',
      desc: '',
      args: [],
    );
  }

  /// `No episode received yet`
  String get noEpisodeRecent {
    return Intl.message(
      'No episode received yet',
      name: 'noEpisodeRecent',
      desc: '',
      args: [],
    );
  }

  /// `No podcast in this group`
  String get noPodcastGroup {
    return Intl.message(
      'No podcast in this group',
      name: 'noPodcastGroup',
      desc: '',
      args: [],
    );
  }

  /// `Still no show notes received \nfor this episode.`
  String get noShownote {
    return Intl.message(
      'Still no show notes received \nfor this episode.',
      name: 'noShownote',
      desc: 'Means this episode have no show notes.',
      args: [],
    );
  }

  /// `Fetch data {title}`
  String notificaitonFatch(Object title) {
    return Intl.message(
      'Fetch data $title',
      name: 'notificaitonFatch',
      desc: '',
      args: [title],
    );
  }

  /// `Subscribe failed, network error {title}`
  String notificationNetworkError(Object title) {
    return Intl.message(
      'Subscribe failed, network error $title',
      name: 'notificationNetworkError',
      desc: '',
      args: [title],
    );
  }

  /// `Subscribe {title}`
  String notificationSubscribe(Object title) {
    return Intl.message(
      'Subscribe $title',
      name: 'notificationSubscribe',
      desc: '',
      args: [title],
    );
  }

  /// `Subscribe failed, podcast existed {title}`
  String notificationSubscribeExisted(Object title) {
    return Intl.message(
      'Subscribe failed, podcast existed $title',
      name: 'notificationSubscribeExisted',
      desc: '',
      args: [title],
    );
  }

  /// `Subscribe success {title}`
  String notificationSuccess(Object title) {
    return Intl.message(
      'Subscribe success $title',
      name: 'notificationSuccess',
      desc: '',
      args: [title],
    );
  }

  /// `Update {title}`
  String notificationUpdate(Object title) {
    return Intl.message(
      'Update $title',
      name: 'notificationUpdate',
      desc: '',
      args: [title],
    );
  }

  /// `Update error {title}`
  String notificationUpdateError(Object title) {
    return Intl.message(
      'Update error $title',
      name: 'notificationUpdateError',
      desc: '',
      args: [title],
    );
  }

  /// `Oldest first`
  String get oldestFirst {
    return Intl.message(
      'Oldest first',
      name: 'oldestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Playing`
  String get playing {
    return Intl.message(
      'Playing',
      name: 'playing',
      desc: '',
      args: [],
    );
  }

  /// `Plugins`
  String get plugins {
    return Intl.message(
      'Plugins',
      name: 'plugins',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{} one{Podcast} other{Podcasts}}`
  String podcast(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: 'Podcast',
      other: 'Podcasts',
      name: 'podcast',
      desc: '',
      args: [count],
    );
  }

  /// `Podcast subscribed`
  String get podcastSubscribed {
    return Intl.message(
      'Podcast subscribed',
      name: 'podcastSubscribed',
      desc: '',
      args: [],
    );
  }

  /// `Download episode`
  String get popupMenuDownloadDes {
    return Intl.message(
      'Download episode',
      name: 'popupMenuDownloadDes',
      desc: '',
      args: [],
    );
  }

  /// `Add episode to playlist`
  String get popupMenuLaterDes {
    return Intl.message(
      'Add episode to playlist',
      name: 'popupMenuLaterDes',
      desc: '',
      args: [],
    );
  }

  /// `Add episode to favorite`
  String get popupMenuLikeDes {
    return Intl.message(
      'Add episode to favorite',
      name: 'popupMenuLikeDes',
      desc: '',
      args: [],
    );
  }

  /// `Mark episode as listened`
  String get popupMenuMarkDes {
    return Intl.message(
      'Mark episode as listened',
      name: 'popupMenuMarkDes',
      desc: '',
      args: [],
    );
  }

  /// `Play the episode`
  String get popupMenuPlayDes {
    return Intl.message(
      'Play the episode',
      name: 'popupMenuPlayDes',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Published at {date}`
  String published(Object date) {
    return Intl.message(
      'Published at $date',
      name: 'published',
      desc: '',
      args: [date],
    );
  }

  /// `Recover subscribe`
  String get recoverSubscribe {
    return Intl.message(
      'Recover subscribe',
      name: 'recoverSubscribe',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Remove confirm`
  String get removeConfirm {
    return Intl.message(
      'Remove confirm',
      name: 'removeConfirm',
      desc: 'unsubscribe podcast dialog',
      args: [],
    );
  }

  /// `Removed at {date}`
  String removedAt(Object date) {
    return Intl.message(
      'Removed at $date',
      name: 'removedAt',
      desc: 'For example ：Removed at 2020.10.10',
      args: [date],
    );
  }

  /// `Are you sure you want to unsubscribe?`
  String get removePodcastDes {
    return Intl.message(
      'Are you sure you want to unsubscribe?',
      name: 'removePodcastDes',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get schedule {
    return Intl.message(
      'Schedule',
      name: 'schedule',
      desc: '',
      args: [],
    );
  }

  /// `Invalid RSS link`
  String get searchInvalidRss {
    return Intl.message(
      'Invalid RSS link',
      name: 'searchInvalidRss',
      desc: '',
      args: [],
    );
  }

  /// `Search podcast`
  String get searchPodcast {
    return Intl.message(
      'Search podcast',
      name: 'searchPodcast',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{} one{{count} second ago} other{{count} seconds ago}}`
  String secondsAgo(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '$count second ago',
      other: '$count seconds ago',
      name: 'secondsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Accent color`
  String get settingsAccentColor {
    return Intl.message(
      'Accent color',
      name: 'settingsAccentColor',
      desc: '',
      args: [],
    );
  }

  /// `Include the ovelay color`
  String get settingsAccentColorDes {
    return Intl.message(
      'Include the ovelay color',
      name: 'settingsAccentColorDes',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get settingsAppearance {
    return Intl.message(
      'Appearance',
      name: 'settingsAppearance',
      desc: '',
      args: [],
    );
  }

  /// `Colors and themes`
  String get settingsAppearanceDes {
    return Intl.message(
      'Colors and themes',
      name: 'settingsAppearanceDes',
      desc: '',
      args: [],
    );
  }

  /// `App Intro`
  String get settingsAppIntro {
    return Intl.message(
      'App Intro',
      name: 'settingsAppIntro',
      desc: '',
      args: [],
    );
  }

  /// `Audio cache`
  String get settingsAudioCache {
    return Intl.message(
      'Audio cache',
      name: 'settingsAudioCache',
      desc: '',
      args: [],
    );
  }

  /// `Audio cache max size`
  String get settingsAudioCacheDes {
    return Intl.message(
      'Audio cache max size',
      name: 'settingsAudioCacheDes',
      desc: '',
      args: [],
    );
  }

  /// `Auto delete downloads after`
  String get settingsAutoDelete {
    return Intl.message(
      'Auto delete downloads after',
      name: 'settingsAutoDelete',
      desc: '',
      args: [],
    );
  }

  /// `Default 30 days`
  String get settingsAutoDeleteDes {
    return Intl.message(
      'Default 30 days',
      name: 'settingsAutoDeleteDes',
      desc: '',
      args: [],
    );
  }

  /// `Auto play next episode in playlist`
  String get settingsAutoPlayDes {
    return Intl.message(
      'Auto play next episode in playlist',
      name: 'settingsAutoPlayDes',
      desc: '',
      args: [],
    );
  }

  /// `Default grid view`
  String get settingsDefaultGrid {
    return Intl.message(
      'Default grid view',
      name: 'settingsDefaultGrid',
      desc: '',
      args: [],
    );
  }

  /// `Download tab`
  String get settingsDefaultGridDownload {
    return Intl.message(
      'Download tab',
      name: 'settingsDefaultGridDownload',
      desc: '',
      args: [],
    );
  }

  /// `Favorite tab`
  String get settingsDefaultGridFavorite {
    return Intl.message(
      'Favorite tab',
      name: 'settingsDefaultGridFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Podcast page`
  String get settingsDefaultGridPodcast {
    return Intl.message(
      'Podcast page',
      name: 'settingsDefaultGridPodcast',
      desc: '',
      args: [],
    );
  }

  /// `Recent tab`
  String get settingsDefaultGridRecent {
    return Intl.message(
      'Recent tab',
      name: 'settingsDefaultGridRecent',
      desc: '',
      args: [],
    );
  }

  /// `Discovery Features Again`
  String get settingsDiscovery {
    return Intl.message(
      'Discovery Features Again',
      name: 'settingsDiscovery',
      desc: '',
      args: [],
    );
  }

  /// `Enable Syncing`
  String get settingsEnableSyncing {
    return Intl.message(
      'Enable Syncing',
      name: 'settingsEnableSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Refresh all podcasts in the background to get leatest episodes`
  String get settingsEnableSyncingDes {
    return Intl.message(
      'Refresh all podcasts in the background to get leatest episodes',
      name: 'settingsEnableSyncingDes',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get settingsExport {
    return Intl.message(
      'Export',
      name: 'settingsExport',
      desc: '',
      args: [],
    );
  }

  /// `Export OMPL file of all podcasts`
  String get settingsExportDes {
    return Intl.message(
      'Export OMPL file of all podcasts',
      name: 'settingsExportDes',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get settingsFeedback {
    return Intl.message(
      'Feedback',
      name: 'settingsFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Bugs and features request`
  String get settingsFeedbackDes {
    return Intl.message(
      'Bugs and features request',
      name: 'settingsFeedbackDes',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get settingsHistory {
    return Intl.message(
      'History',
      name: 'settingsHistory',
      desc: '',
      args: [],
    );
  }

  /// `Listen date`
  String get settingsHistoryDes {
    return Intl.message(
      'Listen date',
      name: 'settingsHistoryDes',
      desc: '',
      args: [],
    );
  }

  /// `Info`
  String get settingsInfo {
    return Intl.message(
      'Info',
      name: 'settingsInfo',
      desc: '',
      args: [],
    );
  }

  /// `Interface`
  String get settingsInterface {
    return Intl.message(
      'Interface',
      name: 'settingsInterface',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get settingsLanguages {
    return Intl.message(
      'Languages',
      name: 'settingsLanguages',
      desc: '',
      args: [],
    );
  }

  /// `Change language`
  String get settingsLanguagesDes {
    return Intl.message(
      'Change language',
      name: 'settingsLanguagesDes',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get settingsLayout {
    return Intl.message(
      'Layout',
      name: 'settingsLayout',
      desc: '',
      args: [],
    );
  }

  /// `App layout`
  String get settingsLayoutDes {
    return Intl.message(
      'App layout',
      name: 'settingsLayoutDes',
      desc: '',
      args: [],
    );
  }

  /// `Libraries`
  String get settingsLibraries {
    return Intl.message(
      'Libraries',
      name: 'settingsLibraries',
      desc: '',
      args: [],
    );
  }

  /// `Open source libraries used in app`
  String get settingsLibrariesDes {
    return Intl.message(
      'Open source libraries used in app',
      name: 'settingsLibrariesDes',
      desc: '',
      args: [],
    );
  }

  /// `Manage download`
  String get settingsManageDownload {
    return Intl.message(
      'Manage download',
      name: 'settingsManageDownload',
      desc: '',
      args: [],
    );
  }

  /// `Manage downloaded audio files`
  String get settingsManageDownloadDes {
    return Intl.message(
      'Manage downloaded audio files',
      name: 'settingsManageDownloadDes',
      desc: '',
      args: [],
    );
  }

  /// `Auto play next`
  String get settingsMenuAutoPlay {
    return Intl.message(
      'Auto play next',
      name: 'settingsMenuAutoPlay',
      desc: '',
      args: [],
    );
  }

  /// `Ask before using cellular data`
  String get settingsNetworkCellular {
    return Intl.message(
      'Ask before using cellular data',
      name: 'settingsNetworkCellular',
      desc: '',
      args: [],
    );
  }

  /// `Auto download using cellular data`
  String get settingsNetworkCellularAuto {
    return Intl.message(
      'Auto download using cellular data',
      name: 'settingsNetworkCellularAuto',
      desc: '',
      args: [],
    );
  }

  /// `You can set podcast auto download in group manage page`
  String get settingsNetworkCellularAutoDes {
    return Intl.message(
      'You can set podcast auto download in group manage page',
      name: 'settingsNetworkCellularAutoDes',
      desc: '',
      args: [],
    );
  }

  /// `Ask to confirm when using cellulae data to download episodes`
  String get settingsNetworkCellularDes {
    return Intl.message(
      'Ask to confirm when using cellulae data to download episodes',
      name: 'settingsNetworkCellularDes',
      desc: '',
      args: [],
    );
  }

  /// `Playlist and player`
  String get settingsPlayDes {
    return Intl.message(
      'Playlist and player',
      name: 'settingsPlayDes',
      desc: '',
      args: [],
    );
  }

  /// `Episodes popup menu`
  String get settingsPopupMenu {
    return Intl.message(
      'Episodes popup menu',
      name: 'settingsPopupMenu',
      desc: '',
      args: [],
    );
  }

  /// `Change the popup menu of episode`
  String get settingsPopupMenuDes {
    return Intl.message(
      'Change the popup menu of episode',
      name: 'settingsPopupMenuDes',
      desc: '',
      args: [],
    );
  }

  /// `Prefrence`
  String get settingsPrefrence {
    return Intl.message(
      'Prefrence',
      name: 'settingsPrefrence',
      desc: '',
      args: [],
    );
  }

  /// `Real dark`
  String get settingsRealDark {
    return Intl.message(
      'Real dark',
      name: 'settingsRealDark',
      desc: '',
      args: [],
    );
  }

  /// `Turn on if you think the night is not dark enough`
  String get settingsRealDarkDes {
    return Intl.message(
      'Turn on if you think the night is not dark enough',
      name: 'settingsRealDarkDes',
      desc: '',
      args: [],
    );
  }

  /// `Auto turn on sleep timer`
  String get settingsSTAuto {
    return Intl.message(
      'Auto turn on sleep timer',
      name: 'settingsSTAuto',
      desc: '',
      args: [],
    );
  }

  /// `Auto start sleep timer at scheduled time`
  String get settingsSTAutoDes {
    return Intl.message(
      'Auto start sleep timer at scheduled time',
      name: 'settingsSTAutoDes',
      desc: '',
      args: [],
    );
  }

  /// `Default time`
  String get settingsSTDefaultTime {
    return Intl.message(
      'Default time',
      name: 'settingsSTDefaultTime',
      desc: '',
      args: [],
    );
  }

  /// `Default time for sleep timer`
  String get settingsSTDefautTimeDes {
    return Intl.message(
      'Default time for sleep timer',
      name: 'settingsSTDefautTimeDes',
      desc: '',
      args: [],
    );
  }

  /// `Auto sleep timer mode`
  String get settingsSTMode {
    return Intl.message(
      'Auto sleep timer mode',
      name: 'settingsSTMode',
      desc: '',
      args: [],
    );
  }

  /// `Manange cache and download storage`
  String get settingsStorageDes {
    return Intl.message(
      'Manange cache and download storage',
      name: 'settingsStorageDes',
      desc: '',
      args: [],
    );
  }

  /// `Syncing`
  String get settingsSyncing {
    return Intl.message(
      'Syncing',
      name: 'settingsSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Refresh podcasts in the background`
  String get settingsSyncingDes {
    return Intl.message(
      'Refresh podcasts in the background',
      name: 'settingsSyncingDes',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get settingsTheme {
    return Intl.message(
      'Theme',
      name: 'settingsTheme',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get settingStorage {
    return Intl.message(
      'Storage',
      name: 'settingStorage',
      desc: '',
      args: [],
    );
  }

  /// `Update interval`
  String get settingsUpdateInterval {
    return Intl.message(
      'Update interval',
      name: 'settingsUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `Default 24 hours`
  String get settingsUpdateIntervalDes {
    return Intl.message(
      'Default 24 hours',
      name: 'settingsUpdateIntervalDes',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get size {
    return Intl.message(
      'Size',
      name: 'size',
      desc: '',
      args: [],
    );
  }

  /// `Skip seconds at start`
  String get skipSecondsAtStart {
    return Intl.message(
      'Skip seconds at start',
      name: 'skipSecondsAtStart',
      desc: '',
      args: [],
    );
  }

  /// `Sleep timer`
  String get sleepTimer {
    return Intl.message(
      'Sleep timer',
      name: 'sleepTimer',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  /// `System default`
  String get systemDefault {
    return Intl.message(
      'System default',
      name: 'systemDefault',
      desc: '',
      args: [],
    );
  }

  /// `Last time {time}`
  String timeLastPlayed(Object time) {
    return Intl.message(
      'Last time $time',
      name: 'timeLastPlayed',
      desc: '',
      args: [time],
    );
  }

  /// `{time} Left`
  String timeLeft(Object time) {
    return Intl.message(
      '$time Left',
      name: 'timeLeft',
      desc: '',
      args: [time],
    );
  }

  /// `To {time}`
  String to(Object time) {
    return Intl.message(
      'To $time',
      name: 'to',
      desc: '',
      args: [time],
    );
  }

  /// `Added to playlist`
  String get toastAddPlaylist {
    return Intl.message(
      'Added to playlist',
      name: 'toastAddPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `Discovery feature reopened, pleast restart the app`
  String get toastDiscovery {
    return Intl.message(
      'Discovery feature reopened, pleast restart the app',
      name: 'toastDiscovery',
      desc: '',
      args: [],
    );
  }

  /// `File error, subscribe failed`
  String get toastFileError {
    return Intl.message(
      'File error, subscribe failed',
      name: 'toastFileError',
      desc: '',
      args: [],
    );
  }

  /// `File not valid`
  String get toastFileNotValid {
    return Intl.message(
      'File not valid',
      name: 'toastFileNotValid',
      desc: '',
      args: [],
    );
  }

  /// `Home group is not supported`
  String get toastHomeGroupNotSupport {
    return Intl.message(
      'Home group is not supported',
      name: 'toastHomeGroupNotSupport',
      desc: '',
      args: [],
    );
  }

  /// `At least select one group`
  String get toastOneGroup {
    return Intl.message(
      'At least select one group',
      name: 'toastOneGroup',
      desc: '',
      args: [],
    );
  }

  /// `Recovering, wait for a moment`
  String get toastPodcastRecovering {
    return Intl.message(
      'Recovering, wait for a moment',
      name: 'toastPodcastRecovering',
      desc: 'Resubscribe removed podcast',
      args: [],
    );
  }

  /// `Read file successfully`
  String get toastReadFile {
    return Intl.message(
      'Read file successfully',
      name: 'toastReadFile',
      desc: '',
      args: [],
    );
  }

  /// `Podcast recover failed`
  String get toastRecoverFailed {
    return Intl.message(
      'Podcast recover failed',
      name: 'toastRecoverFailed',
      desc: 'Resubscribe removed podast',
      args: [],
    );
  }

  /// `Episode removed from playlist`
  String get toastRemovePlaylist {
    return Intl.message(
      'Episode removed from playlist',
      name: 'toastRemovePlaylist',
      desc: '',
      args: [],
    );
  }

  /// `Setting saved`
  String get toastSettingSaved {
    return Intl.message(
      'Setting saved',
      name: 'toastSettingSaved',
      desc: '',
      args: [],
    );
  }

  /// `Time is equal to end time`
  String get toastTimeEqualEnd {
    return Intl.message(
      'Time is equal to end time',
      name: 'toastTimeEqualEnd',
      desc: '',
      args: [],
    );
  }

  /// `Time is equal to start time`
  String get toastTimeEqualStart {
    return Intl.message(
      'Time is equal to start time',
      name: 'toastTimeEqualStart',
      desc: '',
      args: [],
    );
  }

  /// `Understood`
  String get understood {
    return Intl.message(
      'Understood',
      name: 'understood',
      desc: '',
      args: [],
    );
  }

  /// `UNDO`
  String get undo {
    return Intl.message(
      'UNDO',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  /// `Unlike`
  String get unlike {
    return Intl.message(
      'Unlike',
      name: 'unlike',
      desc: '',
      args: [],
    );
  }

  /// `Episode removed from favorite`
  String get unliked {
    return Intl.message(
      'Episode removed from favorite',
      name: 'unliked',
      desc: '',
      args: [],
    );
  }

  /// `Update date`
  String get updateDate {
    return Intl.message(
      'Update date',
      name: 'updateDate',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{No update} one{Updated {count} episode} other{Updated {count} episodes}}`
  String updateEpisodesCount(num count) {
    return Intl.plural(
      count,
      zero: 'No update',
      one: 'Updated $count episode',
      other: 'Updated $count episodes',
      name: 'updateEpisodesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Update failed, network error`
  String get updateFailed {
    return Intl.message(
      'Update failed, network error',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Version : {version}`
  String version(Object version) {
    return Intl.message(
      'Version : $version',
      name: 'version',
      desc: '',
      args: [version],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}