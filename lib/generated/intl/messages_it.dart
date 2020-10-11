// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static m0(groupName, count) => "${Intl.plural(count, zero: '', one: '${count} episodio di ${groupName} aggiunto alla playlist', other: '${count} episodi di ${groupName} aggiunti alla playlist')}";

  static m1(count) => "${Intl.plural(count, zero: '', one: '${count} episodio aggiunto alla playlist', other: '${count} episodi aggiunti alla playlist')}";

  static m2(count) => "${Intl.plural(count, zero: '', one: '${count} giorno fa', other: '${count} giorni fa')}";

  static m3(count) => "${Intl.plural(count, zero: '', one: '${count} giorno', other: '${count} giorni')}";

  static m4(count) => "${Intl.plural(count, zero: '', one: 'Episodio', other: 'Episodi')}";

  static m5(time) => "Da ${time}";

  static m6(count) => "${Intl.plural(count, zero: '', one: 'Gruppo', other: 'Gruppi')}";

  static m7(host) => "Hostato su ${host}";

  static m8(count) => "${Intl.plural(count, zero: '', one: '${count} ora fa', other: '${count} ore fa')}";

  static m9(count) => "${Intl.plural(count, zero: '', one: '${count} ora', other: '${count} ore')}";

  static m10(service) => "Integrato con ${service}";

  static m11(userName) => "Accesso effettuato come ${userName}";

  static m12(count) => "${Intl.plural(count, zero: '', one: '${count} minuto fa', other: '${count} minuti fa')}";

  static m13(count) => "${Intl.plural(count, zero: '', one: '${count} min', other: '${count} min')}";

  static m14(title) => "Recupera dati ${title}";

  static m15(title) => "Sottoscrizione fallita, errore di rete ${title}";

  static m16(title) => "Sottoscrivi ${title}";

  static m17(title) => "Sottoscrizione fallita, il podcast esiste già ${title}\n";

  static m18(title) => "Sottoscrizione con successo ${title}";

  static m19(title) => "Aggiorna ${title}";

  static m20(title) => "Errore di aggiornamento ${title}";

  static m21(count) => "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcast')}";

  static m22(date) => "Pubblicato il ${date}";

  static m23(date) => "Rimosso il ${date}";

  static m24(count) => "${Intl.plural(count, zero: '', one: '${count} sec', other: '${count} sec')}";

  static m25(count) => "${Intl.plural(count, zero: '', one: '${count} secondo fa', other: '${count} secondi fa')}";

  static m26(time) => "Ultima riproduzione ${time}";

  static m27(time) => "${time} Restante";

  static m28(time) => "A ${time}";

  static m29(count) => "${Intl.plural(count, zero: '', one: 'Aggiornato ${count} episodio', other: 'Aggiornati ${count} episodi')}";

  static m30(version) => "Versione: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("Aggiungi"),
    "addEpisodeGroup" : m0,
    "addNewEpisodeAll" : m1,
    "addNewEpisodeTooltip" : MessageLookupByLibrary.simpleMessage("Aggiungi i nuovi episodi alla playlist"),
    "addSomeGroups" : MessageLookupByLibrary.simpleMessage("Aggiungi un gruppo"),
    "all" : MessageLookupByLibrary.simpleMessage("Tutti"),
    "autoDownload" : MessageLookupByLibrary.simpleMessage("Scarica automaticamente"),
    "back" : MessageLookupByLibrary.simpleMessage("Indietro"),
    "boostVolume" : MessageLookupByLibrary.simpleMessage("Aumenta il volume"),
    "buffering" : MessageLookupByLibrary.simpleMessage("In caricamento"),
    "cancel" : MessageLookupByLibrary.simpleMessage("ANNULLA"),
    "cellularConfirm" : MessageLookupByLibrary.simpleMessage("Avvertimento per l\'utilizzo dei dati mobili"),
    "cellularConfirmDes" : MessageLookupByLibrary.simpleMessage("Sei sicurǝ di voler usare i dati mobili per lo scaricamento?"),
    "changeLayout" : MessageLookupByLibrary.simpleMessage("Cambia l\'interfaccia"),
    "changelog" : MessageLookupByLibrary.simpleMessage("Novità"),
    "chooseA" : MessageLookupByLibrary.simpleMessage("Scegli un"),
    "clear" : MessageLookupByLibrary.simpleMessage("Pulisici"),
    "color" : MessageLookupByLibrary.simpleMessage("colore"),
    "confirm" : MessageLookupByLibrary.simpleMessage("CONFERMA"),
    "darkMode" : MessageLookupByLibrary.simpleMessage("Modalità scura"),
    "daysAgo" : m2,
    "daysCount" : m3,
    "defaultSearchEngine" : MessageLookupByLibrary.simpleMessage("Default podcast search engine"),
    "defaultSearchEngineDes" : MessageLookupByLibrary.simpleMessage("Choose the default podcast search engine"),
    "delete" : MessageLookupByLibrary.simpleMessage("Elimina"),
    "developer" : MessageLookupByLibrary.simpleMessage("Sviluppatore"),
    "dismiss" : MessageLookupByLibrary.simpleMessage("Ignora"),
    "done" : MessageLookupByLibrary.simpleMessage("Fatto"),
    "download" : MessageLookupByLibrary.simpleMessage("Scarica"),
    "downloadRemovedToast" : MessageLookupByLibrary.simpleMessage("Download rimosso"),
    "downloadStart" : MessageLookupByLibrary.simpleMessage("Scaricamento"),
    "downloaded" : MessageLookupByLibrary.simpleMessage("Scaricati"),
    "editGroupName" : MessageLookupByLibrary.simpleMessage("Modifica nome del gruppo"),
    "endOfEpisode" : MessageLookupByLibrary.simpleMessage("Fine dell\'episodio"),
    "episode" : m4,
    "fastForward" : MessageLookupByLibrary.simpleMessage("Avanti veloci"),
    "fastRewind" : MessageLookupByLibrary.simpleMessage("Riavvolgimento veloce"),
    "featureDiscoveryEditGroup" : MessageLookupByLibrary.simpleMessage("Tocca per editare il gruppo"),
    "featureDiscoveryEditGroupDes" : MessageLookupByLibrary.simpleMessage("Puoi cambiare il nome del gruppo o eliminarlo da qui, ma il gruppo Home non può essere modificato o eliminato"),
    "featureDiscoveryEpisode" : MessageLookupByLibrary.simpleMessage("Vista Episodio"),
    "featureDiscoveryEpisodeDes" : MessageLookupByLibrary.simpleMessage("Puoi tenere premuto per riprodurre un episodio o aggiungerlo a una playlist."),
    "featureDiscoveryEpisodeTitle" : MessageLookupByLibrary.simpleMessage("Tieni premuto per riprodurre subito un episodio"),
    "featureDiscoveryGroup" : MessageLookupByLibrary.simpleMessage("Tocca per aggiungere gruppo"),
    "featureDiscoveryGroupDes" : MessageLookupByLibrary.simpleMessage("I nuovi podcast vengono aggiungi di default al gruppo Home. Puoi creare nuovi gruppi e spostare lì i podcast o aggiungere un podcast a gruppi diversi."),
    "featureDiscoveryGroupPodcast" : MessageLookupByLibrary.simpleMessage("Tieni premuto per riordinare i podcast"),
    "featureDiscoveryGroupPodcastDes" : MessageLookupByLibrary.simpleMessage("Premi per vedere più opzioni o tieni premuto per riordinare i podcast nel gruppo."),
    "featureDiscoveryOMPL" : MessageLookupByLibrary.simpleMessage("Tocca per importare un OPML"),
    "featureDiscoveryOMPLDes" : MessageLookupByLibrary.simpleMessage("Puoi importare i file OPML, aprire le impostazioni o ricaricare tutti i podcast da qui."),
    "featureDiscoveryPlaylist" : MessageLookupByLibrary.simpleMessage("Tocca per aprire la playlist"),
    "featureDiscoveryPlaylistDes" : MessageLookupByLibrary.simpleMessage("Puoi aggiungere agli episodi alle playlist manualmente. Gli episodi verranno rimossi automaticamente dalla playlist quando riprodotti. "),
    "featureDiscoveryPodcast" : MessageLookupByLibrary.simpleMessage("Vista Podcast"),
    "featureDiscoveryPodcastDes" : MessageLookupByLibrary.simpleMessage("Puoi cliccare su \"Visualizza tutti\" per aggiungere gruppi o gestire i podcast."),
    "featureDiscoveryPodcastTitle" : MessageLookupByLibrary.simpleMessage("Scorri verticalmente per cambiare gruppo"),
    "featureDiscoverySearch" : MessageLookupByLibrary.simpleMessage("Tap per cercare i podcast"),
    "featureDiscoverySearchDes" : MessageLookupByLibrary.simpleMessage("Puoi cercare per titolo del podcast, parola chiave o feed RSS per iscriverti a un nuovo podcast"),
    "feedbackEmail" : MessageLookupByLibrary.simpleMessage("Scrivimi"),
    "feedbackGithub" : MessageLookupByLibrary.simpleMessage("Segnala un problema"),
    "feedbackPlay" : MessageLookupByLibrary.simpleMessage("Vota sul Play Store"),
    "feedbackTelegram" : MessageLookupByLibrary.simpleMessage("Unisciti al gruppo"),
    "filter" : MessageLookupByLibrary.simpleMessage("Filtro"),
    "fontStyle" : MessageLookupByLibrary.simpleMessage("Stile dei caratteri"),
    "fonts" : MessageLookupByLibrary.simpleMessage("Font"),
    "from" : m5,
    "goodNight" : MessageLookupByLibrary.simpleMessage("Buonanotte"),
    "gpodderLoginDes" : MessageLookupByLibrary.simpleMessage("Congratulazioni! Hai collegato con successo il tuo account gpodder.net. Tsacdop sincronizzerà in automatico le tue sottoscrizioni con l\'account gpodder.net."),
    "groupExisted" : MessageLookupByLibrary.simpleMessage("Il gruppo esiste già"),
    "groupFilter" : MessageLookupByLibrary.simpleMessage("Filtro di gruppo"),
    "groupRemoveConfirm" : MessageLookupByLibrary.simpleMessage("Sei sicurǝ di voler cancellare questo gruppo? I podcast verranno spostati nel gruppo Home."),
    "groups" : m6,
    "hideListenedSetting" : MessageLookupByLibrary.simpleMessage("Nascondi ascoltati"),
    "hidePodcastDiscovery" : MessageLookupByLibrary.simpleMessage("Hide podcast discovery"),
    "hidePodcastDiscoveryDes" : MessageLookupByLibrary.simpleMessage("Hide podcast discovery in search page"),
    "homeGroupsSeeAll" : MessageLookupByLibrary.simpleMessage("Visualizza tutto"),
    "homeMenuPlaylist" : MessageLookupByLibrary.simpleMessage("Playlist"),
    "homeSubMenuSortBy" : MessageLookupByLibrary.simpleMessage("Ordina per"),
    "homeTabMenuFavotite" : MessageLookupByLibrary.simpleMessage("Preferiti"),
    "homeTabMenuRecent" : MessageLookupByLibrary.simpleMessage("Recenti"),
    "homeToprightMenuAbout" : MessageLookupByLibrary.simpleMessage("A proposito di"),
    "homeToprightMenuImportOMPL" : MessageLookupByLibrary.simpleMessage("Importa OPML"),
    "homeToprightMenuRefreshAll" : MessageLookupByLibrary.simpleMessage("Ricarica tutto"),
    "hostedOn" : m7,
    "hoursAgo" : m8,
    "hoursCount" : m9,
    "import" : MessageLookupByLibrary.simpleMessage("Importa"),
    "intergateWith" : m10,
    "introFourthPage" : MessageLookupByLibrary.simpleMessage("Puoi tener premuto sulla scheda di un episodio per le azioni rapide"),
    "introSecondPage" : MessageLookupByLibrary.simpleMessage("Sottoscrivi podcast dalla ricerca o importando un file OPML"),
    "introThirdPage" : MessageLookupByLibrary.simpleMessage("Puoi creare gruppi diversi per i podcast."),
    "invalidName" : MessageLookupByLibrary.simpleMessage("Nome utente non valido"),
    "lastUpdate" : MessageLookupByLibrary.simpleMessage("Ultimo aggiornamento"),
    "later" : MessageLookupByLibrary.simpleMessage("Più tardi"),
    "lightMode" : MessageLookupByLibrary.simpleMessage("Modalità chiara"),
    "like" : MessageLookupByLibrary.simpleMessage("Mi piace"),
    "likeDate" : MessageLookupByLibrary.simpleMessage("Data Preferito"),
    "liked" : MessageLookupByLibrary.simpleMessage("Preferito"),
    "listen" : MessageLookupByLibrary.simpleMessage("Ascolta"),
    "listened" : MessageLookupByLibrary.simpleMessage("Ascoltato"),
    "loadMore" : MessageLookupByLibrary.simpleMessage("Carica altri"),
    "loggedInAs" : m11,
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "loginFailed" : MessageLookupByLibrary.simpleMessage("Accesso fallito"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "mark" : MessageLookupByLibrary.simpleMessage("Segna"),
    "markConfirm" : MessageLookupByLibrary.simpleMessage("Conferma la selezione"),
    "markConfirmContent" : MessageLookupByLibrary.simpleMessage("Segna tutti gli episodi come già letti?"),
    "markListened" : MessageLookupByLibrary.simpleMessage("Segna come ascoltato"),
    "markNotListened" : MessageLookupByLibrary.simpleMessage("Segna come non ascoltato"),
    "menu" : MessageLookupByLibrary.simpleMessage("Menu"),
    "menuAllPodcasts" : MessageLookupByLibrary.simpleMessage("Tutti i podcast"),
    "menuMarkAllListened" : MessageLookupByLibrary.simpleMessage("Segna tutto come ascoltato"),
    "menuViewRSS" : MessageLookupByLibrary.simpleMessage("Visita feed RSS"),
    "menuVisitSite" : MessageLookupByLibrary.simpleMessage("Visita sito web"),
    "minsAgo" : m12,
    "minsCount" : m13,
    "network" : MessageLookupByLibrary.simpleMessage("Rete"),
    "neverAutoUpdate" : MessageLookupByLibrary.simpleMessage("Disabilita aggiornamento automatico\n"),
    "newGroup" : MessageLookupByLibrary.simpleMessage("Crea un nuovo gruppo"),
    "newestFirst" : MessageLookupByLibrary.simpleMessage("Prima i più recenti"),
    "next" : MessageLookupByLibrary.simpleMessage("Successivo"),
    "noEpisodeDownload" : MessageLookupByLibrary.simpleMessage("Nessun episodio ancora scarticato"),
    "noEpisodeFavorite" : MessageLookupByLibrary.simpleMessage("Nessun episodio ancora trovato"),
    "noEpisodeRecent" : MessageLookupByLibrary.simpleMessage("Nessun episodio ancora ricevuto"),
    "noPodcastGroup" : MessageLookupByLibrary.simpleMessage("Nessun podcast in questo gruppo"),
    "noShownote" : MessageLookupByLibrary.simpleMessage("Non ci sono note disponibili per questo episodio."),
    "notificaitonFatch" : m14,
    "notificationNetworkError" : m15,
    "notificationSetting" : MessageLookupByLibrary.simpleMessage("Pannello di notifiche"),
    "notificationSubscribe" : m16,
    "notificationSubscribeExisted" : m17,
    "notificationSuccess" : m18,
    "notificationUpdate" : m19,
    "notificationUpdateError" : m20,
    "oldestFirst" : MessageLookupByLibrary.simpleMessage("Prima i più vecchi"),
    "passwdRequired" : MessageLookupByLibrary.simpleMessage("Password obbligatoria"),
    "password" : MessageLookupByLibrary.simpleMessage("Password"),
    "pause" : MessageLookupByLibrary.simpleMessage("Pausa"),
    "play" : MessageLookupByLibrary.simpleMessage("Riproduci"),
    "playback" : MessageLookupByLibrary.simpleMessage("Controlli di riproduzione"),
    "player" : MessageLookupByLibrary.simpleMessage("Player"),
    "playerHeightMed" : MessageLookupByLibrary.simpleMessage("Medio"),
    "playerHeightShort" : MessageLookupByLibrary.simpleMessage("Basso"),
    "playerHeightTall" : MessageLookupByLibrary.simpleMessage("Alto"),
    "playing" : MessageLookupByLibrary.simpleMessage("In riproduzione"),
    "plugins" : MessageLookupByLibrary.simpleMessage("Plugin"),
    "podcast" : m21,
    "podcastSubscribed" : MessageLookupByLibrary.simpleMessage("Podcast sottoscritto"),
    "popupMenuDownloadDes" : MessageLookupByLibrary.simpleMessage("Scarica episodio"),
    "popupMenuLaterDes" : MessageLookupByLibrary.simpleMessage("Aggiungi episodio alla playlist"),
    "popupMenuLikeDes" : MessageLookupByLibrary.simpleMessage("Aggiungi episodio ai preferiti"),
    "popupMenuMarkDes" : MessageLookupByLibrary.simpleMessage("Segna episodio come ascoltato"),
    "popupMenuPlayDes" : MessageLookupByLibrary.simpleMessage("Riproduci l\'episodio"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "published" : m22,
    "publishedDaily" : MessageLookupByLibrary.simpleMessage("Pubblicato quotidianamente"),
    "publishedMonthly" : MessageLookupByLibrary.simpleMessage("Pubblicato mensilmente"),
    "publishedWeekly" : MessageLookupByLibrary.simpleMessage("Pubblicato settimanalmente"),
    "publishedYearly" : MessageLookupByLibrary.simpleMessage("Pubblicato annualmente"),
    "recoverSubscribe" : MessageLookupByLibrary.simpleMessage("Recupera sottoscrizione"),
    "refreshArtwork" : MessageLookupByLibrary.simpleMessage("Aggiorna le copertine"),
    "refreshStarted" : MessageLookupByLibrary.simpleMessage("Ricarica"),
    "remove" : MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "removeConfirm" : MessageLookupByLibrary.simpleMessage("Conferma la rimozione"),
    "removePodcastDes" : MessageLookupByLibrary.simpleMessage("Sei sicurǝ di volerti disiscrivere?"),
    "removedAt" : m23,
    "save" : MessageLookupByLibrary.simpleMessage("Salva"),
    "schedule" : MessageLookupByLibrary.simpleMessage("Programmazione"),
    "search" : MessageLookupByLibrary.simpleMessage("Cerca"),
    "searchEpisode" : MessageLookupByLibrary.simpleMessage("Cerca episodio"),
    "searchHelper" : MessageLookupByLibrary.simpleMessage("Type the podcast name, keywords or enter a feed url."),
    "searchInvalidRss" : MessageLookupByLibrary.simpleMessage("Link RSS invalido"),
    "searchPodcast" : MessageLookupByLibrary.simpleMessage("Cerca un podcast"),
    "secCount" : m24,
    "secondsAgo" : m25,
    "settingStorage" : MessageLookupByLibrary.simpleMessage("Spazio di archiviazione"),
    "settings" : MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "settingsAccentColor" : MessageLookupByLibrary.simpleMessage("Accento"),
    "settingsAccentColorDes" : MessageLookupByLibrary.simpleMessage("Scegli il colore del tema"),
    "settingsAppIntro" : MessageLookupByLibrary.simpleMessage("Intro dell\'app"),
    "settingsAppearance" : MessageLookupByLibrary.simpleMessage("Aspetto"),
    "settingsAppearanceDes" : MessageLookupByLibrary.simpleMessage("Colori e tema"),
    "settingsAudioCache" : MessageLookupByLibrary.simpleMessage("Cache audio"),
    "settingsAudioCacheDes" : MessageLookupByLibrary.simpleMessage("Dimensione massima cache audio"),
    "settingsAutoDelete" : MessageLookupByLibrary.simpleMessage("Cancella automaticamente i download dopo"),
    "settingsAutoDeleteDes" : MessageLookupByLibrary.simpleMessage("Default 30 giorni"),
    "settingsAutoPlayDes" : MessageLookupByLibrary.simpleMessage("Riproduci automaticamente il prossimo episodio"),
    "settingsBackup" : MessageLookupByLibrary.simpleMessage("Backup"),
    "settingsBackupDes" : MessageLookupByLibrary.simpleMessage("Salva i dati dell\'app"),
    "settingsBoostVolume" : MessageLookupByLibrary.simpleMessage("Livello di amplificazione del volume"),
    "settingsBoostVolumeDes" : MessageLookupByLibrary.simpleMessage("Cambia il livello di amplificazione del volume"),
    "settingsDefaultGrid" : MessageLookupByLibrary.simpleMessage("Griglia di default"),
    "settingsDefaultGridDownload" : MessageLookupByLibrary.simpleMessage("Scheda Download"),
    "settingsDefaultGridFavorite" : MessageLookupByLibrary.simpleMessage("Scheda Preferiti"),
    "settingsDefaultGridPodcast" : MessageLookupByLibrary.simpleMessage("Pagina del podcast"),
    "settingsDefaultGridRecent" : MessageLookupByLibrary.simpleMessage("Scheda Recenti"),
    "settingsDiscovery" : MessageLookupByLibrary.simpleMessage("Abilita nuovamente il tutorial"),
    "settingsDownloadPosition" : MessageLookupByLibrary.simpleMessage("Download position"),
    "settingsEnableSyncing" : MessageLookupByLibrary.simpleMessage("Abilita sincronizzazione"),
    "settingsEnableSyncingDes" : MessageLookupByLibrary.simpleMessage("Ricarica tutti i podcast in background per ottenere gli ultimi episodi"),
    "settingsExportDes" : MessageLookupByLibrary.simpleMessage("Esporta e importa le impostazioni dell\'app"),
    "settingsFastForwardSec" : MessageLookupByLibrary.simpleMessage("Avanzamento rapido"),
    "settingsFastForwardSecDes" : MessageLookupByLibrary.simpleMessage("Cambia i secondi di avanzamento nella riproduzione"),
    "settingsFeedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "settingsFeedbackDes" : MessageLookupByLibrary.simpleMessage("Segnalazione bug e richieste di funzionalità"),
    "settingsHistory" : MessageLookupByLibrary.simpleMessage("Storico"),
    "settingsHistoryDes" : MessageLookupByLibrary.simpleMessage("Data di ascolto"),
    "settingsInfo" : MessageLookupByLibrary.simpleMessage("Informazioni"),
    "settingsInterface" : MessageLookupByLibrary.simpleMessage("Interfaccia"),
    "settingsLanguages" : MessageLookupByLibrary.simpleMessage("Lingue"),
    "settingsLanguagesDes" : MessageLookupByLibrary.simpleMessage("Cambia lingua"),
    "settingsLayout" : MessageLookupByLibrary.simpleMessage("Layout"),
    "settingsLayoutDes" : MessageLookupByLibrary.simpleMessage("Layout dell\'app"),
    "settingsLibraries" : MessageLookupByLibrary.simpleMessage("Librerie"),
    "settingsLibrariesDes" : MessageLookupByLibrary.simpleMessage("Librerie Open Source usate in questa app"),
    "settingsManageDownload" : MessageLookupByLibrary.simpleMessage("Gestisci i download"),
    "settingsManageDownloadDes" : MessageLookupByLibrary.simpleMessage("Gestisci i file audio scaricati"),
    "settingsMarkListenedSkip" : MessageLookupByLibrary.simpleMessage("Mark as listened when skipped"),
    "settingsMarkListenedSkipDes" : MessageLookupByLibrary.simpleMessage("Auto mark episode as listened when it was skipped to next"),
    "settingsMenuAutoPlay" : MessageLookupByLibrary.simpleMessage("Riproduci automaticamente"),
    "settingsNetworkCellular" : MessageLookupByLibrary.simpleMessage("Chiedi prima di usare i dati mobili"),
    "settingsNetworkCellularAuto" : MessageLookupByLibrary.simpleMessage("Scarica automaticamente usando i dati mobili"),
    "settingsNetworkCellularAutoDes" : MessageLookupByLibrary.simpleMessage("Puoi configurare lo scaricamento automatico dei podcast nella pagina delle impostazioni di gruppo"),
    "settingsNetworkCellularDes" : MessageLookupByLibrary.simpleMessage("Chiedi conferma quando utilizzi di dati mobili per scaricare gli episodi"),
    "settingsPlayDes" : MessageLookupByLibrary.simpleMessage("Playlist e player"),
    "settingsPlayerHeight" : MessageLookupByLibrary.simpleMessage("Altezza della barra di riproduzione"),
    "settingsPlayerHeightDes" : MessageLookupByLibrary.simpleMessage("Cambia l\'altezza del widget di riproduzione"),
    "settingsPopupMenu" : MessageLookupByLibrary.simpleMessage("Menu a comparsa degli episodi"),
    "settingsPopupMenuDes" : MessageLookupByLibrary.simpleMessage("Cambia il menu a comparsa degli episodi"),
    "settingsPrefrence" : MessageLookupByLibrary.simpleMessage("Preferenze"),
    "settingsRealDark" : MessageLookupByLibrary.simpleMessage("Oscurità"),
    "settingsRealDarkDes" : MessageLookupByLibrary.simpleMessage("Attiva se la versione notte non è abbastanza scura"),
    "settingsRewindSec" : MessageLookupByLibrary.simpleMessage("Riavvolgimento rapido"),
    "settingsRewindSecDes" : MessageLookupByLibrary.simpleMessage("Cambia i secondi di riavvolgimento nella riproduzione"),
    "settingsSTAuto" : MessageLookupByLibrary.simpleMessage("Abilita automaticamente il tempo di standby\n"),
    "settingsSTAutoDes" : MessageLookupByLibrary.simpleMessage("Avvia automaticamente il tempo di standby a un orario programmato"),
    "settingsSTDefaultTime" : MessageLookupByLibrary.simpleMessage("Tempo di default"),
    "settingsSTDefautTimeDes" : MessageLookupByLibrary.simpleMessage("Tempo di default di standby"),
    "settingsSTMode" : MessageLookupByLibrary.simpleMessage("Modalità automatica del tempo di standby"),
    "settingsSpeeds" : MessageLookupByLibrary.simpleMessage("Velocità"),
    "settingsSpeedsDes" : MessageLookupByLibrary.simpleMessage("Personalizza le velocità disponibili"),
    "settingsStorageDes" : MessageLookupByLibrary.simpleMessage("Impostazioni cache e archivio dei download"),
    "settingsSyncing" : MessageLookupByLibrary.simpleMessage("Sincronizzazione"),
    "settingsSyncingDes" : MessageLookupByLibrary.simpleMessage("Ricarica podcast in background"),
    "settingsTapToOpenPopupMenu" : MessageLookupByLibrary.simpleMessage("Tocca per aprire il menu"),
    "settingsTapToOpenPopupMenuDes" : MessageLookupByLibrary.simpleMessage("Tieni premuto per aprire la pagina dell\'episodio"),
    "settingsTheme" : MessageLookupByLibrary.simpleMessage("Tema"),
    "settingsUpdateInterval" : MessageLookupByLibrary.simpleMessage("Intervallo di aggiornamento"),
    "settingsUpdateIntervalDes" : MessageLookupByLibrary.simpleMessage("Default 24 ore"),
    "share" : MessageLookupByLibrary.simpleMessage("Condividi"),
    "showNotesFonts" : MessageLookupByLibrary.simpleMessage("Font delle note"),
    "size" : MessageLookupByLibrary.simpleMessage("Dimensione"),
    "skipSecondsAtEnd" : MessageLookupByLibrary.simpleMessage("Salta secondi al termine"),
    "skipSecondsAtStart" : MessageLookupByLibrary.simpleMessage("Salta secondi all\'inizio"),
    "skipSilence" : MessageLookupByLibrary.simpleMessage("Salta i silenzi"),
    "skipToNext" : MessageLookupByLibrary.simpleMessage("Salta al prossimo"),
    "sleepTimer" : MessageLookupByLibrary.simpleMessage("Tempo di standby"),
    "status" : MessageLookupByLibrary.simpleMessage("Stato"),
    "statusAuthError" : MessageLookupByLibrary.simpleMessage("Errore di autenticazione"),
    "statusFail" : MessageLookupByLibrary.simpleMessage("Sincronizzazione fallita"),
    "statusSuccess" : MessageLookupByLibrary.simpleMessage("Sincronizzazione avvenuta"),
    "stop" : MessageLookupByLibrary.simpleMessage("Stop"),
    "subscribe" : MessageLookupByLibrary.simpleMessage("Sottoscrivi"),
    "subscribeExportDes" : MessageLookupByLibrary.simpleMessage("Esporta file OPML di tutti i podcast"),
    "syncNow" : MessageLookupByLibrary.simpleMessage("Sincronizza ora"),
    "systemDefault" : MessageLookupByLibrary.simpleMessage("Default di sistema"),
    "timeLastPlayed" : m26,
    "timeLeft" : m27,
    "to" : m28,
    "toastAddPlaylist" : MessageLookupByLibrary.simpleMessage("Aggiunto alla playlist"),
    "toastDiscovery" : MessageLookupByLibrary.simpleMessage("Tutorial abilitato, riapri l\'applicazione per visualizzarlo"),
    "toastFileError" : MessageLookupByLibrary.simpleMessage("Errore del file, sottoscrizione fallita"),
    "toastFileNotValid" : MessageLookupByLibrary.simpleMessage("File non valido"),
    "toastHomeGroupNotSupport" : MessageLookupByLibrary.simpleMessage("Il gruppo Home non è supportato"),
    "toastImportSettingsSuccess" : MessageLookupByLibrary.simpleMessage("Impostazioni importate correttamente"),
    "toastOneGroup" : MessageLookupByLibrary.simpleMessage("Seleziona almeno un gruppo"),
    "toastPodcastRecovering" : MessageLookupByLibrary.simpleMessage("Sto scaricando, attendi un attimo"),
    "toastReadFile" : MessageLookupByLibrary.simpleMessage("File letto con successo"),
    "toastRecoverFailed" : MessageLookupByLibrary.simpleMessage("Fallito lo scaricamento del Podcast"),
    "toastRemovePlaylist" : MessageLookupByLibrary.simpleMessage("Episodio rimosso dalla playlist"),
    "toastSettingSaved" : MessageLookupByLibrary.simpleMessage("Impostazioni salvate"),
    "toastTimeEqualEnd" : MessageLookupByLibrary.simpleMessage("Il tempo è uguale al tempo di fine"),
    "toastTimeEqualStart" : MessageLookupByLibrary.simpleMessage("Il tempo è uguale al tempo d\'inizio"),
    "translators" : MessageLookupByLibrary.simpleMessage("Traduttori"),
    "understood" : MessageLookupByLibrary.simpleMessage("Ho capito"),
    "undo" : MessageLookupByLibrary.simpleMessage("ANNULLA"),
    "unlike" : MessageLookupByLibrary.simpleMessage("Non mi piace"),
    "unliked" : MessageLookupByLibrary.simpleMessage("Episodio rimosso dai Preferiti"),
    "updateDate" : MessageLookupByLibrary.simpleMessage("Data di aggiornamento"),
    "updateEpisodesCount" : m29,
    "updateFailed" : MessageLookupByLibrary.simpleMessage("Aggiornamento fallito, errore di rete"),
    "username" : MessageLookupByLibrary.simpleMessage("Nome utente"),
    "usernameRequired" : MessageLookupByLibrary.simpleMessage("Nome utente obbligatorio"),
    "version" : m30
  };
}
