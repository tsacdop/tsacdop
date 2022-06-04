// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a el locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'el';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${count} επεισόδιο προστέθηκε στη λίστα ${groupName}', other: '${count} επεισόδια προστέθηκαν στη λίστα ${groupName}\n')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} επεισόδιο προστέθηκε στη λίστα', other: '${count} επεισόδια προστέθηκαν στη λίστα')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Σήμερα', one: '${count} μέρα πριν', other: '${count} μέρες πριν')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Ποτέ', one: '${count} μέρα', other: '${count} μέρες')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'Επεισόδιο', other: 'Επεισόδια')}";

  static String m5(time) => "Μέχρι ${time}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Ομάδα', one: 'Ομάδα', other: 'Ομάδες')}";

  static String m7(host) => "Φιλοξενούμενο στο ${host}";

  static String m8(count) =>
      "${Intl.plural(count, zero: 'Αυτή την ώρα', one: '${count} ώρα πριν', other: '${count} ώρες πριν')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: '0 ώρες', one: '${count} ώρα', other: '${count} ώρες')}";

  static String m10(service) => "Ενσωμάτωση με ${service}";

  static String m11(userName) => "Συνδεδεμένος/η ως ${userName}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Μόλις τώρα', one: '${count} λεπτό πριν', other: '${count} λεπτά πριν')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 λεπτά', one: '${count} λεπτό', other: '${count} λεπτά')}";

  static String m14(title) => "Λήψη δεδομένων ${title}";

  static String m15(title) => "Η εγγραφή επέτυχε, σφάλμα δικτύου ${title}";

  static String m16(title) => "Εγγραφή ${title}";

  static String m17(title) =>
      "Η εγγραφή επέτυχε, το podcast υπάρχει ήδη ${title}";

  static String m18(title) => "Επιτυχημένη εγγραφή ${title}";

  static String m19(title) => "Ενημέρωση ${title} ";

  static String m20(title) => "Σφάλμα ενημέρωσης ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcast')}";

  static String m22(date) => "Δημοσιεύτηκε στις ${date}";

  static String m23(date) => "Αφαιρέθηκε  στις ${date}";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 δευτ.', one: '${count} δευτ.', other: '${count} δευτ.')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Μόλις τώρα', one: '${count} δευτερόλεπτο πριν', other: '${count} δευτερόλεπτα πριν')}";

  static String m26(count) => "${count} επιλεγμένα";

  static String m27(time) => "Τελευταίος χρόνος ${time}";

  static String m28(time) => "${time} Απομένει";

  static String m29(time) => "Από ${time}";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'Καμία ενημέρωση', one: 'Ενημερώθηκε ${count} επεισόδιο', other: 'Ενημερώθηκαν ${count} επεισόδια')}";

  static String m31(version) => "Έκδοση: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Προσθήκη"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Προσθήκη νέων επεισοδίων σε λίστα"),
        "addSomeGroups":
            MessageLookupByLibrary.simpleMessage("Πρόσθεσε μερικές ομάδες"),
        "all": MessageLookupByLibrary.simpleMessage("Όλα"),
        "autoDownload": MessageLookupByLibrary.simpleMessage("Αυτόματη λήψη"),
        "back": MessageLookupByLibrary.simpleMessage("Πίσω"),
        "boostVolume": MessageLookupByLibrary.simpleMessage("Ενίσχυση έντασης"),
        "buffering": MessageLookupByLibrary.simpleMessage("Φόρτωση"),
        "cancel": MessageLookupByLibrary.simpleMessage("ΑΚΥΡΩΣΗ"),
        "cellularConfirm": MessageLookupByLibrary.simpleMessage(
            "Προειδοποίηση χρήσης δεδομένων"),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "Είσαι σίγουρος/η πως θες να κάνεις χρήση δεδομένων για τη λήψη;"),
        "changeLayout": MessageLookupByLibrary.simpleMessage("Αλλαγή διάταξης"),
        "changelog": MessageLookupByLibrary.simpleMessage("Αλλαγές"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Επέλεξε ένα"),
        "clear": MessageLookupByLibrary.simpleMessage("Εκάθαρση"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Εκκαθάριση όλων"),
        "color": MessageLookupByLibrary.simpleMessage("Χρώμα"),
        "confirm": MessageLookupByLibrary.simpleMessage("ΕΠΙΒΕΒΑΙΩΣΗ"),
        "createNewPlaylist": MessageLookupByLibrary.simpleMessage("Νέα λίστα"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Σκοτεινό θέμα"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(
            "Αυτή είναι η προκαθορισμένη ουρά, δεν μπορεί να αφαιρεθεί."),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Προκαθορισμένη μηχανή αναζήτησης podcast"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Επέλεξε την προκαθορισμένη μηχανή αναζήτησης podcast"),
        "delete": MessageLookupByLibrary.simpleMessage("Διαγραφή"),
        "developer": MessageLookupByLibrary.simpleMessage("Προγραμματιστής"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Παράβλεψη"),
        "done": MessageLookupByLibrary.simpleMessage("Έγινε"),
        "download": MessageLookupByLibrary.simpleMessage("Λήψεις"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("Η λήψη αφαιρέθηκε"),
        "downloadStart": MessageLookupByLibrary.simpleMessage("Λήψη"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Έγινε λήψη"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Επεξεργασία ονόματος ομάδας"),
        "endOfEpisode":
            MessageLookupByLibrary.simpleMessage("Τέλος επεισοδίου"),
        "episode": m4,
        "fastForward":
            MessageLookupByLibrary.simpleMessage("Γρήγορο γύρισμα μπροστά"),
        "fastRewind":
            MessageLookupByLibrary.simpleMessage("Γρήγορο γύρισμα πίσω "),
        "featureDiscoveryEditGroup": MessageLookupByLibrary.simpleMessage(
            "Πάτα για να επεξεργαστείς την ομάδα"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Εδώ μπορείς να αλλάξεις το όνομα της ομάδας ή να τη διαγράψεις, αλλά η Αρχική ομάδα δε μπορεί να επεξεργασθεί ή να διαγραφεί"),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Προβολή επεισοδίου"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Πάτα παρατεταμένα για να παίξεις το επεισόδιο ή να το προσθέσεις σε λίστα."),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Πάτα παρατεταμένα για να παίξεις το επεισόδιο τώρα"),
        "featureDiscoveryGroup": MessageLookupByLibrary.simpleMessage(
            "Πάτα για να προσθέσεις ομάδα"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "Η Αρχική ομάδα είναι η προεπιλεγμένη ομάδα για νέα podcast. Μπορείς να φτιάξεις νέες ομάδες και να μετακινήσεις podcast σε αυτές, καθώς και να προσθέσεις podcast σε πολλαπλές ομάδες."),
        "featureDiscoveryGroupPodcast": MessageLookupByLibrary.simpleMessage(
            "Πάτα παρατεταμένα για να ταξινομήσεις τα podcast"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Πάτα για να δεις περισσότερες επιλογές, ή πάτα παρατεταμένα για να ταξινομήσεις τα podcast σε όμαδα."),
        "featureDiscoveryOMPL":
            MessageLookupByLibrary.simpleMessage("Πάτα για την εισαγωγή OPML"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Εδώ μπορείς να εισάγεις αρχεία OPML, να ανοίξεις ρυθμίσεις ή να ανανεώσεις όλα τα podcast με τη μία."),
        "featureDiscoveryPlaylist":
            MessageLookupByLibrary.simpleMessage("Πάτα για άνοιγμα λίστας"),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Μπορείς να προσθέσεις επεισόδια σε λίστες από μόνος σου. Τα επεισόδια θα αφαιρούνται αυτόματα από τις λίστες αφού παιχτούν."),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Προβολή podcast"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Πάτα στο Προβολή Όλων για να προσθέσεις ομάδες ή να διαχειριστείς τα podcast."),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Σκρόλαρε κάθετα για εναλλαγή μεταξύ ομάδων"),
        "featureDiscoverySearch":
            MessageLookupByLibrary.simpleMessage("Πάτα για αναζήτηση podcast"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Μπορείς να αναζητήσεις με το τίτλο του podcast, λέξη κλειδί, ή να κάνεις χρήση ενός συνδέσμου RSS για να εγγραφείς σε ένα νέο podacast."),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("Γράψε μου"),
        "feedbackGithub": MessageLookupByLibrary.simpleMessage("GitHub"),
        "feedbackPlay":
            MessageLookupByLibrary.simpleMessage("Βαθμολόγηση στο PlayStore"),
        "feedbackTelegram":
            MessageLookupByLibrary.simpleMessage("Συμμετοχή στην ομάδα"),
        "filter": MessageLookupByLibrary.simpleMessage("Φίλτρο"),
        "fontStyle":
            MessageLookupByLibrary.simpleMessage("Στιλ γραμματοσειράς"),
        "fonts": MessageLookupByLibrary.simpleMessage("Γραμματοσειρές"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("Καληνύχτα"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Συγχαρητήρια! Έχετε συνδέσει το gpodder.net λογαριασμό σας με επιτυχία. Το Tsacdop θα συγχρονίσει αυτόματα τις εγγραφές στη συσκευή σας με το gpodder.net λογαριασμό σας."),
        "groupExisted":
            MessageLookupByLibrary.simpleMessage("Η ομάδα υπάρχει ήδη"),
        "groupFilter": MessageLookupByLibrary.simpleMessage("Φίλτρο ομάδων"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "Είσαι σίγουρος/η πως θες να διαγράψεις αυτή την ομάδα; Τα Podcast θα μεταφερθούν στην Αρχική ομάδα."),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Απόκρυψη ακουσμένων"),
        "hidePodcastDiscovery":
            MessageLookupByLibrary.simpleMessage("Απόκρυψη ανακάλυψης podcast"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Απόκρυψη ανακάλυψης podcast από τη σελίδα αναζήτησης"),
        "homeGroupsSeeAll":
            MessageLookupByLibrary.simpleMessage("Προβολή όλων"),
        "homeMenuPlaylist": MessageLookupByLibrary.simpleMessage("Λίστα"),
        "homeSubMenuSortBy":
            MessageLookupByLibrary.simpleMessage("Ταξινόμηση κατά"),
        "homeTabMenuFavotite":
            MessageLookupByLibrary.simpleMessage("Αγαπημένα"),
        "homeTabMenuRecent": MessageLookupByLibrary.simpleMessage("Πρόσφατο"),
        "homeToprightMenuAbout":
            MessageLookupByLibrary.simpleMessage("Σχετικά με"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("Εισαγωγή OPML"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Ανανέωση όλων"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("Εισαγωγή"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Πάτα παρατεταμένα στο επεισόδιο για γρήγορες ενέργειες."),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "Ανακάλυψε podcast μέσω αναζήτησης ή εισαγωγής αρχείου OPML."),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Μπορείς να φτιάξεις μία ομάδα για podcast."),
        "invalidName":
            MessageLookupByLibrary.simpleMessage("Εσφαλμένο όνομα χρήστη"),
        "lastUpdate":
            MessageLookupByLibrary.simpleMessage("Τελευταία ενημέρωση"),
        "later": MessageLookupByLibrary.simpleMessage("Αργότερα"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Φωτεινό θέμα"),
        "like": MessageLookupByLibrary.simpleMessage("Μου Αρέσει"),
        "likeDate":
            MessageLookupByLibrary.simpleMessage("Ημερομηνία αγαπημένου"),
        "liked": MessageLookupByLibrary.simpleMessage("Συνδεδεμένο"),
        "listen": MessageLookupByLibrary.simpleMessage("Άκουσε"),
        "listened": MessageLookupByLibrary.simpleMessage("Ακουσμένο"),
        "loadMore": MessageLookupByLibrary.simpleMessage("Περισσότερα"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Σύνδεση"),
        "loginFailed":
            MessageLookupByLibrary.simpleMessage("Αποτυχία σύνδεσης"),
        "logout": MessageLookupByLibrary.simpleMessage("Αποσύνδεση"),
        "mark": MessageLookupByLibrary.simpleMessage("Επισήμανση"),
        "markConfirm":
            MessageLookupByLibrary.simpleMessage("Επιβεβαίωση επισήμανσης"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Επιβεβαίωση επισήμανσης όλων των επεισοδίων ως ακουσμένα;"),
        "markListened":
            MessageLookupByLibrary.simpleMessage("Επισήμανση ως ακουσμένου"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Επισήμανση ως μη ακουσμένου"),
        "menu": MessageLookupByLibrary.simpleMessage("Μενού"),
        "menuAllPodcasts":
            MessageLookupByLibrary.simpleMessage("Όλα τα podcast"),
        "menuMarkAllListened": MessageLookupByLibrary.simpleMessage(
            "Επισήμανση όλων ως ακουσμένων"),
        "menuViewRSS":
            MessageLookupByLibrary.simpleMessage("Επίσκεψη RSS feed"),
        "menuVisitSite":
            MessageLookupByLibrary.simpleMessage("Επίσκεψη Ιστοτόπου"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Δίκτυο"),
        "neverAutoUpdate": MessageLookupByLibrary.simpleMessage(
            "Απενεργοποίηση αυτόματων ενημερώσεων"),
        "newGroup":
            MessageLookupByLibrary.simpleMessage("Δημιουργία νέας ομάδας"),
        "newestFirst": MessageLookupByLibrary.simpleMessage("Νεότερα πρώτα"),
        "next": MessageLookupByLibrary.simpleMessage("Επόμενο"),
        "noEpisodeDownload": MessageLookupByLibrary.simpleMessage(
            "Δεν έχουν ληφθεί επεισόδια ακόμα"),
        "noEpisodeFavorite": MessageLookupByLibrary.simpleMessage(
            "Κανένα επεισοδίο δεν έχει επισημανθεί ακόμη ως αγαπημένο"),
        "noEpisodeRecent": MessageLookupByLibrary.simpleMessage(
            "Δεν έχουν βρεθεί επεισόδια ακόμα"),
        "noPodcastGroup": MessageLookupByLibrary.simpleMessage(
            "Κανένα podcast σε αυτή την ομάδα"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Δεν υπάρχουν διαθέσιμες σημειώσεις σόου για αυτό το επεισόδιο."),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Πίνακας ειδοποιήσεων"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst": MessageLookupByLibrary.simpleMessage("Παλιότερα πρώτα"),
        "passwdRequired": MessageLookupByLibrary.simpleMessage(
            "Ο κωδικός πρόσβασης είναι υποχρεωτικός"),
        "password": MessageLookupByLibrary.simpleMessage("Κωδικός πρόσβασης"),
        "pause": MessageLookupByLibrary.simpleMessage("Παύση"),
        "play": MessageLookupByLibrary.simpleMessage("Αναπαραγωγή"),
        "playNext": MessageLookupByLibrary.simpleMessage("Επόμενο"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Προσθήκη επεισοδίου στη κορυφή της λίστας"),
        "playback":
            MessageLookupByLibrary.simpleMessage("Έλεγχος αναπαραγωγής "),
        "player": MessageLookupByLibrary.simpleMessage("Προβολή αναπαραγωγής"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Μέτριο"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Χαμηλό"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Ψηλό"),
        "playing":
            MessageLookupByLibrary.simpleMessage("Αναπαραγωγή σε εξέλιξη "),
        "playlistExisted":
            MessageLookupByLibrary.simpleMessage("Το όνομα λίστας υπάρχει"),
        "playlistNameEmpty":
            MessageLookupByLibrary.simpleMessage("Το όνομα λίστας είναι κενό"),
        "playlists": MessageLookupByLibrary.simpleMessage("Λίστες"),
        "plugins": MessageLookupByLibrary.simpleMessage("Πρόσθετα"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Podcast εγγράφη"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Λήψη επεισοδίου "),
        "popupMenuLaterDes": MessageLookupByLibrary.simpleMessage(
            "Προσθήκη επεισοδίου σε λίστα"),
        "popupMenuLikeDes": MessageLookupByLibrary.simpleMessage(
            "Προσθήκη επεισοδίου στα αγαπημένα"),
        "popupMenuMarkDes": MessageLookupByLibrary.simpleMessage(
            "Επισήμανση επεισοδίου ως ακουσμένο"),
        "popupMenuPlayDes":
            MessageLookupByLibrary.simpleMessage("Αναπαραγωγή επεισοδίου"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Πολιτική Απορρήτου "),
        "published": m22,
        "publishedDaily":
            MessageLookupByLibrary.simpleMessage("Δημοσίευεται καθημερινά"),
        "publishedMonthly":
            MessageLookupByLibrary.simpleMessage("Δημοσίευεται μηνιαία"),
        "publishedWeekly":
            MessageLookupByLibrary.simpleMessage("Δημοσίευεται εβδομαδιαια"),
        "publishedYearly":
            MessageLookupByLibrary.simpleMessage("Δημοσίευεται ετήσια"),
        "queue": MessageLookupByLibrary.simpleMessage("Ουρά"),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Ανάκτηση συνδρομής"),
        "refresh": MessageLookupByLibrary.simpleMessage("Ανανέωση"),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Ενημέρωση γραφικών"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Ανανέωση"),
        "remove": MessageLookupByLibrary.simpleMessage("Αφαίρεση"),
        "removeConfirm":
            MessageLookupByLibrary.simpleMessage("Επιβεβαίωση κατάργησης"),
        "removeNewMark":
            MessageLookupByLibrary.simpleMessage("Αφαίρεση επισήμανσης νέου"),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "Είσαι σίγουρος/η πως θες να καταργήσεις την εγγραφή σου; "),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Αποθήκευση"),
        "schedule": MessageLookupByLibrary.simpleMessage("Πρόγραμμα"),
        "search": MessageLookupByLibrary.simpleMessage("Αναζήτηση"),
        "searchEpisode":
            MessageLookupByLibrary.simpleMessage("Αναζήτηση επεισοδίου"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Πληκτρολόγησε το όνομα του podcast, λέξεις κλειδιά ή το URL ενός feed."),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Εσφαλμένος σύνδεσμος RSS"),
        "searchPodcast":
            MessageLookupByLibrary.simpleMessage("Αναζήτηση podcast"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage":
            MessageLookupByLibrary.simpleMessage("Χώρος αποθήκευσης"),
        "settings": MessageLookupByLibrary.simpleMessage("Ρυθμίσεις"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Χρώμα έμφασης"),
        "settingsAccentColorDes": MessageLookupByLibrary.simpleMessage(
            "Συμπερίληψη χρώματος επικάλυψης"),
        "settingsAppIntro":
            MessageLookupByLibrary.simpleMessage("Εισαγωγή εφαρμογής"),
        "settingsAppearance": MessageLookupByLibrary.simpleMessage("Εμφάνιση"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Χρώματα και θέματα"),
        "settingsAudioCache":
            MessageLookupByLibrary.simpleMessage("Προσωρινή μνήμη ήχου"),
        "settingsAudioCacheDes": MessageLookupByLibrary.simpleMessage(
            "Μέγιστο μέγεθος προσωρινής μνήμης ήχου"),
        "settingsAutoDelete": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη διαγραφή λήψεων μετά από"),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("Προεπιλογή 30 ημέρες"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη αναπαραγωγή επόμενου επεισοδίου στη λίστα"),
        "settingsBackup":
            MessageLookupByLibrary.simpleMessage("Αντίγραφο ασφαλείας"),
        "settingsBackupDes": MessageLookupByLibrary.simpleMessage(
            "Αντίγραφο ασφαλείας δεδομένων εφαρμογής"),
        "settingsBoostVolume":
            MessageLookupByLibrary.simpleMessage("Επιπέδο ενίσχυσης έντασης"),
        "settingsBoostVolumeDes": MessageLookupByLibrary.simpleMessage(
            "Αλλαγή επιπέδου ενίσχυσης έντασης"),
        "settingsDefaultGrid": MessageLookupByLibrary.simpleMessage(
            "Προεπιλεγμένη προβολή πλέγματος"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("Καρτέλα λήψεων"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Καρτέλα αγαπημένων"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Σελίδα podcast"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("Καρτέλα πρόσφατων"),
        "settingsDiscovery": MessageLookupByLibrary.simpleMessage(
            "Ενεργοποίηση λειτουργιών ανακάλυψης"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("Λήψη θέσης"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Ενεργοποίηση συγχρονισμού"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Ανανέωση όλων των podcast στο παρασκήνιο για τη λήψη των τελευταίων επεισοδίων"),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Ρυθμίσεις εξαγωγής και εισαγωγής"),
        "settingsFastForwardSec": MessageLookupByLibrary.simpleMessage(
            "Δευτερολέπτα γυρίσματος μπροστά"),
        "settingsFastForwardSecDes": MessageLookupByLibrary.simpleMessage(
            "Αλλαγή δευτερολέπτων γυρίσματος μπροστά στη προβολή αναπαραγωγής"),
        "settingsFeedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsFeedbackDes": MessageLookupByLibrary.simpleMessage(
            "Επαναφορά λειτουργίας εκμάθησης"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("Ιστορικό"),
        "settingsHistoryDes": MessageLookupByLibrary.simpleMessage(
            "Εξαγωγή και εισαγωγή ρυθμίσεων"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Πληροφορίες"),
        "settingsInterface": MessageLookupByLibrary.simpleMessage("Διεπαφή"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Γλώσσες"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Αλλαγή γλώσσας"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Διάταξη"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Διάταξη εφαρμογής"),
        "settingsLibraries":
            MessageLookupByLibrary.simpleMessage("Βιβλιοθήκες"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Βιβλιοθήκες ανοιχτού κώδικα που χρησιμοποιούνται από την εφαρμογή"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("Διαχείριση λήψεων"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "Διαχείριση ληφθέντων αρχείων ήχου"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Επισήμανση ως ακουσμένου όταν παραλείπεται"),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη επισήμανση του επεισοδίου ως ακουσμένου κατά τη παράλειψή του"),
        "settingsMenuAutoPlay": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη αναπαραγωγή επομένου"),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Ερώτηση πριν τη χρήση δεδομένων"),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη λήψη με χρήση δεδομένων"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "Μπορείς να ρυθμίσεις την αυτόματη λήψη podcast στη σελίδα διαχείρισης ομάδων"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Ερώτηση για επιβεβαίωση λήψης επεισοδίων κατά τη χρήση δεδομένων"),
        "settingsPlayDes": MessageLookupByLibrary.simpleMessage(
            "Λίστα και προβολή αναπαραγωγής"),
        "settingsPlayerHeight":
            MessageLookupByLibrary.simpleMessage("Ύψος προβολής αναπαραγωγής"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Προσάρμοσε το ύψος της προβολής αναπαραγωγής εκεί που θέλεις"),
        "settingsPopupMenu":
            MessageLookupByLibrary.simpleMessage("Αναδυόμενο μενού επεισοδίων"),
        "settingsPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Αλλαγή αναδυόμενου μενού επεισοδίων"),
        "settingsPrefrence": MessageLookupByLibrary.simpleMessage("Προτίμηση"),
        "settingsRealDark":
            MessageLookupByLibrary.simpleMessage("Μαύρο (AMOLED)"),
        "settingsRealDarkDes": MessageLookupByLibrary.simpleMessage(
            "Ενεργοποίησε αν νομίζεις ότι η νύχτα δεν είναι σκοτεινή αρκετά"),
        "settingsRewindSec": MessageLookupByLibrary.simpleMessage(
            "Δευτερολέπτα γυρίσματος πίσω"),
        "settingsRewindSecDes": MessageLookupByLibrary.simpleMessage(
            "Αλλαγή δευτερολέπτων γυρίσματος πίσω στη προβολή αναπαραγωγής"),
        "settingsSTAuto": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη ενεργοποίηση χρονοδιακόπτη"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Αυτόματη έναρξη χρονοδιακόπτη την προγραμματισμένη ώρα"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Προεπιλεγμένος χρόνος"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Προεπιλεγμένος χρόνος χρονοδιακόπτη"),
        "settingsSTMode": MessageLookupByLibrary.simpleMessage(
            "Λειτουργία αυτόματου χρονοδιακόπτη"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Ταχύτητες"),
        "settingsSpeedsDes": MessageLookupByLibrary.simpleMessage(
            "Επεξεργασία διαθέσιμων ταχυτήτων"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Διαχείριση χώρου αποθήκευσης λήψεων και προσωρινής μνήμης"),
        "settingsSyncing": MessageLookupByLibrary.simpleMessage("Συγχρονισμός"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Ανανέωση podcast στο παρασκήνιο"),
        "settingsTapToOpenPopupMenu": MessageLookupByLibrary.simpleMessage(
            "Πάτησε για να ανοίξεις το αναδυόμενο μενού"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Πρέπει να πατήσεις παρατεταμένα για το άνοιγμα της σελίδας επεισοδίου"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Θέμα"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Χρόνος μεταξύ ενημερώσεων"),
        "settingsUpdateIntervalDes":
            MessageLookupByLibrary.simpleMessage("Προεπιλογή 24 ώρες "),
        "share": MessageLookupByLibrary.simpleMessage("Κοινοποίηση"),
        "showNotesFonts": MessageLookupByLibrary.simpleMessage(
            "Προβολή γραμματοσειράς σημειώσεων"),
        "size": MessageLookupByLibrary.simpleMessage("Μέγεθος"),
        "skipSecondsAtEnd": MessageLookupByLibrary.simpleMessage(
            "Παράλειψη δευτερολέπτων στο τέλος"),
        "skipSecondsAtStart": MessageLookupByLibrary.simpleMessage(
            "Παράληψη αρχικών δευτερολέπτων"),
        "skipSilence": MessageLookupByLibrary.simpleMessage("Παράλειψη σιγής"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("Παράλειψη"),
        "sleepTimer": MessageLookupByLibrary.simpleMessage("Χρονοδιακόπτης"),
        "status": MessageLookupByLibrary.simpleMessage("Κατάσταση"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage("Σφάλμα πιστοποίησης"),
        "statusFail": MessageLookupByLibrary.simpleMessage("Αποτυχία"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Επιτυχία"),
        "stop": MessageLookupByLibrary.simpleMessage("Σταμάτημα"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Εγγραφή"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Εξαγωγή αρχείου OPML όλων των podcast"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Συγχρονισμός τώρα"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Προεπιλογή συστήματος"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist":
            MessageLookupByLibrary.simpleMessage("Προστέθηκε στη λίστα"),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Λειτουργία ανακάλυψης ενεργή, παρακαλώ ξανανοίξτε την εφαρμογή"),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Σφάλμα αρχείου, η εγγραφή απέτυχε "),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("Μη έγκυρο αρχείο"),
        "toastHomeGroupNotSupport": MessageLookupByLibrary.simpleMessage(
            "Η Αρχική ομάδα δεν υποστηρίζεται"),
        "toastImportSettingsSuccess":
            MessageLookupByLibrary.simpleMessage("Εισαγωγή ρυθμίσεων επιτυχής"),
        "toastOneGroup": MessageLookupByLibrary.simpleMessage(
            "Επέλεξε τουλάχιστον μία ομάδα"),
        "toastPodcastRecovering":
            MessageLookupByLibrary.simpleMessage("Ανάκτηση, περίμενε λίγο"),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("Διάβασμα αρχείου επιτυχές"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Η ανάκτηση του podcast απέτυχε"),
        "toastRemovePlaylist": MessageLookupByLibrary.simpleMessage(
            "Τα επεισόδιο αφαιρέθηκε από τη λίστα"),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Οι ρυθμίσεις αποθηκεύτηκαν "),
        "toastTimeEqualEnd": MessageLookupByLibrary.simpleMessage(
            "Ο επιλεγμένος χρόνος είναι ίδιος με τον χρόνο λήξης"),
        "toastTimeEqualStart": MessageLookupByLibrary.simpleMessage(
            "Ο επιλεγμένος χρόνος είναι ίδιος με τον χρόνο έναρξης"),
        "translators": MessageLookupByLibrary.simpleMessage("Μεταφραστές"),
        "understood": MessageLookupByLibrary.simpleMessage("Κατάλαβα"),
        "undo": MessageLookupByLibrary.simpleMessage("ΑΝΑΙΡΕΣΗ"),
        "unlike": MessageLookupByLibrary.simpleMessage("Δεν Μου Αρέσει"),
        "unliked": MessageLookupByLibrary.simpleMessage(
            "Τα επεισόδιο αφαιρέθηκε από τα αγαπημένα"),
        "updateDate":
            MessageLookupByLibrary.simpleMessage("Ημερομηνία ενημέρωσης"),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Ενημέρωση ανεπιτυχείς, σφάλμα δικτύου"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Όνομα χρήστη"),
        "usernameRequired": MessageLookupByLibrary.simpleMessage(
            "Το όνομα χρήστη είναι υποχρεωτικό"),
        "version": m31
      };
}
