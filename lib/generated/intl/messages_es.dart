// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${count} episodio de ${groupName} añadido a la lista', other: '${count} episodios en ${groupName} añadidos a la lista')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} episodio añadido a la lista', other: '${count} episodios añadidos a la lista')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Hoy', one: 'Hace ${count} dia', other: 'Hace ${count} dias')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Nunca', one: '${count} dia', other: '${count} dias')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'Episodio', other: 'Episodios')}";

  static String m5(time) => "De ${time}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Grupo', one: 'Grupo', other: 'Grupos')}";

  static String m7(host) => "Alojado en ${host}";

  static String m8(count) =>
      "${Intl.plural(count, zero: 'Justo ahora', one: 'Hace ${count} hora', other: 'Hace ${count} horas')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: 'Cero horas', one: '${count} hora', other: '${count} horas')}";

  static String m10(service) => "Integrar con ${service}";

  static String m11(userName) => "Sesión iniciado como ${userName}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Justo Ahora', one: 'Hace ${count} minuto ', other: 'Hace ${count} minutos')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 minutos', one: '${count} minuto', other: '${count} minutos')}";

  static String m14(title) => "Obtener datos ${title}";

  static String m15(title) => "Suscripción fallida, error de red ${title}";

  static String m16(title) => "Suscribir ${title}";

  static String m17(title) => "Suscripción fallida, podcast ya existe ${title}";

  static String m18(title) => "Suscripción exitosa";

  static String m19(title) => "Actualizar ${title}";

  static String m20(title) => "Error de actualización ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Podcast', other: 'Podcasts')}";

  static String m22(date) => "Publicado el ${date}";

  static String m23(date) => "Removido el (fecha)";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 segundos', one: '${count} segundo', other: '${count} segundos')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Justo ahora', one: 'Hace ${count} segundo ', other: 'Hace ${count} segundos')}";

  static String m26(count) => "${count} selecciones";

  static String m27(time) => "Tiempo previo ${time}";

  static String m28(time) => "${time} Restante";

  static String m29(time) => "A ${time}";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'No hay actualizaciones', one: 'Se actualizo ${count} episodio', other: 'Se actualizaron ${count} episodios')}";

  static String m31(version) => "Versión: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Añadir"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Añade nuevos episodios a la lista de reproducción"),
        "addSomeGroups":
            MessageLookupByLibrary.simpleMessage("Añade algún grupo"),
        "all": MessageLookupByLibrary.simpleMessage("Todos"),
        "autoDownload": MessageLookupByLibrary.simpleMessage("Auto-descargar"),
        "back": MessageLookupByLibrary.simpleMessage("Atras"),
        "boostVolume": MessageLookupByLibrary.simpleMessage("Aumentar volumen"),
        "buffering": MessageLookupByLibrary.simpleMessage("Cargando "),
        "cancel": MessageLookupByLibrary.simpleMessage("CANCELAR"),
        "cellularConfirm":
            MessageLookupByLibrary.simpleMessage("Alerta de datos móviles "),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "¿Seguro que quieres usar datos móviles para realizar descargas?"),
        "changeLayout": MessageLookupByLibrary.simpleMessage("Cambiar diseño"),
        "changelog": MessageLookupByLibrary.simpleMessage("Reporte de cambios"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Escoger un"),
        "clear": MessageLookupByLibrary.simpleMessage("Limpiar"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Limipar todo"),
        "color": MessageLookupByLibrary.simpleMessage("color"),
        "confirm": MessageLookupByLibrary.simpleMessage("ACEPTAR"),
        "createNewPlaylist":
            MessageLookupByLibrary.simpleMessage("Nueva playlist"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(
            "Esta es la cola por defecto, no puede removerse"),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Motor de busqueda de podcasts por defecto"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Escoge el motor de busqueda de podcasts por defecto "),
        "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "developer": MessageLookupByLibrary.simpleMessage("Desarrollador"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Minimizar"),
        "done": MessageLookupByLibrary.simpleMessage("Hecho"),
        "download": MessageLookupByLibrary.simpleMessage("Descargar"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("Descarga removida"),
        "downloadStart": MessageLookupByLibrary.simpleMessage("Descargando"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Descargados"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Editar nombre del grupo"),
        "endOfEpisode":
            MessageLookupByLibrary.simpleMessage("Fin del episodio"),
        "episode": m4,
        "fastForward": MessageLookupByLibrary.simpleMessage("Avanzar"),
        "fastRewind": MessageLookupByLibrary.simpleMessage("Retroceder"),
        "featureDiscoveryEditGroup":
            MessageLookupByLibrary.simpleMessage("Toca para editar grupo"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Puedes cambiar el nombre del grupo o eliminar el grupo aquí, el grupo Home no puede ser editado ni borrado"),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Vista de episodios"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Puedes mantener presionado para reproducir o añadir un episodio a la lista de reproducción "),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Mantén presionado para reproducir episodio instantáneamente"),
        "featureDiscoveryGroup":
            MessageLookupByLibrary.simpleMessage("Toca para añadir grupo"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "El grupo por defecto para nuevos podcasts es Home, puedes crear nuevos grupos y mover podcasts ahí. Puedes poner un podcast en varios grupos"),
        "featureDiscoveryGroupPodcast": MessageLookupByLibrary.simpleMessage(
            "Mantén presionado para re-ordenar podcasts"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Puedes tocar para ver mas opciones, o mantener presionado para ordenar podcasts en grupos"),
        "featureDiscoveryOMPL":
            MessageLookupByLibrary.simpleMessage("Toca para importar un OPML"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Puedes importar archivos OPML, abre los ajustes o refresca todos los podcasts aquí "),
        "featureDiscoveryPlaylist": MessageLookupByLibrary.simpleMessage(
            "Toca para abrir lista de reproducción "),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Puedes añadir episodios a la lista de reproducción. El episodio se removerá automáticamente de la lista una vez reproducido "),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Vista"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Puedes tocar \"Ver Todos\" para añadir grupos u organizar podcasts "),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Desplazate verticalmente para cambiar entre grupos"),
        "featureDiscoverySearch":
            MessageLookupByLibrary.simpleMessage("Toca para buscar podcast"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Puedes buscar podcasts, palabras clave o enlaces RSS para añadir nuevos podcasts"),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("Escríbeme "),
        "feedbackGithub":
            MessageLookupByLibrary.simpleMessage("Reportar problema"),
        "feedbackPlay":
            MessageLookupByLibrary.simpleMessage("Calificar en Play Store"),
        "feedbackTelegram":
            MessageLookupByLibrary.simpleMessage("Unirse a grupo"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
        "fontStyle": MessageLookupByLibrary.simpleMessage("Estilo de fuente"),
        "fonts": MessageLookupByLibrary.simpleMessage("Tipografías"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("Buenas noches"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Felicidades, has unido tu cuenta gpodder.net exitosamente. Tsacdop sincronizara tus subscripciones en tu dispositivo con tu cuenta gpodder.net."),
        "groupExisted":
            MessageLookupByLibrary.simpleMessage("El grupo ya existe"),
        "groupFilter": MessageLookupByLibrary.simpleMessage("Filtro de grupo"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "¿Estas seguro de que quieres remover este grupo? Los podcasts serán movidos al grupo Home"),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Ocultar escuchados"),
        "hidePodcastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Ocultar descubrimiento de podcasts"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Ocultar descubrimiento de pocasts en el motor de busqueda"),
        "homeGroupsSeeAll": MessageLookupByLibrary.simpleMessage("Ver todo"),
        "homeMenuPlaylist":
            MessageLookupByLibrary.simpleMessage("Lista de reproducción"),
        "homeSubMenuSortBy":
            MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "homeTabMenuFavotite":
            MessageLookupByLibrary.simpleMessage("Favoritos"),
        "homeTabMenuRecent": MessageLookupByLibrary.simpleMessage("Recientes"),
        "homeToprightMenuAbout":
            MessageLookupByLibrary.simpleMessage("Acerca de"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("Importar OPML"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Refrescar todo"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("Importar"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Puedes mantener presionado un episodio para realizar acciones rápidas"),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "Suscribete a podcasts buscándolos, o importando un archivo OPML"),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Puedes crear un nuevo grupo de podcasts"),
        "invalidName":
            MessageLookupByLibrary.simpleMessage("Nombre de usuario invalido"),
        "lastUpdate":
            MessageLookupByLibrary.simpleMessage("Ultima actualización"),
        "later": MessageLookupByLibrary.simpleMessage("Despues"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
        "like": MessageLookupByLibrary.simpleMessage("Me gusta"),
        "likeDate":
            MessageLookupByLibrary.simpleMessage("Fecha en que Me Gusto"),
        "liked": MessageLookupByLibrary.simpleMessage("Me gusta"),
        "listen": MessageLookupByLibrary.simpleMessage("Escuchar"),
        "listened": MessageLookupByLibrary.simpleMessage("Escuchado"),
        "loadMore": MessageLookupByLibrary.simpleMessage("Cargar mas"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
        "loginFailed":
            MessageLookupByLibrary.simpleMessage("Inicio de sesión fallido"),
        "logout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
        "mark": MessageLookupByLibrary.simpleMessage("Completado"),
        "markConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmar marcado"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "¿Marcar todos los episodios como escuchados?"),
        "markListened":
            MessageLookupByLibrary.simpleMessage("Marcar escuchados"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Marcar no escuchados"),
        "menu": MessageLookupByLibrary.simpleMessage("Menú"),
        "menuAllPodcasts":
            MessageLookupByLibrary.simpleMessage("Todos los podcasts"),
        "menuMarkAllListened":
            MessageLookupByLibrary.simpleMessage("Marcar todo como escuchado"),
        "menuViewRSS": MessageLookupByLibrary.simpleMessage("Visitar feed RSS"),
        "menuVisitSite":
            MessageLookupByLibrary.simpleMessage("Visitar sitio web"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Red"),
        "neverAutoUpdate": MessageLookupByLibrary.simpleMessage(
            "Desactivar actualizaciones automaticas "),
        "newGroup": MessageLookupByLibrary.simpleMessage("Crear grupo nuevo"),
        "newestFirst":
            MessageLookupByLibrary.simpleMessage("Mas recientes primero"),
        "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
        "noEpisodeDownload": MessageLookupByLibrary.simpleMessage(
            "Aun no hay episodios decargados"),
        "noEpisodeFavorite": MessageLookupByLibrary.simpleMessage(
            "Aun no hay episodios recolectados"),
        "noEpisodeRecent": MessageLookupByLibrary.simpleMessage(
            "Aun no hay episodios recibidos"),
        "noPodcastGroup": MessageLookupByLibrary.simpleMessage(
            "No hay podcasts en este grupo"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Aun no hay notas disponibles para este episodio"),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Panel de notificaciones"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst":
            MessageLookupByLibrary.simpleMessage("Mas antiguos primero"),
        "passwdRequired":
            MessageLookupByLibrary.simpleMessage("Contraseña requerida"),
        "password": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "pause": MessageLookupByLibrary.simpleMessage("Pausa"),
        "play": MessageLookupByLibrary.simpleMessage("Reproducir"),
        "playNext":
            MessageLookupByLibrary.simpleMessage("Reproducir siguiente"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Añadir episodio a la cima de la playlist"),
        "playback":
            MessageLookupByLibrary.simpleMessage("Control de reproducción"),
        "player": MessageLookupByLibrary.simpleMessage("Reproductor"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Medio"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Bajo"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Alto"),
        "playing": MessageLookupByLibrary.simpleMessage("Reproduciendo"),
        "playlistExisted": MessageLookupByLibrary.simpleMessage(
            "El nombre de la playlist ya esta en uso"),
        "playlistNameEmpty":
            MessageLookupByLibrary.simpleMessage("La playlist no tiene nombre"),
        "playlists": MessageLookupByLibrary.simpleMessage("Playlists"),
        "plugins": MessageLookupByLibrary.simpleMessage("Plugins"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Podcast añadido"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Descargar episodio"),
        "popupMenuLaterDes": MessageLookupByLibrary.simpleMessage(
            "Añadir episodio a lista de reproducción"),
        "popupMenuLikeDes":
            MessageLookupByLibrary.simpleMessage("Añadir episodio a favoritos"),
        "popupMenuMarkDes": MessageLookupByLibrary.simpleMessage(
            "Marcar episodio como escuchado"),
        "popupMenuPlayDes":
            MessageLookupByLibrary.simpleMessage("Reproducir episodio\n"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de privacidad"),
        "published": m22,
        "publishedDaily":
            MessageLookupByLibrary.simpleMessage("Publicado diariamente"),
        "publishedMonthly":
            MessageLookupByLibrary.simpleMessage("Publicado mensualmente"),
        "publishedWeekly":
            MessageLookupByLibrary.simpleMessage("Publicado semanalmente"),
        "publishedYearly":
            MessageLookupByLibrary.simpleMessage("Publicado anualmente"),
        "queue": MessageLookupByLibrary.simpleMessage("Cola"),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Recuperar suscripcion"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refrescar"),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Actualizar portada"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Refrescando"),
        "remove": MessageLookupByLibrary.simpleMessage("Remover"),
        "removeConfirm":
            MessageLookupByLibrary.simpleMessage("Confirma la remoción "),
        "removeNewMark": MessageLookupByLibrary.simpleMessage("Remover marca"),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "¿Estas seguro de que deseas desuscribirte?"),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "schedule": MessageLookupByLibrary.simpleMessage("Horario"),
        "search": MessageLookupByLibrary.simpleMessage("Buscar"),
        "searchEpisode":
            MessageLookupByLibrary.simpleMessage("Buscar episodio"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Escribe el nombre del podcast, palabras clave o un feed url"),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Enlace RSS invalido "),
        "searchPodcast": MessageLookupByLibrary.simpleMessage("Buscar podcast"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage":
            MessageLookupByLibrary.simpleMessage("Almacenamiento"),
        "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Color de acento "),
        "settingsAccentColorDes": MessageLookupByLibrary.simpleMessage(
            "Incluir el color del overlay"),
        "settingsAppIntro":
            MessageLookupByLibrary.simpleMessage("Intro de App"),
        "settingsAppearance":
            MessageLookupByLibrary.simpleMessage("Apariencia"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Tema y Colores\n"),
        "settingsAudioCache":
            MessageLookupByLibrary.simpleMessage("Cache de audio"),
        "settingsAudioCacheDes": MessageLookupByLibrary.simpleMessage(
            "Tamaño máximo del cache de audio"),
        "settingsAutoDelete": MessageLookupByLibrary.simpleMessage(
            "Auto-eliminar descargas después"),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("30 días por defecto"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Reproducir automaticamente episodio siguiente "),
        "settingsBackup": MessageLookupByLibrary.simpleMessage("Respaldo"),
        "settingsBackupDes":
            MessageLookupByLibrary.simpleMessage("Respaldar datos de la app"),
        "settingsBoostVolume":
            MessageLookupByLibrary.simpleMessage("Nivel de aumento de volumen"),
        "settingsBoostVolumeDes": MessageLookupByLibrary.simpleMessage(
            "Cambiar nivel de aumento de volumen"),
        "settingsDefaultGrid": MessageLookupByLibrary.simpleMessage(
            "Vista de cuadricula por defecto"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("Pestaña de descargas"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Pestaña de favoritos"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Pagina de podcasts"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("Pestaña de recientes"),
        "settingsDiscovery":
            MessageLookupByLibrary.simpleMessage("Reiniciar tutorial"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("Posicion de descarga"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Activar sincronización"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Actualizar todos los podcasts en el fondo para obtener episodios mas recientes"),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Exportar e importar ajustes de la app"),
        "settingsFastForwardSec":
            MessageLookupByLibrary.simpleMessage("Segundos de avance"),
        "settingsFastForwardSecDes": MessageLookupByLibrary.simpleMessage(
            "Cambia los segundos de avance del reproductor"),
        "settingsFeedback": MessageLookupByLibrary.simpleMessage("Comentarios"),
        "settingsFeedbackDes": MessageLookupByLibrary.simpleMessage(
            "Haz sugerencias y reporta errores"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("Historial"),
        "settingsHistoryDes":
            MessageLookupByLibrary.simpleMessage("Datos de escucha"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Información"),
        "settingsInterface": MessageLookupByLibrary.simpleMessage("Interfaz"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Lenguajes"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Cambiar lenguaje"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Diseño"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Diseño de app"),
        "settingsLibraries": MessageLookupByLibrary.simpleMessage("Librerías"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Librerías de código abierto usadas en la app"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("Administrar descargas"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "Administrar archivos de audio descargados"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Marcar como escuchado al saltar episodio"),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Marcar episodio como escuchado automaticamente al saltar al siguiente"),
        "settingsMenuAutoPlay":
            MessageLookupByLibrary.simpleMessage("Auto reproducir siguiente "),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Preguntar antes de usar datos móviles "),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Auto descargar usando datos móviles"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "Puedes configurar la auto-descarga en la pagina de administración de grupos"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Pregunta para confirmar el uso de datos móviles al descargar episodios"),
        "settingsPlayDes": MessageLookupByLibrary.simpleMessage(
            "Lista de reproducción y Reproductor"),
        "settingsPlayerHeight":
            MessageLookupByLibrary.simpleMessage("Altura del reproductor"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Cambia la altura del reproductor como gustes"),
        "settingsPopupMenu": MessageLookupByLibrary.simpleMessage(
            "Menú emergente de episodios "),
        "settingsPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Cambia el menu emergente del episodio"),
        "settingsPrefrence":
            MessageLookupByLibrary.simpleMessage("Preferencias"),
        "settingsRealDark": MessageLookupByLibrary.simpleMessage("Negro Puro"),
        "settingsRealDarkDes": MessageLookupByLibrary.simpleMessage(
            "Activa si el modo Noche no es suficientemente oscuro"),
        "settingsRewindSec":
            MessageLookupByLibrary.simpleMessage("Segundos de retraso"),
        "settingsRewindSecDes": MessageLookupByLibrary.simpleMessage(
            "Cambia los segundos de retroceso del reproductor"),
        "settingsSTAuto": MessageLookupByLibrary.simpleMessage(
            "Encender temporizador de sueño automáticamente"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Encender temporizador de sueño en un horario determinado"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Tiempo predeterminado"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Tiempo predeterminado de temporizador de sueño"),
        "settingsSTMode": MessageLookupByLibrary.simpleMessage(
            "Modo automático de tempo. de sueño"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Velocidades"),
        "settingsSpeedsDes": MessageLookupByLibrary.simpleMessage(
            "Personalizar velocidades disponibles"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Administrar cache y almacenamiento de descargas"),
        "settingsSyncing":
            MessageLookupByLibrary.simpleMessage("Sincronización"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Actualizar podcasts en el fondo"),
        "settingsTapToOpenPopupMenu":
            MessageLookupByLibrary.simpleMessage("Presiona para abrir el menu"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Necesitas mantener presionado para abrir la pagina del episodio"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Tema"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Intervalo de actualización"),
        "settingsUpdateIntervalDes":
            MessageLookupByLibrary.simpleMessage("24 horas por defecto"),
        "share": MessageLookupByLibrary.simpleMessage("Compartir"),
        "showNotesFonts": MessageLookupByLibrary.simpleMessage(
            "Fuente de las notas del show"),
        "size": MessageLookupByLibrary.simpleMessage("Tamaño"),
        "skipSecondsAtEnd":
            MessageLookupByLibrary.simpleMessage("Saltar segundos al final"),
        "skipSecondsAtStart":
            MessageLookupByLibrary.simpleMessage("Saltar segundos al inicio"),
        "skipSilence": MessageLookupByLibrary.simpleMessage("Saltar silencios"),
        "skipToNext":
            MessageLookupByLibrary.simpleMessage("Saltar a la siguiente"),
        "sleepTimer":
            MessageLookupByLibrary.simpleMessage("Temporizador de sueño"),
        "status": MessageLookupByLibrary.simpleMessage("Estatus"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage(" Error de autenticación"),
        "statusFail": MessageLookupByLibrary.simpleMessage("Fallido"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Exitoso"),
        "stop": MessageLookupByLibrary.simpleMessage("Detener"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Suscribir"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Exportar OPML de todos los podcasts"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Sincronizar ahora"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Acorde al sistema"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist": MessageLookupByLibrary.simpleMessage(
            "Añadido a la lista de reproducción "),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "El tutorial se ha reiniciado, reinicia la app porfavor"),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Error de archivo, suscripción fallida"),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("Archivo invalido"),
        "toastHomeGroupNotSupport": MessageLookupByLibrary.simpleMessage(
            "El grupo Home no esta soportado"),
        "toastImportSettingsSuccess": MessageLookupByLibrary.simpleMessage(
            "Ajustes importados correctamente"),
        "toastOneGroup": MessageLookupByLibrary.simpleMessage(
            "Selecciona al menos un grupo"),
        "toastPodcastRecovering": MessageLookupByLibrary.simpleMessage(
            "Recuperando, espera un momento"),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("Archivo leído con exito"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Recuperación de podcast fallida"),
        "toastRemovePlaylist": MessageLookupByLibrary.simpleMessage(
            "Episodio removido de la lista de reproducción"),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Ajustes guardados"),
        "toastTimeEqualEnd": MessageLookupByLibrary.simpleMessage(
            "El tiempo es igual al tiempo final"),
        "toastTimeEqualStart": MessageLookupByLibrary.simpleMessage(
            "El tiempo es igual al tiempo de inicio"),
        "translators": MessageLookupByLibrary.simpleMessage("Traductores"),
        "understood": MessageLookupByLibrary.simpleMessage("Entendido"),
        "undo": MessageLookupByLibrary.simpleMessage("Deshacer "),
        "unlike": MessageLookupByLibrary.simpleMessage("No me gusta"),
        "unliked": MessageLookupByLibrary.simpleMessage(
            "Episodio removido de favoritos"),
        "updateDate":
            MessageLookupByLibrary.simpleMessage("Fecha de actualización "),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Actualización fallida, error de red"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Nombre de usuario"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Nombre de usuario requerido"),
        "version": m31
      };
}
