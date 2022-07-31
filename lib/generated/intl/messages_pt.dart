// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
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
  String get localeName => 'pt';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${count} episódio de ${groupName} adicionado à lista', other: '${count} episódios de ${groupName} adicionados à lista')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} episódio adicionado à lista', other: '${count} episódios adicionados à lista')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Hoje', one: 'Há ${count} dia', other: 'Há ${count} dias')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Nunca', one: '${count} dia', other: '${count} dias')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'Episódio', other: 'Episódios')}";

  static String m5(time) => "De ${time}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Grupo', one: 'Grupo', other: 'Grupos')}";

  static String m7(host) => "Hospedado em ${host}";

  static String m8(count) =>
      "${Intl.plural(count, zero: '', one: 'há ${count} hora', other: 'há ${count} horas')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: '0 horas', one: '${count} hora', other: '${count} horas')}";

  static String m10(service) => "Integrate with ${service}";

  static String m11(userName) => "Logged in as ${userName}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Agora', one: 'Há ${count} minuto', other: 'Há ${count} minutos')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 minutos', one: '${count} minuto', other: '${count} minutos')}";

  static String m14(title) => "Obter dados ${title}";

  static String m15(title) => "A subscrição falhou, erro de rede ${title}";

  static String m16(title) => "Subscrever ${title}";

  static String m17(title) => "Subscrição falhou, podcast já existe ${title}";

  static String m18(title) => "Subscrito com sucesso ${title}";

  static String m19(title) => "Atualizar ${title}";

  static String m20(title) => "Erro de atualização ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcasts')}";

  static String m22(date) => "Publicado em ${date}";

  static String m23(date) => "Removido em ${date}";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 segundos', one: '${count} segundo', other: '${count} segundos')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Agora', one: 'Há ${count} segundo', other: 'Há ${count} segundos')}";

  static String m26(count) => "";

  static String m27(time) => "Última vez ${time}";

  static String m28(time) => "${time} Restante";

  static String m29(time) => "Para ${time}";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'Sem atualizações', one: '${count} episódio atualizado', other: '${count} episódios atualizados')}";

  static String m31(version) => "Versão: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Adicionar"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Adiciona novos episódios à lista de reprodução"),
        "addSomeGroups":
            MessageLookupByLibrary.simpleMessage("Adiciona alguns grupos"),
        "all": MessageLookupByLibrary.simpleMessage("Todos"),
        "autoDownload":
            MessageLookupByLibrary.simpleMessage("Download automático"),
        "back": MessageLookupByLibrary.simpleMessage("Atrás"),
        "boostVolume": MessageLookupByLibrary.simpleMessage("Aumentar volume"),
        "buffering": MessageLookupByLibrary.simpleMessage("A carregar"),
        "cancel": MessageLookupByLibrary.simpleMessage("CANCELAR"),
        "cellularConfirm":
            MessageLookupByLibrary.simpleMessage("Alerta de dados móveis"),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "Tens a certeza que queres usar dados móveis para downloads?"),
        "changeLayout": MessageLookupByLibrary.simpleMessage("Mudar aparência"),
        "changelog":
            MessageLookupByLibrary.simpleMessage("Registo de mudanças"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Escolher um"),
        "clear": MessageLookupByLibrary.simpleMessage("Limpar"),
        "clearAll": MessageLookupByLibrary.simpleMessage(""),
        "color": MessageLookupByLibrary.simpleMessage("Cor"),
        "confirm": MessageLookupByLibrary.simpleMessage("CONFIRMAR"),
        "createNewPlaylist": MessageLookupByLibrary.simpleMessage(""),
        "darkMode": MessageLookupByLibrary.simpleMessage("Modo escuro"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(""),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Default podcast search engine"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Choose the default podcast search engine"),
        "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "developer": MessageLookupByLibrary.simpleMessage("Desenvolvedor"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Minimizar"),
        "done": MessageLookupByLibrary.simpleMessage("Feito"),
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("Download removido"),
        "downloadStart": MessageLookupByLibrary.simpleMessage("Downloading"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Descarregado"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Editar nome do grupo"),
        "endOfEpisode": MessageLookupByLibrary.simpleMessage("Fim do episódio"),
        "episode": m4,
        "fastForward": MessageLookupByLibrary.simpleMessage("Avanço"),
        "fastRewind": MessageLookupByLibrary.simpleMessage("Recuo rápido"),
        "featureDiscoveryEditGroup":
            MessageLookupByLibrary.simpleMessage("Prime para editar grupo"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Podes alterar o nome do grupo ou apagá-lo aqui, mas o grupo Home não pode ser editado ou eliminado"),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Vista de episódios"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Podes manter premido para reproduzir um episódio ou adicioná-lo a uma lista de reprodução."),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Mantém premido para reproduzir um episódio instantâneamente"),
        "featureDiscoveryGroup":
            MessageLookupByLibrary.simpleMessage("Prime para adicionar grupo"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "O grupo por defeito para novos podcasts é Home. Podes criar novos grupos e mover os podcasts para estes, assim como adicionar podcasts a múltiplos grupos."),
        "featureDiscoveryGroupPodcast": MessageLookupByLibrary.simpleMessage(
            "Mantém premido para reordenar podcasts"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Podes premir para ver mais opções, ou manter premido para reordenar podcasts em grupos."),
        "featureDiscoveryOMPL": MessageLookupByLibrary.simpleMessage(
            "Premir para importar um OPML"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Podes importar ficheiros OPML, abrir as definições ou atualizar todos os podcasts aqui."),
        "featureDiscoveryPlaylist": MessageLookupByLibrary.simpleMessage(
            "Prime para abrir a lista de reprodução"),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Podes adicionar episódios à lista de reprodução manualmente. Os episódios serão automaticamente removidos das listas de reprodução quando reproduzidos."),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Vista do podcast"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Podes premir \"Ver Todos\" para adicionar grupos ou organizar pdcasts."),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Deslizar verticalmente para alterar grupos"),
        "featureDiscoverySearch": MessageLookupByLibrary.simpleMessage(
            "Prime para procurar podcasts"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Podes procurar pelo título do podcast, palavra-chave ou ligação RSS para subscrever novos podcasts."),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("Escreve-me"),
        "feedbackGithub":
            MessageLookupByLibrary.simpleMessage("Submeter problema"),
        "feedbackPlay":
            MessageLookupByLibrary.simpleMessage("Avaliar na Play Store"),
        "feedbackTelegram":
            MessageLookupByLibrary.simpleMessage("Juntar um grupo"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtro"),
        "fontStyle":
            MessageLookupByLibrary.simpleMessage("Estilo do tipo de letra"),
        "fonts": MessageLookupByLibrary.simpleMessage("Fontes"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("Boa Noite"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Congratulations! You  have linked gpodder.net account successfully. Tsacdop will automatically sync subscriptions on your device with your gpodder.net account."),
        "groupExisted": MessageLookupByLibrary.simpleMessage("Grupo já existe"),
        "groupFilter": MessageLookupByLibrary.simpleMessage("Filtro de grupo"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "Tens a certeza que queres eliminar este grupo? Os podcasts serão removidos para o grupo \"Home\"."),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Esconder ouvidos"),
        "hidePodcastDiscovery":
            MessageLookupByLibrary.simpleMessage("Hide podcast discovery"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Hide podcast discovery in search page"),
        "homeGroupsSeeAll": MessageLookupByLibrary.simpleMessage("Ver Todos"),
        "homeMenuPlaylist":
            MessageLookupByLibrary.simpleMessage("Lista de Reprodução"),
        "homeSubMenuSortBy":
            MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "homeTabMenuFavotite": MessageLookupByLibrary.simpleMessage("Favorito"),
        "homeTabMenuRecent": MessageLookupByLibrary.simpleMessage("Recentes"),
        "homeToprightMenuAbout": MessageLookupByLibrary.simpleMessage("Sobre"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("Importar OPML"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Atualizar todos"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("Importar"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Podes manter premido um episódio para uma ação rápida."),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "Subscreve podcasts por pesquisa ou importa um ficheiro OPML."),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Podes criar um novo grupo para podcasts."),
        "invalidName": MessageLookupByLibrary.simpleMessage("Invalid username"),
        "lastUpdate": MessageLookupByLibrary.simpleMessage("Last update"),
        "later": MessageLookupByLibrary.simpleMessage("Mais tarde"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
        "like": MessageLookupByLibrary.simpleMessage("Gosto"),
        "likeDate": MessageLookupByLibrary.simpleMessage("Data do Gosto"),
        "liked": MessageLookupByLibrary.simpleMessage("Gostou"),
        "listen": MessageLookupByLibrary.simpleMessage("Ouvir"),
        "listened": MessageLookupByLibrary.simpleMessage("Ouvido"),
        "loadMore": MessageLookupByLibrary.simpleMessage("Carregar mais"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "mark": MessageLookupByLibrary.simpleMessage("Marcar"),
        "markConfirm": MessageLookupByLibrary.simpleMessage("Confirmar marca"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Marcar todos os episódios como ouvidos?"),
        "markListened":
            MessageLookupByLibrary.simpleMessage("Marcar como ouvido"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Marcar não ouvidos"),
        "menu": MessageLookupByLibrary.simpleMessage("Menu"),
        "menuAllPodcasts":
            MessageLookupByLibrary.simpleMessage("Todos os podcasts"),
        "menuMarkAllListened":
            MessageLookupByLibrary.simpleMessage("Marcar todos como ouvidos"),
        "menuViewRSS": MessageLookupByLibrary.simpleMessage("Visitar Feed RSS"),
        "menuVisitSite":
            MessageLookupByLibrary.simpleMessage("Visitar website"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Rede"),
        "neverAutoUpdate":
            MessageLookupByLibrary.simpleMessage("Turn off auto update"),
        "newGroup": MessageLookupByLibrary.simpleMessage("Criar um novo grupo"),
        "newestFirst":
            MessageLookupByLibrary.simpleMessage("Mais recentes primeiro"),
        "next": MessageLookupByLibrary.simpleMessage("Seguinte"),
        "noEpisodeDownload": MessageLookupByLibrary.simpleMessage(
            "Ainda não há episódios descarregados"),
        "noEpisodeFavorite": MessageLookupByLibrary.simpleMessage(
            "Ainda não há episódios coletados"),
        "noEpisodeRecent": MessageLookupByLibrary.simpleMessage(
            "Ainda não há episódios recebidos"),
        "noPodcastGroup":
            MessageLookupByLibrary.simpleMessage("Não há podcasts neste grupo"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Não há notas disponíveis para este episódio"),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Painel de notificações"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst":
            MessageLookupByLibrary.simpleMessage("Mais antigos primeiro"),
        "passwdRequired":
            MessageLookupByLibrary.simpleMessage("Password required"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pause": MessageLookupByLibrary.simpleMessage("Pausa"),
        "play": MessageLookupByLibrary.simpleMessage("Reproduzir"),
        "playNext": MessageLookupByLibrary.simpleMessage("Play next"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Add episode to top of the playlist"),
        "playback":
            MessageLookupByLibrary.simpleMessage("Controlo da reprodução"),
        "player": MessageLookupByLibrary.simpleMessage("Reprodutor"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Médio"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Baixo"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Alto"),
        "playing": MessageLookupByLibrary.simpleMessage("Em reprodução"),
        "playlistExisted": MessageLookupByLibrary.simpleMessage(""),
        "playlistNameEmpty": MessageLookupByLibrary.simpleMessage(""),
        "playlists": MessageLookupByLibrary.simpleMessage(""),
        "plugins": MessageLookupByLibrary.simpleMessage("Plugins"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Podcast subscrito"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Descarregar episódio"),
        "popupMenuLaterDes": MessageLookupByLibrary.simpleMessage(
            "Adicionar episódio à lista de reprodução"),
        "popupMenuLikeDes": MessageLookupByLibrary.simpleMessage(
            "Adicionar episódio aos favoritos"),
        "popupMenuMarkDes":
            MessageLookupByLibrary.simpleMessage("Marcar episódio como ouvido"),
        "popupMenuPlayDes":
            MessageLookupByLibrary.simpleMessage("Reproduzir episódio"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de Privacidade"),
        "published": m22,
        "publishedDaily":
            MessageLookupByLibrary.simpleMessage("Publicado diariamente"),
        "publishedMonthly":
            MessageLookupByLibrary.simpleMessage("Publicado mensalmente"),
        "publishedWeekly":
            MessageLookupByLibrary.simpleMessage("Publicado semanalmente"),
        "publishedYearly":
            MessageLookupByLibrary.simpleMessage("Publicado anualmente"),
        "queue": MessageLookupByLibrary.simpleMessage(""),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Recuperar subscrição"),
        "refresh": MessageLookupByLibrary.simpleMessage(""),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Atualizar capa"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Refreshing"),
        "remove": MessageLookupByLibrary.simpleMessage("Remover"),
        "removeConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmação de remoção"),
        "removeNewMark": MessageLookupByLibrary.simpleMessage(""),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "Tens a certeza que pretendes cancelar a subscrição?"),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "schedule": MessageLookupByLibrary.simpleMessage("Horário"),
        "search": MessageLookupByLibrary.simpleMessage("Procurar"),
        "searchEpisode":
            MessageLookupByLibrary.simpleMessage("Procurar episódio"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Type the podcast name, keywords or enter a feed url."),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Ligação RSS inválida"),
        "searchPodcast":
            MessageLookupByLibrary.simpleMessage("Procurar podcasts"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage": MessageLookupByLibrary.simpleMessage("Armazenamento"),
        "settings": MessageLookupByLibrary.simpleMessage("Definições"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Cor de realce"),
        "settingsAccentColorDes":
            MessageLookupByLibrary.simpleMessage("Incluir cor de sobreposição"),
        "settingsAppIntro":
            MessageLookupByLibrary.simpleMessage("Introdução da Aplicação"),
        "settingsAppearance": MessageLookupByLibrary.simpleMessage("Aparência"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Cores e temas"),
        "settingsAudioCache":
            MessageLookupByLibrary.simpleMessage("Cache de áudio"),
        "settingsAudioCacheDes": MessageLookupByLibrary.simpleMessage(
            "Tamanho máximo da cache de áudio"),
        "settingsAutoDelete": MessageLookupByLibrary.simpleMessage(
            "Eliminar downloads automaticamente após"),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("30 dias por defeito"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Reproduzir automaticamente o episódio seguinte"),
        "settingsBackup":
            MessageLookupByLibrary.simpleMessage("Cópia de segurança"),
        "settingsBackupDes": MessageLookupByLibrary.simpleMessage(
            "Cópia de segurança dos dados da aplicação"),
        "settingsBoostVolume":
            MessageLookupByLibrary.simpleMessage("Nível de aumento de volume"),
        "settingsBoostVolumeDes": MessageLookupByLibrary.simpleMessage(
            "Alterar nível de aumento de volume"),
        "settingsDefaultGrid":
            MessageLookupByLibrary.simpleMessage("Vista de grelha predefinida"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("Aba de downloads"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Aba de favoritos"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Página de podcasts"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("Aba de recentes"),
        "settingsDiscovery":
            MessageLookupByLibrary.simpleMessage("Reiniciar tutorial"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("Download position"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Ativar sincronização"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Atualizar todos os podcasts em segundo plano para obter os episódios mais recentes"),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Exportar e importar definições da aplicação"),
        "settingsFastForwardSec":
            MessageLookupByLibrary.simpleMessage("Avançar segundos"),
        "settingsFastForwardSecDes": MessageLookupByLibrary.simpleMessage(
            "Muda os segundos de avanço no reprodutor"),
        "settingsFeedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsFeedbackDes":
            MessageLookupByLibrary.simpleMessage("Erros e sugestões"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("Histórico"),
        "settingsHistoryDes":
            MessageLookupByLibrary.simpleMessage("Dados de audição"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Informações"),
        "settingsInterface": MessageLookupByLibrary.simpleMessage("Interface"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Idiomas"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Mudar idioma"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Esquema"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Esquema da aplicação"),
        "settingsLibraries":
            MessageLookupByLibrary.simpleMessage("Bibliotecas"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Bibliotecas de código aberto usados nesta aplicação"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("Gerir downloads"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "Gerir arquivos de aúdio descarregados"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Mark as listened when skipped"),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Auto mark episode as listened when it was skipped to next"),
        "settingsMenuAutoPlay": MessageLookupByLibrary.simpleMessage(
            "Reproduzir seguinte automaticamente"),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Perguntar antes de usar dados móveis"),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Descarregar automaticamente usando os dados móveis"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "Podes configurar o descarregamento automático na página de gestão de grupos"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Perguntar a confirmar o uso de dados móveis ao descarregar episódios"),
        "settingsPlayDes": MessageLookupByLibrary.simpleMessage(
            "Lista de reprodução e reprodutor"),
        "settingsPlayerHeight":
            MessageLookupByLibrary.simpleMessage("Altura do reprodutor"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Mudar a altura do reprodutor a teu gosto"),
        "settingsPopupMenu":
            MessageLookupByLibrary.simpleMessage("Menu pop-up de episódios"),
        "settingsPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Muda o menu pop-up de episódios"),
        "settingsPrefrence":
            MessageLookupByLibrary.simpleMessage("Preferências"),
        "settingsRealDark":
            MessageLookupByLibrary.simpleMessage("Escuro AMOLED"),
        "settingsRealDarkDes": MessageLookupByLibrary.simpleMessage(
            "Ativa caso o modo escuro não seja suficientemente escuro"),
        "settingsRewindSec":
            MessageLookupByLibrary.simpleMessage("Segundos de recuo"),
        "settingsRewindSecDes": MessageLookupByLibrary.simpleMessage(
            "Muda os segundos de recuo no reprodutor"),
        "settingsSTAuto": MessageLookupByLibrary.simpleMessage(
            "Ligar temporizador automaticamente"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Ligar temporizador automaticamente num horário definido"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Tempo predefinido"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Tempo predefinido para temporizador"),
        "settingsSTMode": MessageLookupByLibrary.simpleMessage(
            "Modo de temporizador automático"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Velocidades"),
        "settingsSpeedsDes": MessageLookupByLibrary.simpleMessage(
            "Customizar as velocidades disponíveis"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Gerir cache e armazenamento de downloads"),
        "settingsSyncing":
            MessageLookupByLibrary.simpleMessage("Sincronização"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Atualizar podcasts em segundo plano"),
        "settingsTapToOpenPopupMenu": MessageLookupByLibrary.simpleMessage(
            "Prime para abrir o menu pop-up"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Precisas manter premido para abrir a página do episódio"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Tema"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Intervalo de atualização"),
        "settingsUpdateIntervalDes":
            MessageLookupByLibrary.simpleMessage("24 horas predefinidas"),
        "share": MessageLookupByLibrary.simpleMessage("Partilhar"),
        "showNotesFonts": MessageLookupByLibrary.simpleMessage(
            "Mostrar tipo de letra das notas"),
        "size": MessageLookupByLibrary.simpleMessage("Tamanho"),
        "skipSecondsAtEnd":
            MessageLookupByLibrary.simpleMessage("Saltar segundos no fim"),
        "skipSecondsAtStart":
            MessageLookupByLibrary.simpleMessage("Saltar segundos no início"),
        "skipSilence": MessageLookupByLibrary.simpleMessage("Saltar silêncio"),
        "skipToNext":
            MessageLookupByLibrary.simpleMessage("Saltar para o próximo"),
        "sleepTimer": MessageLookupByLibrary.simpleMessage("Temporizador"),
        "status": MessageLookupByLibrary.simpleMessage("Status"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage("Authentication error"),
        "statusFail": MessageLookupByLibrary.simpleMessage("Failed"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Successful"),
        "stop": MessageLookupByLibrary.simpleMessage("Parar"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Subscrever"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Exportar ficheiro OPML de todos os podcasts"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Sync now"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Predefinido do sistema"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist": MessageLookupByLibrary.simpleMessage(
            "Adicionado à lista de reprodução"),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Característica \"Descobrir\" ligada, por favor reinicia a aplicação"),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Erro no ficheiro, subscrição falhou"),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("Ficheiro inválido"),
        "toastHomeGroupNotSupport":
            MessageLookupByLibrary.simpleMessage("Grupo Home não é suportado"),
        "toastImportSettingsSuccess": MessageLookupByLibrary.simpleMessage(
            "Definições importadas com sucesso"),
        "toastOneGroup": MessageLookupByLibrary.simpleMessage(
            "Seleciona pelo menos um grupo"),
        "toastPodcastRecovering": MessageLookupByLibrary.simpleMessage(
            "A recuperar, espera um momento"),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("Ficheiro lido com sucesso"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Recuperação do podcast falhou"),
        "toastRemovePlaylist": MessageLookupByLibrary.simpleMessage(
            "Episódio removido da lista de reprodução"),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Definições guardadas"),
        "toastTimeEqualEnd": MessageLookupByLibrary.simpleMessage(
            "Tempo marcado é igual ao tempo de fim"),
        "toastTimeEqualStart": MessageLookupByLibrary.simpleMessage(
            "Tempo marcado é igual ao tempo de início"),
        "translators": MessageLookupByLibrary.simpleMessage("Tradutores"),
        "understood": MessageLookupByLibrary.simpleMessage("Compreendido"),
        "undo": MessageLookupByLibrary.simpleMessage("DESFAZER"),
        "unlike": MessageLookupByLibrary.simpleMessage("Não gosto"),
        "unliked": MessageLookupByLibrary.simpleMessage(
            "Episódio removido dos favoritos"),
        "updateDate": MessageLookupByLibrary.simpleMessage("Atualizar data"),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Atuallização falhou, erro de conexão"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Username requeired"),
        "version": m31
      };
}
