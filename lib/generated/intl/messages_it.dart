// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${count} episodio di ${groupName} aggiunto alla playlist', other: '${count} episodi di ${groupName} aggiunti alla playlist')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} episodio aggiunto alla playlist', other: '${count} episodi aggiunti alla playlist')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Oggi', one: '${count} giorno fa', other: '${count} giorni fa')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Mai', one: '${count} giorno', other: '${count} giorni')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'Episodio', other: 'Episodi')}";

  static String m5(time) => "Da ${time}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Gruppi', one: 'Gruppo', other: 'Gruppi')}";

  static String m7(host) => "Hostato da ${host}";

  static String m8(count) =>
      "${Intl.plural(count, zero: 'Meno di un\'ora fa', one: '${count} ora fa', other: '${count} ore fa')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: '0 ore', one: '${count} ora', other: '${count} ore')}";

  static String m10(service) => "Integra con ${service}";

  static String m11(userName) => "Accesso effettuato come ${userName}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Adesso', one: '${count} minuto fa', other: '${count} minuti fa')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 min', one: '${count} min', other: '${count} min')}";

  static String m14(title) => "Recupera dati ${title}";

  static String m15(title) => "Iscrizione fallita, errore di rete ${title}";

  static String m16(title) => "Sottoscrivi ${title}";

  static String m17(title) =>
      "Iscrizione fallita, il podcast esiste già ${title}";

  static String m18(title) => "Sottoscrizione con successo ${title}";

  static String m19(title) => "Aggiorna ${title}";

  static String m20(title) => "Errore aggiornando ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcast')}";

  static String m22(date) => "Pubblicato il ${date}";

  static String m23(date) => "Rimosso il ${date}";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 sec', one: '${count} sec', other: '${count} sec')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Adesso', one: '${count} secondo fa', other: '${count} secondi fa')}";

  static String m26(count) => "${count} selezionati";

  static String m27(time) => "Ultima riproduzione ${time}";

  static String m28(time) => "${time} Restante";

  static String m29(time) => "A ${time}";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'Nessun aggiornamento', one: 'Aggiornato ${count} episodio', other: 'Aggiornati ${count} episodi')}";

  static String m31(version) => "Versione: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Aggiungi"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Aggiungi i nuovi episodi alla playlist"),
        "addSomeGroups":
            MessageLookupByLibrary.simpleMessage("Aggiungi qualche gruppo"),
        "all": MessageLookupByLibrary.simpleMessage("Tutti"),
        "autoDownload":
            MessageLookupByLibrary.simpleMessage("Download automatico"),
        "back": MessageLookupByLibrary.simpleMessage("Indietro"),
        "boostVolume": MessageLookupByLibrary.simpleMessage("Amplifica volume"),
        "buffering": MessageLookupByLibrary.simpleMessage("Buffering"),
        "cancel": MessageLookupByLibrary.simpleMessage("ANNULLA"),
        "cellularConfirm":
            MessageLookupByLibrary.simpleMessage("Avviso utilizzo dati mobili"),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "Sei sicurǝ di voler usare i dati mobili per il download?"),
        "changeLayout": MessageLookupByLibrary.simpleMessage("Cambia layout"),
        "changelog": MessageLookupByLibrary.simpleMessage("Novità"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Scegli un"),
        "clear": MessageLookupByLibrary.simpleMessage("Pulisici"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Azzera tutto"),
        "color": MessageLookupByLibrary.simpleMessage("colore"),
        "confirm": MessageLookupByLibrary.simpleMessage("CONFERMA"),
        "createNewPlaylist":
            MessageLookupByLibrary.simpleMessage("Nuova playlist"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Tema scuro"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(
            "Questa è la coda predefinita, non può essere rimossa."),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Motore di ricerca podcast predefinito"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Scegli il motore di ricerca predefinito per i podcast"),
        "delete": MessageLookupByLibrary.simpleMessage("Elimina"),
        "developer": MessageLookupByLibrary.simpleMessage("Sviluppatore"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Ignora"),
        "done": MessageLookupByLibrary.simpleMessage("Fatto"),
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("Download rimosso"),
        "downloadStart":
            MessageLookupByLibrary.simpleMessage("Download in corso"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Scaricati"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Modifica nome gruppo"),
        "endOfEpisode":
            MessageLookupByLibrary.simpleMessage("Fine dell\'episodio"),
        "episode": m4,
        "fastForward":
            MessageLookupByLibrary.simpleMessage("Avanzamento rapido"),
        "fastRewind":
            MessageLookupByLibrary.simpleMessage("Riavvolgimento rapido"),
        "featureDiscoveryEditGroup":
            MessageLookupByLibrary.simpleMessage("Tocca per editare il gruppo"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Puoi cambiare il nome del gruppo o eliminarlo da qui, ma il gruppo Home non può essere modificato o eliminato"),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Vista Episodio"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Puoi tenere premuto per riprodurre un episodio o aggiungerlo a una playlist."),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Tieni premuto per riprodurre subito un episodio"),
        "featureDiscoveryGroup":
            MessageLookupByLibrary.simpleMessage("Tocca per aggiungere gruppo"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "I nuovi podcast vengono aggiungi al gruppo Home. Puoi creare nuovi gruppi e spostare lì i podcast o aggiungere un podcast a gruppi diversi."),
        "featureDiscoveryGroupPodcast": MessageLookupByLibrary.simpleMessage(
            "Tieni premuto per riordinare i podcast"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Premi per vedere più opzioni o tieni premuto per riordinare i podcast nel gruppo."),
        "featureDiscoveryOMPL":
            MessageLookupByLibrary.simpleMessage("Tocca per importare un OPML"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Puoi importare file OPML, aprire le impostazioni o ricaricare tutti i podcast da qui."),
        "featureDiscoveryPlaylist": MessageLookupByLibrary.simpleMessage(
            "Tocca per aprire la playlist"),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Puoi aggiungere episodi alle playlist manualmente. Gli episodi saranno automaticamente rimossi dalla playlist quando riprodotti."),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Vista podcast"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Puoi cliccare su \"Visualizza tutti\" per aggiungere gruppi o gestire i podcast."),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Scorri verticalmente per cambiare gruppo"),
        "featureDiscoverySearch":
            MessageLookupByLibrary.simpleMessage("Tap per cercare i podcast"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Puoi cercare per titolo del podcast, parola chiave o feed RSS per iscriverti a un nuovo podcast"),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("Scrivimi"),
        "feedbackGithub":
            MessageLookupByLibrary.simpleMessage("Segnala un problema"),
        "feedbackPlay":
            MessageLookupByLibrary.simpleMessage("Vota sul Play Store"),
        "feedbackTelegram":
            MessageLookupByLibrary.simpleMessage("Unisciti al gruppo"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtra"),
        "fontStyle": MessageLookupByLibrary.simpleMessage("Stile font"),
        "fonts": MessageLookupByLibrary.simpleMessage("Font"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("Buonanotte"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Congratulazioni! Hai collegato con successo il tuo account gpodder.net. Tsacdop sincronizzerà in automatico le tue sottoscrizioni con l\'account gpodder.net."),
        "groupExisted":
            MessageLookupByLibrary.simpleMessage("Il gruppo esiste già"),
        "groupFilter":
            MessageLookupByLibrary.simpleMessage("Filtra per gruppo"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "Sei sicurǝ di voler cancellare questo gruppo? I podcast verranno spostati nel gruppo Home."),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Nascondi ascoltati"),
        "hidePodcastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Nascondi suggerimenti podcast"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Nascondi i suggerimenti podcast nella pagina di ricerca"),
        "homeGroupsSeeAll":
            MessageLookupByLibrary.simpleMessage("Visualizza tutto"),
        "homeMenuPlaylist": MessageLookupByLibrary.simpleMessage("Playlist"),
        "homeSubMenuSortBy": MessageLookupByLibrary.simpleMessage("Ordina per"),
        "homeTabMenuFavotite":
            MessageLookupByLibrary.simpleMessage("Preferiti"),
        "homeTabMenuRecent": MessageLookupByLibrary.simpleMessage("Recenti"),
        "homeToprightMenuAbout":
            MessageLookupByLibrary.simpleMessage("Informazioni"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("Importa OPML"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Ricarica tutto"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("Importa"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Puoi tener premuto sulla scheda di un episodio per le azioni rapide."),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "Iscriviti al podcast tramite ricerca o importando un file OPML."),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Puoi creare gruppi diversi per i podcast."),
        "invalidName":
            MessageLookupByLibrary.simpleMessage("Nome utente non valido"),
        "lastUpdate":
            MessageLookupByLibrary.simpleMessage("Ultimo aggiornamento"),
        "later": MessageLookupByLibrary.simpleMessage("Più tardi"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Tema chiaro"),
        "like": MessageLookupByLibrary.simpleMessage("Like"),
        "likeDate": MessageLookupByLibrary.simpleMessage("Data del like"),
        "liked": MessageLookupByLibrary.simpleMessage("Preferito"),
        "listen": MessageLookupByLibrary.simpleMessage("Ascolta"),
        "listened": MessageLookupByLibrary.simpleMessage("Ascoltato"),
        "loadMore": MessageLookupByLibrary.simpleMessage("Visualizza altri"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginFailed": MessageLookupByLibrary.simpleMessage("Accesso fallito"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "mark": MessageLookupByLibrary.simpleMessage("Segna"),
        "markConfirm":
            MessageLookupByLibrary.simpleMessage("Conferma la selezione"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Segna tutti gli episodi come già letti?"),
        "markListened":
            MessageLookupByLibrary.simpleMessage("Segna come ascoltato"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Segna come non ascoltato"),
        "menu": MessageLookupByLibrary.simpleMessage("Menu"),
        "menuAllPodcasts":
            MessageLookupByLibrary.simpleMessage("Tutti i podcast"),
        "menuMarkAllListened":
            MessageLookupByLibrary.simpleMessage("Segna Tutti Come Ascoltati"),
        "menuViewRSS": MessageLookupByLibrary.simpleMessage("Vai al feed RSS"),
        "menuVisitSite":
            MessageLookupByLibrary.simpleMessage("Vai al sito web"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Rete"),
        "neverAutoUpdate": MessageLookupByLibrary.simpleMessage(
            "Disabilita aggiornamento automatico\n"),
        "newGroup": MessageLookupByLibrary.simpleMessage("Crea nuovo gruppo"),
        "newestFirst":
            MessageLookupByLibrary.simpleMessage("Prima i più recenti"),
        "next": MessageLookupByLibrary.simpleMessage("Successivo"),
        "noEpisodeDownload": MessageLookupByLibrary.simpleMessage(
            "Nessun episodio ancora scaricato"),
        "noEpisodeFavorite": MessageLookupByLibrary.simpleMessage(
            "Nessun episodio ancora inserito"),
        "noEpisodeRecent": MessageLookupByLibrary.simpleMessage(
            "Nessun episodio ancora ricevuto"),
        "noPodcastGroup": MessageLookupByLibrary.simpleMessage(
            "Nessun podcast in questo gruppo"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Non ci sono note disponibili per questo episodio."),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Pannello notifiche"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst":
            MessageLookupByLibrary.simpleMessage("Prima i più vecchi"),
        "passwdRequired":
            MessageLookupByLibrary.simpleMessage("Password obbligatoria"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pause": MessageLookupByLibrary.simpleMessage("Pausa"),
        "play": MessageLookupByLibrary.simpleMessage("Riproduci"),
        "playNext":
            MessageLookupByLibrary.simpleMessage("Riproduci successivo"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Aggiungi episodio in testa alla playlist"),
        "playback":
            MessageLookupByLibrary.simpleMessage("Controlli riproduzione"),
        "player": MessageLookupByLibrary.simpleMessage("Player"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Medio"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Basso"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Alto"),
        "playing": MessageLookupByLibrary.simpleMessage("Riproducendo"),
        "playlistExisted":
            MessageLookupByLibrary.simpleMessage("Nome playlist già esistente"),
        "playlistNameEmpty":
            MessageLookupByLibrary.simpleMessage("Nome playlist vuoto"),
        "playlists": MessageLookupByLibrary.simpleMessage("Playlist"),
        "plugins": MessageLookupByLibrary.simpleMessage("Plugin"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Iscritto al podcast"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Download episodio"),
        "popupMenuLaterDes": MessageLookupByLibrary.simpleMessage(
            "Aggiungi episodio alla playlist"),
        "popupMenuLikeDes": MessageLookupByLibrary.simpleMessage(
            "Aggiungi episodio ai preferiti"),
        "popupMenuMarkDes": MessageLookupByLibrary.simpleMessage(
            "Segna episodio come ascoltato"),
        "popupMenuPlayDes":
            MessageLookupByLibrary.simpleMessage("Riproduci l\'episodio"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "published": m22,
        "publishedDaily":
            MessageLookupByLibrary.simpleMessage("Pubblicato quotidianamente"),
        "publishedMonthly":
            MessageLookupByLibrary.simpleMessage("Pubblicato mensilmente"),
        "publishedWeekly":
            MessageLookupByLibrary.simpleMessage("Pubblicato settimanalmente"),
        "publishedYearly":
            MessageLookupByLibrary.simpleMessage("Pubblicato annualmente"),
        "queue": MessageLookupByLibrary.simpleMessage("Coda"),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Recupera iscrizione"),
        "refresh": MessageLookupByLibrary.simpleMessage("Ricarica"),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Aggiorna copertine"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Aggiornando"),
        "remove": MessageLookupByLibrary.simpleMessage("Rimuovi"),
        "removeConfirm":
            MessageLookupByLibrary.simpleMessage("Conferma la rimozione"),
        "removeNewMark": MessageLookupByLibrary.simpleMessage(
            "Rimuovi simbolo di \"nuovo\""),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "Sei sicurǝ di volerti disiscrivere?"),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Salva"),
        "schedule": MessageLookupByLibrary.simpleMessage("Programmazione"),
        "search": MessageLookupByLibrary.simpleMessage("Cerca"),
        "searchEpisode": MessageLookupByLibrary.simpleMessage("Cerca episodio"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Scrivi il nome del podcast, una parola chiave o un url di feed."),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Link RSS invalido"),
        "searchPodcast":
            MessageLookupByLibrary.simpleMessage("Cerca un podcast"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage": MessageLookupByLibrary.simpleMessage("Archiviazione"),
        "settings": MessageLookupByLibrary.simpleMessage("Impostazioni"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Tinta colore"),
        "settingsAccentColorDes":
            MessageLookupByLibrary.simpleMessage("Includi il colore del tema"),
        "settingsAppIntro": MessageLookupByLibrary.simpleMessage("Tutorial"),
        "settingsAppearance": MessageLookupByLibrary.simpleMessage("Aspetto"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Colori e temi"),
        "settingsAudioCache":
            MessageLookupByLibrary.simpleMessage("Cache audio"),
        "settingsAudioCacheDes": MessageLookupByLibrary.simpleMessage(
            "Dimensione massima cache audio"),
        "settingsAutoDelete": MessageLookupByLibrary.simpleMessage(
            "Cancella automaticamente i download dopo"),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("Predefinito 30 giorni"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Riproduci automaticamente il prossimo episodio"),
        "settingsBackup": MessageLookupByLibrary.simpleMessage("Backup"),
        "settingsBackupDes":
            MessageLookupByLibrary.simpleMessage("Salva i dati dell\'app"),
        "settingsBoostVolume": MessageLookupByLibrary.simpleMessage(
            "Livello di amplificazione del volume"),
        "settingsBoostVolumeDes": MessageLookupByLibrary.simpleMessage(
            "Cambia il livello di amplificazione del volume"),
        "settingsDefaultGrid":
            MessageLookupByLibrary.simpleMessage("Vista a griglia predefinita"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("Scheda Download"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Scheda Preferiti"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Pagina del podcast"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("Scheda Recenti"),
        "settingsDiscovery": MessageLookupByLibrary.simpleMessage(
            "Attiva nuovamente il tutorial"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("Cartella download"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Abilita sincronizzazione"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Ricarica tutti i podcast in background per ottenere gli ultimi episodi"),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Esporta e importa le impostazioni dell\'app"),
        "settingsFastForwardSec":
            MessageLookupByLibrary.simpleMessage("Secondi avanzamento rapido"),
        "settingsFastForwardSecDes": MessageLookupByLibrary.simpleMessage(
            "Modifica i secondi di avanzamento nel player"),
        "settingsFeedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsFeedbackDes": MessageLookupByLibrary.simpleMessage(
            "Bug e richieste di funzionalità"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("Cronologia"),
        "settingsHistoryDes":
            MessageLookupByLibrary.simpleMessage("Data di ascolto"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Informazioni"),
        "settingsInterface":
            MessageLookupByLibrary.simpleMessage("Interfaccia"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Lingue"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Cambia lingua"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Layout"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Layout dell\'app"),
        "settingsLibraries": MessageLookupByLibrary.simpleMessage("Librerie"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Librerie open source usate in questa app"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("Gestisci i download"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "Gestisci i file audio scaricati"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Segna come ascoltato quando saltato"),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Segna automaticamente l\'episodio come ascoltato quando si passa al successivo\n"),
        "settingsMenuAutoPlay": MessageLookupByLibrary.simpleMessage(
            "Riproduci automaticamente successivo"),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Chiedi prima di usare i dati mobili"),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Download automatico con dati mobili"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "Puoi configurare il download automatico dei podcast nella pagina impostazioni del gruppo"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Chiedi conferma del download automatico con dati mobili"),
        "settingsPlayDes":
            MessageLookupByLibrary.simpleMessage("Playlist e player"),
        "settingsPlayerHeight": MessageLookupByLibrary.simpleMessage(
            "Altezza barra di riproduzione"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Cambia l\'altezza del widget di riproduzione"),
        "settingsPopupMenu":
            MessageLookupByLibrary.simpleMessage("Menu popup episodi"),
        "settingsPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Cambia il menu popup degli episodi"),
        "settingsPrefrence": MessageLookupByLibrary.simpleMessage("Preferenze"),
        "settingsRealDark": MessageLookupByLibrary.simpleMessage("Molto scuro"),
        "settingsRealDarkDes": MessageLookupByLibrary.simpleMessage(
            "Attiva se il tema scuro non è abbastanza scuro"),
        "settingsRewindSec":
            MessageLookupByLibrary.simpleMessage("Secondi riavvolgimento"),
        "settingsRewindSecDes": MessageLookupByLibrary.simpleMessage(
            "Modifica i secondi di riavvolgimento nel player"),
        "settingsSTAuto": MessageLookupByLibrary.simpleMessage(
            "Abilita automaticamente timer notturno\n"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Avvia automaticamente il timer notturno all\'orario scelto"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Ora predefinita"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Ora predefinita timer notturno"),
        "settingsSTMode": MessageLookupByLibrary.simpleMessage(
            "Modalità timer notturno automatico"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Velocità"),
        "settingsSpeedsDes": MessageLookupByLibrary.simpleMessage(
            "Personalizza le velocità disponibili"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Impostazioni cache e archivio dei download"),
        "settingsSyncing":
            MessageLookupByLibrary.simpleMessage("Sincronizzazione"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Aggiorna podcast in background"),
        "settingsTapToOpenPopupMenu":
            MessageLookupByLibrary.simpleMessage("Tocca per aprire il menu"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Tieni premuto per aprire la pagina dell\'episodio"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Tema"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Intervallo di aggiornamento"),
        "settingsUpdateIntervalDes":
            MessageLookupByLibrary.simpleMessage("Predefinito 24 ore"),
        "share": MessageLookupByLibrary.simpleMessage("Condividi"),
        "showNotesFonts":
            MessageLookupByLibrary.simpleMessage("Mostra il font delle note"),
        "size": MessageLookupByLibrary.simpleMessage("Dimensione"),
        "skipSecondsAtEnd":
            MessageLookupByLibrary.simpleMessage("Salta secondi al termine"),
        "skipSecondsAtStart":
            MessageLookupByLibrary.simpleMessage("Salta secondi all\'inizio"),
        "skipSilence": MessageLookupByLibrary.simpleMessage("Salta i silenzi"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("Salta al prossimo"),
        "sleepTimer": MessageLookupByLibrary.simpleMessage("Timer notturno"),
        "status": MessageLookupByLibrary.simpleMessage("Stato"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage("Errore di autenticazione"),
        "statusFail":
            MessageLookupByLibrary.simpleMessage("Sincronizzazione fallita"),
        "statusSuccess":
            MessageLookupByLibrary.simpleMessage("Sincronizzazione avvenuta"),
        "stop": MessageLookupByLibrary.simpleMessage("Stop"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Iscriviti"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Esporta file OPML di tutti i podcast"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Sincronizza ora"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Predefinito di sistema"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist":
            MessageLookupByLibrary.simpleMessage("Aggiunto alla playlist"),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Tutorial abilitato, riapri l\'applicazione per visualizzarlo"),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Errore file, iscrizione fallita"),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("File non valido"),
        "toastHomeGroupNotSupport": MessageLookupByLibrary.simpleMessage(
            "Il gruppo Home non è supportato"),
        "toastImportSettingsSuccess": MessageLookupByLibrary.simpleMessage(
            "Impostazioni importate correttamente"),
        "toastOneGroup":
            MessageLookupByLibrary.simpleMessage("Seleziona almeno un gruppo"),
        "toastPodcastRecovering": MessageLookupByLibrary.simpleMessage(
            "Recuperando, attendi un attimo"),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("File letto con successo"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Recupero del podcast fallito"),
        "toastRemovePlaylist": MessageLookupByLibrary.simpleMessage(
            "Episodio rimosso dalla playlist"),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Impostazioni salvate"),
        "toastTimeEqualEnd": MessageLookupByLibrary.simpleMessage(
            "Il tempo è uguale al tempo di fine"),
        "toastTimeEqualStart": MessageLookupByLibrary.simpleMessage(
            "Il tempo è uguale al tempo d\'inizio"),
        "translators": MessageLookupByLibrary.simpleMessage("Traduttori"),
        "understood": MessageLookupByLibrary.simpleMessage("Ho capito"),
        "undo": MessageLookupByLibrary.simpleMessage("ANNULLA"),
        "unlike": MessageLookupByLibrary.simpleMessage("Rimuovi like"),
        "unliked": MessageLookupByLibrary.simpleMessage(
            "Episodio rimosso dai preferiti"),
        "updateDate":
            MessageLookupByLibrary.simpleMessage("Data di aggiornamento"),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Aggiornamento fallito, errore di rete"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Nome utente"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Nome utente obbligatorio"),
        "version": m31
      };
}
