// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${count} выпуск в ${groupName} добавлен в плейлист', few: '${count} выпуска в ${groupName} добавлены в плейлист', many: '${count} выпусков в ${groupName} добавлены в плейлист', other: '${count} выпусков в ${groupName} добавлены в плейлист')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} выпуск добавлен в плейлист', few: '${count} выпуска добавлены в плейлист', many: '${count} выпусков добавлены в плейлист', other: '${count} выпусков добавлены в плейлист')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Сегодня', one: 'День назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дней назад')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Никогда', one: 'День', few: '${count} дня', many: '${count} дней', other: '${count} дней')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'выпуск', few: 'выпуска', many: 'выпусков', other: 'выпусков')}";

  static String m5(time) => "С ${time}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Группа', one: 'Группа', few: 'Группы', many: 'Групп', other: 'Групп')}";

  static String m7(host) => "Размещено на ${host}";

  static String m8(count) =>
      "${Intl.plural(count, zero: 'В течение часа', one: 'Час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часов назад')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: '0 час.', one: '${count} час.', few: '${count} час.', many: '${count} час.', other: '${count} час.')}";

  static String m10(service) => "Интегрировать с  ${service}";

  static String m11(userName) => "Авторизован как ${userName}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Только что', one: 'Минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минут назад')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 мин.', one: '${count} мин.', few: '${count} мин.', many: '${count} мин.', other: '${count} мин.')}";

  static String m14(title) => "Получить данные ${title}";

  static String m15(title) => "Подписка не удалась, ошибка сети ${title}";

  static String m16(title) => "Подписаться на ${title}";

  static String m17(title) =>
      "Подписка не удалась, подкаст уже существует ${title}";

  static String m18(title) => "Успешная подписка на ${title}";

  static String m19(title) => "Обновить ${title}";

  static String m20(title) => "Ошибка обновления ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Подкаст', few: 'Подкаста', many: 'Подкастов', other: 'Подкастов')}";

  static String m22(date) => "Опубликовано ${date}";

  static String m23(date) => "Удалено ${date}";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 сек', one: '${count} сек', few: '${count} сек', many: '${count} сек', other: '${count} сек')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Только что', one: 'Секунду назад', few: '${count} секунды назад', many: '${count} секунд назад', other: '${count} секунд назад')}";

  static String m26(count) => "выбрано ${count}";

  static String m27(time) => "Время остановки ${time}";

  static String m28(time) => "Осталось ${time}";

  static String m29(time) => "До ${time}";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'Нет обновлений', one: 'Обновлен ${count} выпуск', few: 'Обновлено ${count} выпуска', many: 'Обновлены ${count} выпусков', other: 'Обновлены ${count} выпусков')}";

  static String m31(version) => "Версия: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Добавить"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Добавить новые выпуски в плейлист"),
        "addSomeGroups":
            MessageLookupByLibrary.simpleMessage("Добавить несколько групп"),
        "all": MessageLookupByLibrary.simpleMessage("Все"),
        "autoDownload": MessageLookupByLibrary.simpleMessage("Автозагрузка"),
        "back": MessageLookupByLibrary.simpleMessage("Назад"),
        "boostVolume":
            MessageLookupByLibrary.simpleMessage("Усиление громкости"),
        "buffering": MessageLookupByLibrary.simpleMessage("Буферизация"),
        "cancel": MessageLookupByLibrary.simpleMessage("ОТМЕНА"),
        "cellularConfirm": MessageLookupByLibrary.simpleMessage(
            "Предупреждение о мобильной сети"),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите использовать мобильную сеть для загрузки?"),
        "changeLayout":
            MessageLookupByLibrary.simpleMessage("Изменить интерфейс"),
        "changelog": MessageLookupByLibrary.simpleMessage("История изменений"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Выберите"),
        "clear": MessageLookupByLibrary.simpleMessage("Очистить"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Очистить все"),
        "color": MessageLookupByLibrary.simpleMessage("цвет"),
        "confirm": MessageLookupByLibrary.simpleMessage("ПОДТВЕРДИТЬ"),
        "createNewPlaylist":
            MessageLookupByLibrary.simpleMessage("Новый плейлист"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Темная"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(
            "Это очередь по умолчанию. Ее удалить нельзя."),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Поисковая система подкастов по умолчанию"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Выберите поисковую систему подкастов по умолчанию"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "developer": MessageLookupByLibrary.simpleMessage("Разработчик"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Отклонить"),
        "done": MessageLookupByLibrary.simpleMessage("Готово"),
        "download": MessageLookupByLibrary.simpleMessage("Загружено"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("Загрузка удалена"),
        "downloadStart": MessageLookupByLibrary.simpleMessage("Загрузка"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Загружено"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Изменить название группы"),
        "endOfEpisode": MessageLookupByLibrary.simpleMessage("Конец выпуска"),
        "episode": m4,
        "fastForward": MessageLookupByLibrary.simpleMessage("Перемотка вперед"),
        "fastRewind": MessageLookupByLibrary.simpleMessage("Быстрая перемотка"),
        "featureDiscoveryEditGroup": MessageLookupByLibrary.simpleMessage(
            "Нажмите, чтобы изменить группу"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Здесь можно изменить название группы или удалить ее. Домашнюю группу нельзя удалить или отредактировать."),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Просмотр выпуска"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Удерживайте для воспроизведения выпуска или добавления его в плейлист"),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Удерживайте для немедленного воспроизведения выпуска"),
        "featureDiscoveryGroup": MessageLookupByLibrary.simpleMessage(
            "Нажмите для добавления группы"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "Домашняя группа - это группа по умолчанию для новых подкастов. Вы можете создавать новые группы и перемещать в них подкасты, а также добавлять подкасты в несколько групп."),
        "featureDiscoveryGroupPodcast": MessageLookupByLibrary.simpleMessage(
            "Нажмите и удерживайте, чтобы изменить порядок подкастов"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Нажмите, чтобы получить доступ к дополнительным параметрам, длительное нажатие позволит изменить порядок подкастов в группе."),
        "featureDiscoveryOMPL":
            MessageLookupByLibrary.simpleMessage("Нажмите для импорта OPML"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Вы можете импортировать файл OPML, перейти в настройки или обновить все подкасты."),
        "featureDiscoveryPlaylist": MessageLookupByLibrary.simpleMessage(
            "Нажмите для открытия плейлиста."),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Добавьте выпуски в плейлист. Они будут автоматически удалены после прослушивания."),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Просмотр подкаста"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Чтобы добавить группы или управлять подкастами, можно нажать \'Посмотреть все\'."),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Прокрутите по вертикали, чтобы переключить группы"),
        "featureDiscoverySearch": MessageLookupByLibrary.simpleMessage(
            "Нажмите для поиска подкастов"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Вы можете искать по названию подкаста, ключевому слову или RSS-ссылке, чтобы подписаться на новые подкасты."),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("Написать мне"),
        "feedbackGithub": MessageLookupByLibrary.simpleMessage("GitHub"),
        "feedbackPlay":
            MessageLookupByLibrary.simpleMessage("Оценить в Play Store"),
        "feedbackTelegram": MessageLookupByLibrary.simpleMessage("Telegram"),
        "filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
        "fontStyle": MessageLookupByLibrary.simpleMessage("Стиль шрифта"),
        "fonts": MessageLookupByLibrary.simpleMessage("Шрифты"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("Спокойной ночи"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Поздравляем! Вы успешно связали учетную запись gpodder.net. Tsacdop будет автоматически синхронизировать подписки на вашем устройстве с вашей учетной записью gpodder.net."),
        "groupExisted": MessageLookupByLibrary.simpleMessage(
            "Нажмите, чтобы добавить группу"),
        "groupFilter": MessageLookupByLibrary.simpleMessage("Фильтр по группе"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить эту группу? Подкасты будут перемещены в домашнюю группу."),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Скрыть прослушанное"),
        "hidePodcastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Скрыть обнаружение подкастов"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Скрыть обнаружение подкастов на странице поиска"),
        "homeGroupsSeeAll":
            MessageLookupByLibrary.simpleMessage("Посмотреть все"),
        "homeMenuPlaylist": MessageLookupByLibrary.simpleMessage("Плейлист"),
        "homeSubMenuSortBy": MessageLookupByLibrary.simpleMessage("Сортировка"),
        "homeTabMenuFavotite":
            MessageLookupByLibrary.simpleMessage("Избранное"),
        "homeTabMenuRecent": MessageLookupByLibrary.simpleMessage("Недавние"),
        "homeToprightMenuAbout":
            MessageLookupByLibrary.simpleMessage("О приложении"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("Импорт OPML"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Обновить все"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("Импорт"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Длительное нажатие на выпуск запускает быстрые действия."),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "Подписка на подкаст через поиск или импорт файла OPML."),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Вы можете создать новую группу для подкастов."),
        "invalidName":
            MessageLookupByLibrary.simpleMessage("Неверное имя пользователя"),
        "lastUpdate":
            MessageLookupByLibrary.simpleMessage("Последнее обновление"),
        "later": MessageLookupByLibrary.simpleMessage("Позже"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Светлая"),
        "like": MessageLookupByLibrary.simpleMessage("Нравится"),
        "likeDate": MessageLookupByLibrary.simpleMessage("Дата добавления"),
        "liked": MessageLookupByLibrary.simpleMessage("Нравится"),
        "listen": MessageLookupByLibrary.simpleMessage("Слушать"),
        "listened": MessageLookupByLibrary.simpleMessage("Прослушано"),
        "loadMore": MessageLookupByLibrary.simpleMessage("Загрузить еще"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Войти"),
        "loginFailed":
            MessageLookupByLibrary.simpleMessage("Не удалось авторизоваться"),
        "logout": MessageLookupByLibrary.simpleMessage("Выйти"),
        "mark": MessageLookupByLibrary.simpleMessage("Пометить"),
        "markConfirm":
            MessageLookupByLibrary.simpleMessage("Подтвердить отметку"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Подтвердить отметку всех выпусков как прослушанных?"),
        "markListened":
            MessageLookupByLibrary.simpleMessage("Отметить как прослушанное"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Отметить непрослушанным"),
        "menu": MessageLookupByLibrary.simpleMessage("Меню"),
        "menuAllPodcasts": MessageLookupByLibrary.simpleMessage("Все подкасты"),
        "menuMarkAllListened": MessageLookupByLibrary.simpleMessage(
            "Отметить все как прослушанные"),
        "menuViewRSS":
            MessageLookupByLibrary.simpleMessage("Доступ к RSS-каналу"),
        "menuVisitSite": MessageLookupByLibrary.simpleMessage("Посетить сайт"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Сеть"),
        "neverAutoUpdate": MessageLookupByLibrary.simpleMessage(
            "Выключить автоматическое обновление"),
        "newGroup":
            MessageLookupByLibrary.simpleMessage("Создать новую группу"),
        "newestFirst": MessageLookupByLibrary.simpleMessage("Начиная с новых"),
        "next": MessageLookupByLibrary.simpleMessage("Следующий"),
        "noEpisodeDownload":
            MessageLookupByLibrary.simpleMessage("Выпуски пока не загружены"),
        "noEpisodeFavorite":
            MessageLookupByLibrary.simpleMessage("Выпуски пока не добавлены"),
        "noEpisodeRecent":
            MessageLookupByLibrary.simpleMessage("Нет недавних выпусков"),
        "noPodcastGroup":
            MessageLookupByLibrary.simpleMessage("В этой группе нет подкастов"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Для этого выпуска нет примечаний."),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Панель уведомлений"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst":
            MessageLookupByLibrary.simpleMessage("Начиная со старых"),
        "passwdRequired":
            MessageLookupByLibrary.simpleMessage("Требуется пароль"),
        "password": MessageLookupByLibrary.simpleMessage("Пароль"),
        "pause": MessageLookupByLibrary.simpleMessage("Пауза"),
        "play": MessageLookupByLibrary.simpleMessage("Воспроизвести"),
        "playNext":
            MessageLookupByLibrary.simpleMessage("Воспроизвести следующий"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Добавить выпуск в начало плейлиста"),
        "playback":
            MessageLookupByLibrary.simpleMessage("Управление воспроизведением"),
        "player": MessageLookupByLibrary.simpleMessage("Плейер"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Средний"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Низкий"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Высокий"),
        "playing": MessageLookupByLibrary.simpleMessage("Проигрывается"),
        "playlistExisted": MessageLookupByLibrary.simpleMessage(
            "Название плейлиста существует"),
        "playlistNameEmpty":
            MessageLookupByLibrary.simpleMessage("Название плейлиста пустое"),
        "playlists": MessageLookupByLibrary.simpleMessage("Плейлисты"),
        "plugins": MessageLookupByLibrary.simpleMessage("Плагины"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Подписка оформлена"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Скачать выпуск"),
        "popupMenuLaterDes":
            MessageLookupByLibrary.simpleMessage("Добавить выпуск в плейлист"),
        "popupMenuLikeDes":
            MessageLookupByLibrary.simpleMessage("Добавить выпуск в избранное"),
        "popupMenuMarkDes": MessageLookupByLibrary.simpleMessage(
            "Отметить выпуск как прослушанный"),
        "popupMenuPlayDes":
            MessageLookupByLibrary.simpleMessage("Воспроизвести выпуск"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Политика конфиденциальности"),
        "published": m22,
        "publishedDaily":
            MessageLookupByLibrary.simpleMessage("Публикуется ежедневно"),
        "publishedMonthly":
            MessageLookupByLibrary.simpleMessage("Публикуется ежемесячно"),
        "publishedWeekly":
            MessageLookupByLibrary.simpleMessage("Публикуется еженедельно"),
        "publishedYearly":
            MessageLookupByLibrary.simpleMessage("Публикуется ежегодно"),
        "queue": MessageLookupByLibrary.simpleMessage("Очередь"),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Восстановить подписку"),
        "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Обновить обложку"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Обновление"),
        "remove": MessageLookupByLibrary.simpleMessage("Удалить"),
        "removeConfirm":
            MessageLookupByLibrary.simpleMessage("Подтверждение удаления"),
        "removeNewMark":
            MessageLookupByLibrary.simpleMessage("Удалить новую пометку"),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите отказаться от подписки?"),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "schedule": MessageLookupByLibrary.simpleMessage("Расписание"),
        "search": MessageLookupByLibrary.simpleMessage("Поиск"),
        "searchEpisode": MessageLookupByLibrary.simpleMessage("Поиск выпуска"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Введите название подкаста, ключевые слова или введите URL канала."),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Неверная ссылка RSS"),
        "searchPodcast":
            MessageLookupByLibrary.simpleMessage("Искать подкасты"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage": MessageLookupByLibrary.simpleMessage("Хранилище"),
        "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Цвет акцента"),
        "settingsAccentColorDes":
            MessageLookupByLibrary.simpleMessage("Выбор цвета темы"),
        "settingsAppIntro":
            MessageLookupByLibrary.simpleMessage("Тур по приложению"),
        "settingsAppearance":
            MessageLookupByLibrary.simpleMessage("Внешний вид"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Цвета и темы"),
        "settingsAudioCache": MessageLookupByLibrary.simpleMessage("Аудиокэш"),
        "settingsAudioCacheDes": MessageLookupByLibrary.simpleMessage(
            "Максимальный размер аудиокэша"),
        "settingsAutoDelete":
            MessageLookupByLibrary.simpleMessage("Автоудаление загрузок через"),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("По умолчанию 30 дней"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Автоматическое воспроизведение следующего выпуска в плейлисте"),
        "settingsBackup":
            MessageLookupByLibrary.simpleMessage("Резервное копирование"),
        "settingsBackupDes": MessageLookupByLibrary.simpleMessage(
            "Резервное копирование данных приложения"),
        "settingsBoostVolume":
            MessageLookupByLibrary.simpleMessage("Уровень усиления громкости"),
        "settingsBoostVolumeDes": MessageLookupByLibrary.simpleMessage(
            "Изменение уровня усиления громкости"),
        "settingsDefaultGrid":
            MessageLookupByLibrary.simpleMessage("Вид сетки по умолчанию"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("Вкладка \'Загрузки\'"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Вкладка \'Избранное\'"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Страница подкаста"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("Вкладка \'Недавние\'"),
        "settingsDiscovery": MessageLookupByLibrary.simpleMessage(
            "Повторно активировать руководство"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("Позиция для скачивания"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Включить синхронизацию"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Обновлять все подкасты в фоновом режиме, чтобы получать последние выпуски."),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Экспорт и импорт настроек приложения"),
        "settingsFastForwardSec":
            MessageLookupByLibrary.simpleMessage("Секунды перемотки вперед"),
        "settingsFastForwardSecDes": MessageLookupByLibrary.simpleMessage(
            "Изменение времени перемотки вперед в плеере"),
        "settingsFeedback":
            MessageLookupByLibrary.simpleMessage("Обратная связь"),
        "settingsFeedbackDes":
            MessageLookupByLibrary.simpleMessage("Ошибки и пожелания"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("История"),
        "settingsHistoryDes":
            MessageLookupByLibrary.simpleMessage("Данные о прослушивании"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Информация"),
        "settingsInterface": MessageLookupByLibrary.simpleMessage("Интерфейс"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Языки"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Изменить язык"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Стиль"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Стиль приложения"),
        "settingsLibraries": MessageLookupByLibrary.simpleMessage("Библиотеки"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Библиотеки с открытым исходным кодом, используемые в этом приложении"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("Управление загрузками"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "Управление загруженными аудиофайлами"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Отметить как прослушанный, если пропущен"),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Автоматическая отметка выпуска как прослушанного при переходе к следующему"),
        "settingsMenuAutoPlay":
            MessageLookupByLibrary.simpleMessage("Автовоспроизведение"),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Запрос перед использованием мобильной сети"),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Автоматическая загрузка через мобильную сеть"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "Вы можете настроить автоматическую загрузку подкастов на странице управления группой"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Запрашивать подтверждение при использовании мобильной сети для загрузки выпусков"),
        "settingsPlayDes":
            MessageLookupByLibrary.simpleMessage("Плейлист и плеер"),
        "settingsPlayerHeight":
            MessageLookupByLibrary.simpleMessage("Высота плейера"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Изменение высоты виджета плеера по своему усмотрению"),
        "settingsPopupMenu":
            MessageLookupByLibrary.simpleMessage("Всплывающее меню выпусков"),
        "settingsPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Настройка всплывающего меню выпусков"),
        "settingsPrefrence":
            MessageLookupByLibrary.simpleMessage("Предпочтения"),
        "settingsRealDark":
            MessageLookupByLibrary.simpleMessage("Истинный черный"),
        "settingsRealDarkDes": MessageLookupByLibrary.simpleMessage(
            "Акцентированный темный режим"),
        "settingsRewindSec":
            MessageLookupByLibrary.simpleMessage("Секунды перемотки назад"),
        "settingsRewindSecDes": MessageLookupByLibrary.simpleMessage(
            "Изменение времени перемотки назад в плеере"),
        "settingsSTAuto": MessageLookupByLibrary.simpleMessage(
            "Автоматическое включение таймера сна"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Автоматический запуск таймера сна в запланированное время"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Время по умолчанию"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Время по умолчанию для таймера сна"),
        "settingsSTMode": MessageLookupByLibrary.simpleMessage(
            "Автоматический режим таймера сна"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Скорости"),
        "settingsSpeedsDes": MessageLookupByLibrary.simpleMessage(
            "Настроить доступные скорости"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Управление кэшем и хранилищем загрузок"),
        "settingsSyncing":
            MessageLookupByLibrary.simpleMessage("Синхронизация"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Обновление подкастов в фоновом режиме"),
        "settingsTapToOpenPopupMenu": MessageLookupByLibrary.simpleMessage(
            "Нажмите для открытия всплывающего меню"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Для открытия страницы выпуска нажмите и удерживайте"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Тема"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Интервал обновления"),
        "settingsUpdateIntervalDes":
            MessageLookupByLibrary.simpleMessage("По умолчанию 24 часа"),
        "share": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "showNotesFonts":
            MessageLookupByLibrary.simpleMessage("Показать шрифт заметок"),
        "size": MessageLookupByLibrary.simpleMessage("Размер"),
        "skipSecondsAtEnd": MessageLookupByLibrary.simpleMessage(
            "Пропустить несколько секунд в конце"),
        "skipSecondsAtStart": MessageLookupByLibrary.simpleMessage(
            "Пропустить секунды при запуске"),
        "skipSilence":
            MessageLookupByLibrary.simpleMessage("Пропускать тишину"),
        "skipToNext":
            MessageLookupByLibrary.simpleMessage("Перейти к следующему"),
        "sleepTimer": MessageLookupByLibrary.simpleMessage("Таймер сна"),
        "status": MessageLookupByLibrary.simpleMessage("Статус"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage("Ошибка аутентификации"),
        "statusFail": MessageLookupByLibrary.simpleMessage("Не удалось"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Успешно"),
        "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Подписаться"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Экспорт OPML-файла всех подкастов"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Синхронизировать"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("По умолчанию"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist":
            MessageLookupByLibrary.simpleMessage("Добавлен в плейлист"),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Руководство сброшено. Перезапустите приложение."),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Ошибка файла, ошибка подписки"),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("Неверный файл"),
        "toastHomeGroupNotSupport": MessageLookupByLibrary.simpleMessage(
            "Домашняя группа не поддерживается"),
        "toastImportSettingsSuccess": MessageLookupByLibrary.simpleMessage(
            "Настройки успешно импортированы"),
        "toastOneGroup": MessageLookupByLibrary.simpleMessage(
            "Выберите хотя бы одну группу"),
        "toastPodcastRecovering": MessageLookupByLibrary.simpleMessage(
            "Восстановление, подождите немного"),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("Файл успешно прочитан"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Не удалось восстановить подкаст"),
        "toastRemovePlaylist":
            MessageLookupByLibrary.simpleMessage("Выпуск удален из плейлиста"),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Настройки сохранены"),
        "toastTimeEqualEnd": MessageLookupByLibrary.simpleMessage(
            "Время соответствует времени конца"),
        "toastTimeEqualStart": MessageLookupByLibrary.simpleMessage(
            "Время соответствует времени начала"),
        "translators": MessageLookupByLibrary.simpleMessage("Переводчики"),
        "understood": MessageLookupByLibrary.simpleMessage("Понятно"),
        "undo": MessageLookupByLibrary.simpleMessage("ВЕРНУТЬ"),
        "unlike": MessageLookupByLibrary.simpleMessage("Не нравится"),
        "unliked":
            MessageLookupByLibrary.simpleMessage("Выпуск удален из избранного"),
        "updateDate": MessageLookupByLibrary.simpleMessage("Дата обновления"),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Ошибка обновления, ошибка сети"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Имя пользователя"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Требуется имя пользователя"),
        "version": m31
      };
}
