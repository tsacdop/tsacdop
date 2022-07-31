// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${count} épisode de ${groupName} ajouté à la playlist.', other: '${count} épisodes de ${groupName} ajoutés à la playlist.')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} épisode ajouté à la playlist.', other: '${count} épisodes ajoutés à la playlist.')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Aujourd\'hui', one: 'Il y a ${count} jour', other: 'Il y a ${count} jours')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Jamais', one: '${count} jour', other: '${count} jours')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'Épisode', other: 'Épisodes ')}";

  static String m5(time) => "De ${time}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Groupe', one: 'Groupe', other: 'Groupes')}";

  static String m7(host) => "Hébergé par ${host}";

  static String m8(count) =>
      "${Intl.plural(count, zero: 'A l\'instant', one: 'Il y a ${count} heure', other: 'Il y a ${count} heures')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: '0 heure', one: '${count} heure', other: '${count} heures')}";

  static String m10(service) => "Integrate with ${service}";

  static String m11(userName) => "Logged in as ${userName}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'A l\'instant', one: 'Il y a ${count} minute', other: 'Il y a ${count} minutes')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 min', one: '${count} min', other: '${count} mins')}";

  static String m14(title) => "Accès aux données ${title} ";

  static String m15(title) => "Échec de l’abonnement, erreur réseau ${title} ";

  static String m16(title) => "Abonnement en cours";

  static String m17(title) =>
      "Échec de l’abonnement, le podcast existe déjà ${title}";

  static String m18(title) => "Abonnement réussi.";

  static String m19(title) => "Mise à jour ${title}";

  static String m20(title) => "Échec de la mise à jour ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcasts')}";

  static String m22(date) => "Publié le ${date}";

  static String m23(date) => "Supprimé le ${date}";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 sec', one: '${count} sec', other: '${count} sec')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'A l\'instant', one: 'Il y a ${count} seconde', other: 'Il y a ${count} secondes')}";

  static String m26(count) => "";

  static String m27(time) => "Dernière écoute à ${time}";

  static String m28(time) => "${time} Restant";

  static String m29(time) => "à ${time}";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'Aucune mise à jour.', one: 'Mise à jour d\'${count} épisode.', other: 'Mise à jour de ${count} épisodes.')}";

  static String m31(version) => "Version : ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Ajouter"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Ajouter de nouveaux épisodes à la playlist."),
        "addSomeGroups":
            MessageLookupByLibrary.simpleMessage("Ajouter des groupes"),
        "all": MessageLookupByLibrary.simpleMessage("Tout"),
        "autoDownload": MessageLookupByLibrary.simpleMessage("Automatisation"),
        "back": MessageLookupByLibrary.simpleMessage("Retour"),
        "boostVolume":
            MessageLookupByLibrary.simpleMessage("Booster le volume"),
        "buffering": MessageLookupByLibrary.simpleMessage("Buffering"),
        "cancel": MessageLookupByLibrary.simpleMessage("ANNULER"),
        "cellularConfirm": MessageLookupByLibrary.simpleMessage(
            "Avertissement utilisation des données mobiles"),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "Êtes-vous sûr d\'autoriser l\'utilisation des données mobiles ?"),
        "changeLayout":
            MessageLookupByLibrary.simpleMessage("Modifier l\'interface"),
        "changelog": MessageLookupByLibrary.simpleMessage("Changelog"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Choisir un"),
        "clear": MessageLookupByLibrary.simpleMessage("Effacer"),
        "clearAll": MessageLookupByLibrary.simpleMessage(""),
        "color": MessageLookupByLibrary.simpleMessage("Couleur"),
        "confirm": MessageLookupByLibrary.simpleMessage("CONFIRMER"),
        "createNewPlaylist": MessageLookupByLibrary.simpleMessage(""),
        "darkMode": MessageLookupByLibrary.simpleMessage("Mode sombre"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(""),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Default podcast search engine"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Choose the default podcast search engine"),
        "delete": MessageLookupByLibrary.simpleMessage("Effacer"),
        "developer": MessageLookupByLibrary.simpleMessage("Développeur"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Passer"),
        "done": MessageLookupByLibrary.simpleMessage("Fait"),
        "download": MessageLookupByLibrary.simpleMessage("Téléchargés"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("Download removed"),
        "downloadStart": MessageLookupByLibrary.simpleMessage("Downloading"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Téléchargés"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Modifier le nom du groupe"),
        "endOfEpisode":
            MessageLookupByLibrary.simpleMessage("Fin de l\'épisode"),
        "episode": m4,
        "fastForward": MessageLookupByLibrary.simpleMessage("Fast forward"),
        "fastRewind": MessageLookupByLibrary.simpleMessage("Fast rewind"),
        "featureDiscoveryEditGroup":
            MessageLookupByLibrary.simpleMessage("Gestion des groupes"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Ici vous pouvez supprimer ou modifier le nom des groupes, seul le groupe Home ne peut être édité."),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Vue épisode"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez effectuer un appui long pour jouer un épisode ou l\'ajouter à la playlist."),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Effectuez un appui long pour lancer un épisode"),
        "featureDiscoveryGroup": MessageLookupByLibrary.simpleMessage(
            "Appuyez ici pour créer un groupe"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "Pour les nouveaux podcasts le groupe par défaut est Home. Vous pouvez créer de nouveaux groupes et y déplacer vos podcasts. Un podcast peut être associé à plusieurs groupes."),
        "featureDiscoveryGroupPodcast":
            MessageLookupByLibrary.simpleMessage("Classement des podcasts"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Appuyez ici pour accéder à plus d\'options, un appui long permet de classer les podcasts d\'un groupe."),
        "featureDiscoveryOMPL": MessageLookupByLibrary.simpleMessage(
            "Appuyez ici pour importer un fichier OPML"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez importer un fichier OPML, accéder aux paramètres ou actualiser tous les podcasts."),
        "featureDiscoveryPlaylist": MessageLookupByLibrary.simpleMessage(
            "Appuyez ici pour ouvrir la playlist"),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Ajoutez des épisodes dans la playlist. Ils seront automatiquement retirés une fois écoutés."),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Vue podcasts"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Appuyez sur Tout Voir pour ajouter des groupes et gérer les podcasts."),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Effectuez un défilement vertical pour changer de groupe."),
        "featureDiscoverySearch": MessageLookupByLibrary.simpleMessage(
            "Appuyez ici pour rechercher un podcast"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Pour trouver vos podcasts vous pouvez effectuer une recherche par titres, mots clés ou liens RSS."),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("Contact"),
        "feedbackGithub": MessageLookupByLibrary.simpleMessage("GitHub"),
        "feedbackPlay": MessageLookupByLibrary.simpleMessage("PlayStore"),
        "feedbackTelegram": MessageLookupByLibrary.simpleMessage("Telegram"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtrer"),
        "fontStyle": MessageLookupByLibrary.simpleMessage("Font style"),
        "fonts": MessageLookupByLibrary.simpleMessage("Polices"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("Bonne nuit"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Congratulations! You  have linked gpodder.net account successfully. Tsacdop will automatically sync subscriptions on your device with your gpodder.net account."),
        "groupExisted":
            MessageLookupByLibrary.simpleMessage("Ce groupe existe déjà"),
        "groupFilter":
            MessageLookupByLibrary.simpleMessage("Filtrer par groupe"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "Êtes-vous sûr de vouloir supprimer ce groupe ? Les podcasts seront déplacés vers le groupe Home."),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Hide listened"),
        "hidePodcastDiscovery":
            MessageLookupByLibrary.simpleMessage("Hide podcast discovery"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Hide podcast discovery in search page"),
        "homeGroupsSeeAll": MessageLookupByLibrary.simpleMessage("Tout Voir"),
        "homeMenuPlaylist": MessageLookupByLibrary.simpleMessage("Playlist"),
        "homeSubMenuSortBy": MessageLookupByLibrary.simpleMessage("Classé par"),
        "homeTabMenuFavotite": MessageLookupByLibrary.simpleMessage("Favoris"),
        "homeTabMenuRecent": MessageLookupByLibrary.simpleMessage("Récents"),
        "homeToprightMenuAbout":
            MessageLookupByLibrary.simpleMessage("À propos"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("Importer un fichier OPML"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Tout actualiser"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("Importer"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Un appui long sur un épisode lance les actions rapides."),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "S\'abonner aux podcasts via la section recherche ou un fichier OPML."),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez créer des groupes de podcasts."),
        "invalidName": MessageLookupByLibrary.simpleMessage("Invalid username"),
        "lastUpdate": MessageLookupByLibrary.simpleMessage("Last update"),
        "later": MessageLookupByLibrary.simpleMessage("Plus tard"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Mode clair"),
        "like": MessageLookupByLibrary.simpleMessage("Like"),
        "likeDate": MessageLookupByLibrary.simpleMessage("Date du like"),
        "liked": MessageLookupByLibrary.simpleMessage("Liké"),
        "listen": MessageLookupByLibrary.simpleMessage("Écoutés"),
        "listened": MessageLookupByLibrary.simpleMessage("Écouté "),
        "loadMore": MessageLookupByLibrary.simpleMessage("Voir plus"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "mark": MessageLookupByLibrary.simpleMessage("✓"),
        "markConfirm":
            MessageLookupByLibrary.simpleMessage("Marquage effectué"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Marquer tous les épisodes comme lus ?"),
        "markListened": MessageLookupByLibrary.simpleMessage("Marquage"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Mark not listened"),
        "menu": MessageLookupByLibrary.simpleMessage("Menu"),
        "menuAllPodcasts":
            MessageLookupByLibrary.simpleMessage("Tous les podcasts"),
        "menuMarkAllListened":
            MessageLookupByLibrary.simpleMessage("Marquer comme tous lu"),
        "menuViewRSS":
            MessageLookupByLibrary.simpleMessage("Accéder au flux RSS"),
        "menuVisitSite":
            MessageLookupByLibrary.simpleMessage("Accéder au site"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Réseau"),
        "neverAutoUpdate":
            MessageLookupByLibrary.simpleMessage("Turn off auto update"),
        "newGroup":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau groupe"),
        "newestFirst":
            MessageLookupByLibrary.simpleMessage("Le plus récent en premier"),
        "next": MessageLookupByLibrary.simpleMessage("Suivant"),
        "noEpisodeDownload":
            MessageLookupByLibrary.simpleMessage("Aucun épisode téléchargé."),
        "noEpisodeFavorite":
            MessageLookupByLibrary.simpleMessage("Aucun épisode ajouté."),
        "noEpisodeRecent":
            MessageLookupByLibrary.simpleMessage("Aucun épisode récent."),
        "noPodcastGroup": MessageLookupByLibrary.simpleMessage(
            "Ce groupe ne contient aucun podcast"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Notes de l\'épisode manquantes."),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Notification panel"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst":
            MessageLookupByLibrary.simpleMessage("Le plus ancien en premier"),
        "passwdRequired":
            MessageLookupByLibrary.simpleMessage("Password required"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "play": MessageLookupByLibrary.simpleMessage("Lecture"),
        "playNext": MessageLookupByLibrary.simpleMessage("Play next"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Add episode to top of the playlist"),
        "playback":
            MessageLookupByLibrary.simpleMessage("Commandes du lecteur"),
        "player": MessageLookupByLibrary.simpleMessage("Player"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Moyen"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Petit"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Grand"),
        "playing": MessageLookupByLibrary.simpleMessage("En cours"),
        "playlistExisted": MessageLookupByLibrary.simpleMessage(""),
        "playlistNameEmpty": MessageLookupByLibrary.simpleMessage(""),
        "playlists": MessageLookupByLibrary.simpleMessage(""),
        "plugins": MessageLookupByLibrary.simpleMessage("Plugins"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Abonné au podcast"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Télécharger l\'épisode"),
        "popupMenuLaterDes":
            MessageLookupByLibrary.simpleMessage("Ajouter à la playlist"),
        "popupMenuLikeDes": MessageLookupByLibrary.simpleMessage(
            "Ajouter l\'épisode aux favoris"),
        "popupMenuMarkDes":
            MessageLookupByLibrary.simpleMessage("Marquer l\'épisode comme lu"),
        "popupMenuPlayDes":
            MessageLookupByLibrary.simpleMessage("Lancer l\'épisode"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Gestion des données"),
        "published": m22,
        "publishedDaily": MessageLookupByLibrary.simpleMessage("Quotidien"),
        "publishedMonthly": MessageLookupByLibrary.simpleMessage("Mensuel"),
        "publishedWeekly": MessageLookupByLibrary.simpleMessage("Hebdomadaire"),
        "publishedYearly": MessageLookupByLibrary.simpleMessage("Annuel"),
        "queue": MessageLookupByLibrary.simpleMessage(""),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Restaurer l\'abonnement"),
        "refresh": MessageLookupByLibrary.simpleMessage(""),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Mettre à jour la vignette"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Refreshing"),
        "remove": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "removeConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmer la suppression"),
        "removeNewMark": MessageLookupByLibrary.simpleMessage(""),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "Êtes-vous sûr de vouloir vous désabonner ?"),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Sauvegarder"),
        "schedule": MessageLookupByLibrary.simpleMessage("Programmation"),
        "search": MessageLookupByLibrary.simpleMessage("Rechercher"),
        "searchEpisode":
            MessageLookupByLibrary.simpleMessage("Rechercher un épisode"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Type the podcast name, keywords or enter a feed url."),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Lien RSS invalide"),
        "searchPodcast":
            MessageLookupByLibrary.simpleMessage("Chercher un podcast"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage":
            MessageLookupByLibrary.simpleMessage("Espace de stockage"),
        "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Couleur principale"),
        "settingsAccentColorDes": MessageLookupByLibrary.simpleMessage(
            "Sélection de la couleur du thème"),
        "settingsAppIntro":
            MessageLookupByLibrary.simpleMessage("Revoir l\'introduction"),
        "settingsAppearance": MessageLookupByLibrary.simpleMessage("Apparence"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Couleurs et thèmes"),
        "settingsAudioCache":
            MessageLookupByLibrary.simpleMessage("Cache audio"),
        "settingsAudioCacheDes": MessageLookupByLibrary.simpleMessage(
            "Taille maximum du cache audio"),
        "settingsAutoDelete":
            MessageLookupByLibrary.simpleMessage("Suppression des fichiers "),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("30 jours par défaut"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Lancer automatiquement l\'épisode suivant"),
        "settingsBackup": MessageLookupByLibrary.simpleMessage("Backup"),
        "settingsBackupDes": MessageLookupByLibrary.simpleMessage(
            "Sauvegarde des données de l\'application"),
        "settingsBoostVolume":
            MessageLookupByLibrary.simpleMessage("Booster le volume"),
        "settingsBoostVolumeDes": MessageLookupByLibrary.simpleMessage(
            "Définir la puissance du volume"),
        "settingsDefaultGrid":
            MessageLookupByLibrary.simpleMessage("Vue par défaut"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("Onglet Téléchargés"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Onglet Favoris"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Onglet podcasts"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("Onglet Récents"),
        "settingsDiscovery":
            MessageLookupByLibrary.simpleMessage("Revoir le tutoriel"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("Download position"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Activer la synchronisation"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Actualiser tous les podcasts en arrière-plan pour toujours afficher les derniers épisodes"),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Exporter et importer les paramètres de l\'application."),
        "settingsFastForwardSec":
            MessageLookupByLibrary.simpleMessage("Avance rapide"),
        "settingsFastForwardSecDes":
            MessageLookupByLibrary.simpleMessage("Saut avant"),
        "settingsFeedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsFeedbackDes": MessageLookupByLibrary.simpleMessage(
            "Report de bug et demande d\'ajout de fonction"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("Historique"),
        "settingsHistoryDes":
            MessageLookupByLibrary.simpleMessage("Gestion des données"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Informations"),
        "settingsInterface":
            MessageLookupByLibrary.simpleMessage("Interface utilisateur"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Langues"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Sélection de la langue"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Style"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Style de l\'application"),
        "settingsLibraries": MessageLookupByLibrary.simpleMessage("Librairies"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Librairies opensource utilisées"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("Gérer les téléchargements"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "Gestion des fichiers audio téléchargés"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Mark as listened when skipped"),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Auto mark episode as listened when it was skipped to next"),
        "settingsMenuAutoPlay":
            MessageLookupByLibrary.simpleMessage("Lecture automatique"),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Utilisation du réseau mobile"),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Téléchargement automatique sur réseau mobile"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "L\'automatisation du téléchargement peut aussi être configurée sur page de gestion des groupes"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Demander une confirmation avant de lancer un téléchargement"),
        "settingsPlayDes":
            MessageLookupByLibrary.simpleMessage("Playlist et lecteur"),
        "settingsPlayerHeight":
            MessageLookupByLibrary.simpleMessage("Taille du player"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Changer la hauteur du widget"),
        "settingsPopupMenu":
            MessageLookupByLibrary.simpleMessage("Menu popup des épisodes"),
        "settingsPopupMenuDes":
            MessageLookupByLibrary.simpleMessage("Configuration du menu popup"),
        "settingsPrefrence":
            MessageLookupByLibrary.simpleMessage("Préférences"),
        "settingsRealDark":
            MessageLookupByLibrary.simpleMessage("Noir profond"),
        "settingsRealDarkDes":
            MessageLookupByLibrary.simpleMessage("Mode sombre accentué"),
        "settingsRewindSec":
            MessageLookupByLibrary.simpleMessage("Retour rapide"),
        "settingsRewindSecDes":
            MessageLookupByLibrary.simpleMessage("Saut arrière"),
        "settingsSTAuto": MessageLookupByLibrary.simpleMessage(
            "Activation automatique de la minuterie"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Démarrer la minuterie à l\'horaire programmé"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Durée par défaut"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Configuration de la minuterie"),
        "settingsSTMode":
            MessageLookupByLibrary.simpleMessage("Mode minuterie automatique"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Speeds"),
        "settingsSpeedsDes": MessageLookupByLibrary.simpleMessage(
            "Customize the speeds avaliable"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Gestion du cache et de l\'espace de stockage"),
        "settingsSyncing":
            MessageLookupByLibrary.simpleMessage("Synchronisation"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Actualisation des podcasts en arrière-plan"),
        "settingsTapToOpenPopupMenu":
            MessageLookupByLibrary.simpleMessage("Ouverture du menu"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Effectuer un appui long pour ouvrir la page de l\'épisode"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Thème"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Intervalle de mise à jour"),
        "settingsUpdateIntervalDes": MessageLookupByLibrary.simpleMessage(
            "L\'intervalle par défaut est de 24 heures"),
        "share": MessageLookupByLibrary.simpleMessage("Partager"),
        "showNotesFonts":
            MessageLookupByLibrary.simpleMessage("Show notes font"),
        "size": MessageLookupByLibrary.simpleMessage("Taille"),
        "skipSecondsAtEnd":
            MessageLookupByLibrary.simpleMessage("Skip seconds at end"),
        "skipSecondsAtStart": MessageLookupByLibrary.simpleMessage(
            "Passer les premières secondes du début"),
        "skipSilence": MessageLookupByLibrary.simpleMessage("Skip silence"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("Skip to next"),
        "sleepTimer": MessageLookupByLibrary.simpleMessage("Minuterie"),
        "status": MessageLookupByLibrary.simpleMessage("Status"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage("Authentication error"),
        "statusFail": MessageLookupByLibrary.simpleMessage("Failed"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Successful"),
        "stop": MessageLookupByLibrary.simpleMessage("Stop"),
        "subscribe": MessageLookupByLibrary.simpleMessage("S\'abonner"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Exporter le fichier OPML de tous les podcasts."),
        "syncNow": MessageLookupByLibrary.simpleMessage("Sync now"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Système par défaut"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist": MessageLookupByLibrary.simpleMessage(
            "Ajouter l\'épisode à la playlist."),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Tutoriel réinitialisé, veuillez redémarrer l\'application."),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Erreur du fichier, échec de l\'abonnement."),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("Fichier invalide."),
        "toastHomeGroupNotSupport": MessageLookupByLibrary.simpleMessage(
            "Le groupe Home n\'est pas pris en charge"),
        "toastImportSettingsSuccess": MessageLookupByLibrary.simpleMessage(
            "Importation des paramètres effectuée"),
        "toastOneGroup": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez au moins un groupe"),
        "toastPodcastRecovering": MessageLookupByLibrary.simpleMessage(
            "Récupération en cours, patientez un instant."),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("Lecture du fichier réussie"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Échec de la récupération du podcast"),
        "toastRemovePlaylist": MessageLookupByLibrary.simpleMessage(
            "L\'épisode a été supprimé de la playlist."),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Paramètres sauvegardés"),
        "toastTimeEqualEnd":
            MessageLookupByLibrary.simpleMessage("Heure de fin"),
        "toastTimeEqualStart":
            MessageLookupByLibrary.simpleMessage("Heure de démarrage"),
        "translators": MessageLookupByLibrary.simpleMessage("Traducteurs"),
        "understood": MessageLookupByLibrary.simpleMessage("Compris"),
        "undo": MessageLookupByLibrary.simpleMessage("ANNULER"),
        "unlike": MessageLookupByLibrary.simpleMessage("Unlike"),
        "unliked": MessageLookupByLibrary.simpleMessage(
            "L\'épisode a été supprimé des favoris."),
        "updateDate":
            MessageLookupByLibrary.simpleMessage("Date de mise à jour"),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Échec de la mise à jour, erreur réseau"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Username required"),
        "version": m31
      };
}
