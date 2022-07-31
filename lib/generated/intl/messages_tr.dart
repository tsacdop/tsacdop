// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
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
  String get localeName => 'tr';

  static String m0(groupName, count) =>
      "${Intl.plural(count, zero: '', one: '${groupName} deki ${count} bölüm çalma listesine eklendi', other: '${groupName} deki ${count} bölüm çalma listesine eklendi')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: '${count} bölüm çalma listesine eklendi', other: '${count} bölüm çalma listesine eklendi')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Bugün', one: '${count} gün önce', other: '${count} gün önce')}";

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Asla', one: '${count} gün', other: '${count} gün')}";

  static String m4(count) =>
      "${Intl.plural(count, zero: '', one: 'Bölüm', other: 'Bölümler')}";

  static String m5(time) => "${time} e kadar";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Liste', one: 'Liste', other: 'Listeler')}";

  static String m7(host) => "${host} da depolanır";

  static String m8(count) =>
      "${Intl.plural(count, zero: 'Bir saat içinde', one: '${count} saat önce', other: '${count} saat önce')}";

  static String m9(count) =>
      "${Intl.plural(count, zero: '0 saat', one: '${count} saat', other: '${count} saat')}";

  static String m10(service) => "${service} ile bağlantı kur";

  static String m11(userName) => "${userName} olarak giriş yapıldı ";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Şimdi', one: '${count} dakika önce', other: '${count} dakika önce')}";

  static String m13(count) =>
      "${Intl.plural(count, zero: '0 dk', one: '${count} dk', other: '${count} dk')}";

  static String m14(title) => "Bilgiler toplanıyor ${title}";

  static String m15(title) =>
      "Abonelik başarısız oldu, bağlantı hatası ${title}";

  static String m16(title) => "Abone ol ${title}";

  static String m17(title) =>
      "Abonelik başarısız oldu, podcast zaten mevcut ${title}";

  static String m18(title) => "Başarıyla abone olundu";

  static String m19(title) => "Güncelleme ${title}";

  static String m20(title) => "Güncelleme hatası ${title}";

  static String m21(count) =>
      "${Intl.plural(count, zero: '', one: 'Bölüm', other: 'Bölümler')}";

  static String m22(date) => "${date} tarihinde yayınlandı";

  static String m23(date) => "${date} tarihinde kaldırıldı";

  static String m24(count) =>
      "${Intl.plural(count, zero: '0 sn', one: '${count} sn', other: '${count} sn')}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Şimdi', one: '${count} saniye önce', other: '${count} saniye önce')}";

  static String m26(count) => "${count} seçilen";

  static String m27(time) => "En son ${time}";

  static String m28(time) => "${time} kaldı";

  static String m29(time) => "${time} den";

  static String m30(count) =>
      "${Intl.plural(count, zero: 'Güncelleme yok', one: '${count} bölüm güncellendi', other: '${count} bölüm güncellendi')}";

  static String m31(version) => "Version: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Ekle"),
        "addEpisodeGroup": m0,
        "addNewEpisodeAll": m1,
        "addNewEpisodeTooltip": MessageLookupByLibrary.simpleMessage(
            "Çalma listesine yeni bölüm ekle"),
        "addSomeGroups": MessageLookupByLibrary.simpleMessage("Liste eklel"),
        "all": MessageLookupByLibrary.simpleMessage("Hepsi"),
        "autoDownload":
            MessageLookupByLibrary.simpleMessage("Otomatik indirme"),
        "back": MessageLookupByLibrary.simpleMessage("Geri"),
        "boostVolume": MessageLookupByLibrary.simpleMessage("Sesi yükselt"),
        "buffering": MessageLookupByLibrary.simpleMessage("Yükleniyor"),
        "cancel": MessageLookupByLibrary.simpleMessage("İPTAL"),
        "cellularConfirm":
            MessageLookupByLibrary.simpleMessage("Hücresel veri uyarısı"),
        "cellularConfirmDes": MessageLookupByLibrary.simpleMessage(
            "İndirmek için hücresel veri kullanmak istediğinden emin misin?"),
        "changeLayout":
            MessageLookupByLibrary.simpleMessage("Görünümü değiştir"),
        "changelog": MessageLookupByLibrary.simpleMessage("Neler yeni?"),
        "chooseA": MessageLookupByLibrary.simpleMessage("Seç"),
        "clear": MessageLookupByLibrary.simpleMessage("Temizle"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Hepsini sil"),
        "color": MessageLookupByLibrary.simpleMessage("renk"),
        "confirm": MessageLookupByLibrary.simpleMessage("ONAY"),
        "createNewPlaylist":
            MessageLookupByLibrary.simpleMessage("Yeni çalma listesi"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Karanlık mod"),
        "daysAgo": m2,
        "daysCount": m3,
        "defaultQueueReminder": MessageLookupByLibrary.simpleMessage(
            "Varsayılan sıralama kaldırılamaz."),
        "defaultSearchEngine": MessageLookupByLibrary.simpleMessage(
            "Varsayılan podcast arama motoru"),
        "defaultSearchEngineDes": MessageLookupByLibrary.simpleMessage(
            "Varsayılan podcast arama motorunu seçin"),
        "delete": MessageLookupByLibrary.simpleMessage("Sil"),
        "developer": MessageLookupByLibrary.simpleMessage("Geliştirici"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Kaybol"),
        "done": MessageLookupByLibrary.simpleMessage("Bitti"),
        "download": MessageLookupByLibrary.simpleMessage("İndirilen"),
        "downloadRemovedToast":
            MessageLookupByLibrary.simpleMessage("İndirme kaldırıldı"),
        "downloadStart": MessageLookupByLibrary.simpleMessage("İndiriliyor"),
        "downloaded": MessageLookupByLibrary.simpleMessage("İndirilenler"),
        "editGroupName":
            MessageLookupByLibrary.simpleMessage("Liste adını değiştir"),
        "endOfEpisode": MessageLookupByLibrary.simpleMessage("Bölüm sonu"),
        "episode": m4,
        "fastForward": MessageLookupByLibrary.simpleMessage("İleri sar"),
        "fastRewind": MessageLookupByLibrary.simpleMessage("Geri sar"),
        "featureDiscoveryEditGroup": MessageLookupByLibrary.simpleMessage(
            "Grupları düzenlemek için tıkla"),
        "featureDiscoveryEditGroupDes": MessageLookupByLibrary.simpleMessage(
            "Buradan liste ismini değiştirebilir ya da silebilirsin, ancak Başlangıç sayfası değiştirilemez."),
        "featureDiscoveryEpisode":
            MessageLookupByLibrary.simpleMessage("Bölüm görünümü"),
        "featureDiscoveryEpisodeDes": MessageLookupByLibrary.simpleMessage(
            "Bölümü oynatmak için uzun dokun veya bir çalma listesine ekle. "),
        "featureDiscoveryEpisodeTitle": MessageLookupByLibrary.simpleMessage(
            "Bölümü hemen oynatmak için uzun bas"),
        "featureDiscoveryGroup": MessageLookupByLibrary.simpleMessage(
            "Listeyi düzenlemek için tıkla"),
        "featureDiscoveryGroupDes": MessageLookupByLibrary.simpleMessage(
            "Başlangıç sayfası yeni podcastler için ön tanımlı sayfadır. Yeni listeler oluşturabilir ve podcastleri içine koyabilirsin. Bir podcasti birden çok listeye koyabilirsin. "),
        "featureDiscoveryGroupPodcast": MessageLookupByLibrary.simpleMessage(
            "Podcastleri sıralamak için uzun bas"),
        "featureDiscoveryGroupPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Daha fazla seçenek için tıklayabilirsin ya da uzunca basarak listedeki podcastleri sıralayabilirsin."),
        "featureDiscoveryOMPL": MessageLookupByLibrary.simpleMessage(
            "OPML dosyasını içe aktarmak için dokun"),
        "featureDiscoveryOMPLDes": MessageLookupByLibrary.simpleMessage(
            "Buradan OPML dosyalarını içe aktarabilir, ayarları açabilir ya da tüm podcastleri aynı anda yenileyebilirsin."),
        "featureDiscoveryPlaylist": MessageLookupByLibrary.simpleMessage(
            "Çalma listesini açmak için dokun"),
        "featureDiscoveryPlaylistDes": MessageLookupByLibrary.simpleMessage(
            "Çalma listelerine bölüm ekleyebilirsin. Bölümler oynatıldığında çalma listelerinden otomatik olarak silinir. "),
        "featureDiscoveryPodcast":
            MessageLookupByLibrary.simpleMessage("Podcast görünümü"),
        "featureDiscoveryPodcastDes": MessageLookupByLibrary.simpleMessage(
            "Liste eklemek için Hepsini Göster\'e dokun ya da podcastleri düzenle."),
        "featureDiscoveryPodcastTitle": MessageLookupByLibrary.simpleMessage(
            "Listeler arasında dolaşmak için sağa sola kaydır"),
        "featureDiscoverySearch": MessageLookupByLibrary.simpleMessage(
            "Podcast aramak için buraya dokun"),
        "featureDiscoverySearchDes": MessageLookupByLibrary.simpleMessage(
            "Podcast adı, RSS linki, veya bir kaç harf girerek yeni podcast arayabilirsin."),
        "feedbackEmail": MessageLookupByLibrary.simpleMessage("İletişim"),
        "feedbackGithub": MessageLookupByLibrary.simpleMessage("Sorun bildir"),
        "feedbackPlay":
            MessageLookupByLibrary.simpleMessage("Play Store\'da oyla"),
        "feedbackTelegram":
            MessageLookupByLibrary.simpleMessage("Telegram Grubu"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtrele"),
        "fontStyle": MessageLookupByLibrary.simpleMessage("Yazı tipi stili"),
        "fonts": MessageLookupByLibrary.simpleMessage("Yazı tipleri"),
        "from": m5,
        "goodNight": MessageLookupByLibrary.simpleMessage("İyi Geceler"),
        "gpodderLoginDes": MessageLookupByLibrary.simpleMessage(
            "Tebrikler! Gpodder.net hesabınızla bağlantı kuruldu.Tsacdop aboneliklerinizi gpodder.net  hesabınızla otomatik olarak eşitleyecek."),
        "groupExisted":
            MessageLookupByLibrary.simpleMessage("Liste zaten mevcut"),
        "groupFilter":
            MessageLookupByLibrary.simpleMessage("Listeleye göre filtrele"),
        "groupRemoveConfirm": MessageLookupByLibrary.simpleMessage(
            "Bu listeyi silmek istediğine emin misin? Podcastler Başlangıç sayfasına aktarılacaktır."),
        "groups": m6,
        "hideListenedSetting":
            MessageLookupByLibrary.simpleMessage("Oynatılanları gizle"),
        "hidePodcastDiscovery":
            MessageLookupByLibrary.simpleMessage("Podcast önerilerini gizle"),
        "hidePodcastDiscoveryDes": MessageLookupByLibrary.simpleMessage(
            "Podcast önerilerini arama sayfasında gösterme"),
        "homeGroupsSeeAll": MessageLookupByLibrary.simpleMessage("Hepsini gör"),
        "homeMenuPlaylist":
            MessageLookupByLibrary.simpleMessage("Çalma listesi"),
        "homeSubMenuSortBy": MessageLookupByLibrary.simpleMessage("Sıralama"),
        "homeTabMenuFavotite": MessageLookupByLibrary.simpleMessage("Favori"),
        "homeTabMenuRecent":
            MessageLookupByLibrary.simpleMessage("Son çalınan"),
        "homeToprightMenuAbout":
            MessageLookupByLibrary.simpleMessage("Hakkında"),
        "homeToprightMenuImportOMPL":
            MessageLookupByLibrary.simpleMessage("OPML içe aktar"),
        "homeToprightMenuRefreshAll":
            MessageLookupByLibrary.simpleMessage("Hepsini yenile"),
        "hostedOn": m7,
        "hoursAgo": m8,
        "hoursCount": m9,
        "import": MessageLookupByLibrary.simpleMessage("İçe aktar"),
        "intergateWith": m10,
        "introFourthPage": MessageLookupByLibrary.simpleMessage(
            "Bölüm resmine uzun basarak hızlı menüyü açabilirsin."),
        "introSecondPage": MessageLookupByLibrary.simpleMessage(
            "Arama yaparak ya da OPML dosyasını içe aktararak podcaste abone olabilirsin."),
        "introThirdPage": MessageLookupByLibrary.simpleMessage(
            "Podcastler için yeni bir grup oluşturabilirsin."),
        "invalidName":
            MessageLookupByLibrary.simpleMessage("Geçersiz kullanıcı adı"),
        "lastUpdate": MessageLookupByLibrary.simpleMessage("Son güncelleme\n"),
        "later": MessageLookupByLibrary.simpleMessage("Sonra"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Aydınlık mod"),
        "like": MessageLookupByLibrary.simpleMessage("Beğen"),
        "likeDate": MessageLookupByLibrary.simpleMessage("Beğenilme tarihi"),
        "liked": MessageLookupByLibrary.simpleMessage("Beğenilen"),
        "listen": MessageLookupByLibrary.simpleMessage("Dinle"),
        "listened": MessageLookupByLibrary.simpleMessage("Oynatılan"),
        "loadMore": MessageLookupByLibrary.simpleMessage("Daha fazla göster"),
        "loggedInAs": m11,
        "login": MessageLookupByLibrary.simpleMessage("Giriş"),
        "loginFailed": MessageLookupByLibrary.simpleMessage("Giriş başarısız "),
        "logout": MessageLookupByLibrary.simpleMessage("Çıkış yap"),
        "mark": MessageLookupByLibrary.simpleMessage("İşaretle"),
        "markConfirm": MessageLookupByLibrary.simpleMessage("Seçimi onayla"),
        "markConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Tüm bölümler oynatıldı olarak işaretlensin mi?"),
        "markListened":
            MessageLookupByLibrary.simpleMessage("Oynatıldı olarak işaretle"),
        "markNotListened":
            MessageLookupByLibrary.simpleMessage("Oynatılmadı olarak işaretle"),
        "menu": MessageLookupByLibrary.simpleMessage("Menü"),
        "menuAllPodcasts":
            MessageLookupByLibrary.simpleMessage("Tüm podcastler"),
        "menuMarkAllListened": MessageLookupByLibrary.simpleMessage(
            "Hepsini oynatıldı olarak işaretle"),
        "menuViewRSS":
            MessageLookupByLibrary.simpleMessage("RSS akışını ziyaret et"),
        "menuVisitSite":
            MessageLookupByLibrary.simpleMessage("Siteyi ziyaret et"),
        "minsAgo": m12,
        "minsCount": m13,
        "network": MessageLookupByLibrary.simpleMessage("Bağlantı"),
        "neverAutoUpdate":
            MessageLookupByLibrary.simpleMessage("Otomatik güncellemeyi kapat"),
        "newGroup": MessageLookupByLibrary.simpleMessage("Yeni liste oluştur"),
        "newestFirst": MessageLookupByLibrary.simpleMessage("Önce yeniler"),
        "next": MessageLookupByLibrary.simpleMessage("Sonraki"),
        "noEpisodeDownload": MessageLookupByLibrary.simpleMessage(
            "Henüz hiç bir bölüm indirilmedi"),
        "noEpisodeFavorite": MessageLookupByLibrary.simpleMessage(
            "Henüz hiç bir bölüm toplanmadı"),
        "noEpisodeRecent": MessageLookupByLibrary.simpleMessage(
            "Henüz hiç bir bölüm alınmadı"),
        "noPodcastGroup":
            MessageLookupByLibrary.simpleMessage("Bu listede hiç podcast yok"),
        "noShownote": MessageLookupByLibrary.simpleMessage(
            "Bu bölüm için her hangi bir not mevcut değil"),
        "notificaitonFatch": m14,
        "notificationNetworkError": m15,
        "notificationSetting":
            MessageLookupByLibrary.simpleMessage("Bildirim paneli"),
        "notificationSubscribe": m16,
        "notificationSubscribeExisted": m17,
        "notificationSuccess": m18,
        "notificationUpdate": m19,
        "notificationUpdateError": m20,
        "oldestFirst": MessageLookupByLibrary.simpleMessage("Önce eskiler"),
        "passwdRequired":
            MessageLookupByLibrary.simpleMessage("Parola gerekli"),
        "password": MessageLookupByLibrary.simpleMessage("Şifre"),
        "pause": MessageLookupByLibrary.simpleMessage("Duraklat"),
        "play": MessageLookupByLibrary.simpleMessage("Oynat"),
        "playNext": MessageLookupByLibrary.simpleMessage("Sonrakini çal"),
        "playNextDes": MessageLookupByLibrary.simpleMessage(
            "Çalma listesinin başına ekle"),
        "playback": MessageLookupByLibrary.simpleMessage("Playback kontrol"),
        "player": MessageLookupByLibrary.simpleMessage("Player"),
        "playerHeightMed": MessageLookupByLibrary.simpleMessage("Orta"),
        "playerHeightShort": MessageLookupByLibrary.simpleMessage("Kısa"),
        "playerHeightTall": MessageLookupByLibrary.simpleMessage("Uzun"),
        "playing": MessageLookupByLibrary.simpleMessage("Oynatılıyor"),
        "playlistExisted": MessageLookupByLibrary.simpleMessage(
            "Bu isimde bir çalma listesi mevcut."),
        "playlistNameEmpty":
            MessageLookupByLibrary.simpleMessage("İsimsiz çalma listesi"),
        "playlists": MessageLookupByLibrary.simpleMessage("Çalma listeleri"),
        "plugins": MessageLookupByLibrary.simpleMessage("Eklentiler"),
        "podcast": m21,
        "podcastSubscribed":
            MessageLookupByLibrary.simpleMessage("Podcaste abone olundu"),
        "popupMenuDownloadDes":
            MessageLookupByLibrary.simpleMessage("Bölümü indir"),
        "popupMenuLaterDes":
            MessageLookupByLibrary.simpleMessage("Bölümü çalma listesine ekle"),
        "popupMenuLikeDes":
            MessageLookupByLibrary.simpleMessage("Bölümü favorilere  ekle"),
        "popupMenuMarkDes": MessageLookupByLibrary.simpleMessage(
            "Böümü oynatıdı olarak işaretle"),
        "popupMenuPlayDes": MessageLookupByLibrary.simpleMessage("Bölümü çal"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Gizlilik sözleşmesi"),
        "published": m22,
        "publishedDaily": MessageLookupByLibrary.simpleMessage("Günlük"),
        "publishedMonthly": MessageLookupByLibrary.simpleMessage("Aylık"),
        "publishedWeekly": MessageLookupByLibrary.simpleMessage("Haftalık"),
        "publishedYearly": MessageLookupByLibrary.simpleMessage("Yıllık"),
        "queue": MessageLookupByLibrary.simpleMessage("Kuyruk"),
        "recoverSubscribe":
            MessageLookupByLibrary.simpleMessage("Aboneliği kurtar"),
        "refresh": MessageLookupByLibrary.simpleMessage("Yenile"),
        "refreshArtwork":
            MessageLookupByLibrary.simpleMessage("Albüm kapağını güncelle"),
        "refreshStarted": MessageLookupByLibrary.simpleMessage("Yenileniyor"),
        "remove": MessageLookupByLibrary.simpleMessage("Kaldır"),
        "removeConfirm": MessageLookupByLibrary.simpleMessage("İptal teyidi"),
        "removeNewMark":
            MessageLookupByLibrary.simpleMessage("Yeni işaretini kaldır"),
        "removePodcastDes": MessageLookupByLibrary.simpleMessage(
            "Aboneliği sonlandırmak istediğine emin misin?"),
        "removedAt": m23,
        "save": MessageLookupByLibrary.simpleMessage("Kaydet"),
        "schedule": MessageLookupByLibrary.simpleMessage("Program"),
        "search": MessageLookupByLibrary.simpleMessage("Ara"),
        "searchEpisode": MessageLookupByLibrary.simpleMessage("Bölüm ara"),
        "searchHelper": MessageLookupByLibrary.simpleMessage(
            "Bir podcast ismi, bir link ya da bir kaç kelime girin."),
        "searchInvalidRss":
            MessageLookupByLibrary.simpleMessage("Geçersiz RSS linki"),
        "searchPodcast": MessageLookupByLibrary.simpleMessage("Podcast ara"),
        "secCount": m24,
        "secondsAgo": m25,
        "selected": m26,
        "settingStorage": MessageLookupByLibrary.simpleMessage("Depolama"),
        "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
        "settingsAccentColor":
            MessageLookupByLibrary.simpleMessage("Ara renk "),
        "settingsAccentColorDes":
            MessageLookupByLibrary.simpleMessage("Katman rengini seç"),
        "settingsAppIntro":
            MessageLookupByLibrary.simpleMessage("Uygulama başlangıcı"),
        "settingsAppearance": MessageLookupByLibrary.simpleMessage("Görünüm"),
        "settingsAppearanceDes":
            MessageLookupByLibrary.simpleMessage("Renkler ve temalar"),
        "settingsAudioCache":
            MessageLookupByLibrary.simpleMessage("Audio cache"),
        "settingsAudioCacheDes":
            MessageLookupByLibrary.simpleMessage("Maksimum audio cache boyutu"),
        "settingsAutoDelete":
            MessageLookupByLibrary.simpleMessage("İndirilenleri otomatik sil"),
        "settingsAutoDeleteDes":
            MessageLookupByLibrary.simpleMessage("Varsayılan 30 gün"),
        "settingsAutoPlayDes": MessageLookupByLibrary.simpleMessage(
            "Çalma listesindeki sonraki bölümü otomatik oynat"),
        "settingsBackup": MessageLookupByLibrary.simpleMessage("Yedekleme"),
        "settingsBackupDes": MessageLookupByLibrary.simpleMessage(
            "Uygulama bilgilerini yedekle"),
        "settingsBoostVolume":
            MessageLookupByLibrary.simpleMessage("Ses yükseltici seviyesi"),
        "settingsBoostVolumeDes":
            MessageLookupByLibrary.simpleMessage("Ses yükselticiyi belirle"),
        "settingsDefaultGrid":
            MessageLookupByLibrary.simpleMessage("Varsayılan ızgara görünümü"),
        "settingsDefaultGridDownload":
            MessageLookupByLibrary.simpleMessage("İndirilenler"),
        "settingsDefaultGridFavorite":
            MessageLookupByLibrary.simpleMessage("Favoriler"),
        "settingsDefaultGridPodcast":
            MessageLookupByLibrary.simpleMessage("Podcastler"),
        "settingsDefaultGridRecent":
            MessageLookupByLibrary.simpleMessage("En son oynatılanlar"),
        "settingsDiscovery": MessageLookupByLibrary.simpleMessage(
            "Keşfet özelliğini yeniden aktifleştir"),
        "settingsDownloadPosition":
            MessageLookupByLibrary.simpleMessage("İndirme konumu"),
        "settingsEnableSyncing":
            MessageLookupByLibrary.simpleMessage("Senkronizasyonu aktive et"),
        "settingsEnableSyncingDes": MessageLookupByLibrary.simpleMessage(
            "En son yayınlananları görüntülemek için tüm podcastleri arka planda güncelle"),
        "settingsExportDes": MessageLookupByLibrary.simpleMessage(
            "Uygulama ayarlarıını içe ya da dışa aktar"),
        "settingsFastForwardSec":
            MessageLookupByLibrary.simpleMessage("İleri sarma hızı"),
        "settingsFastForwardSecDes": MessageLookupByLibrary.simpleMessage(
            "Oynatıcıda ileri sarma saniyesini belirle"),
        "settingsFeedback":
            MessageLookupByLibrary.simpleMessage("Geribildirim "),
        "settingsFeedbackDes":
            MessageLookupByLibrary.simpleMessage("Hata bildirimi ve istekler"),
        "settingsHistory": MessageLookupByLibrary.simpleMessage("Geçmiş"),
        "settingsHistoryDes":
            MessageLookupByLibrary.simpleMessage("Oynatma bilgileri"),
        "settingsInfo": MessageLookupByLibrary.simpleMessage("Bilgi"),
        "settingsInterface": MessageLookupByLibrary.simpleMessage("Ara yüz"),
        "settingsLanguages": MessageLookupByLibrary.simpleMessage("Diller"),
        "settingsLanguagesDes":
            MessageLookupByLibrary.simpleMessage("Dili değiştir"),
        "settingsLayout": MessageLookupByLibrary.simpleMessage("Stil"),
        "settingsLayoutDes":
            MessageLookupByLibrary.simpleMessage("Uygulama stili"),
        "settingsLibraries":
            MessageLookupByLibrary.simpleMessage("Kütüphaneler"),
        "settingsLibrariesDes": MessageLookupByLibrary.simpleMessage(
            "Bu uygulamada kullanılann açık kaynak kütüphaneleri"),
        "settingsManageDownload":
            MessageLookupByLibrary.simpleMessage("İndirilenleri yönet"),
        "settingsManageDownloadDes": MessageLookupByLibrary.simpleMessage(
            "İndirilen ses dosyalarını yönet"),
        "settingsMarkListenedSkip": MessageLookupByLibrary.simpleMessage(
            "Atladığında oynatıldı olarak işaretle."),
        "settingsMarkListenedSkipDes": MessageLookupByLibrary.simpleMessage(
            "Sonrakine atladığımda bu bölümü oynatıldı olarak işaretle."),
        "settingsMenuAutoPlay":
            MessageLookupByLibrary.simpleMessage("Sonrakini otomatik oynat"),
        "settingsNetworkCellular": MessageLookupByLibrary.simpleMessage(
            "Hücresel veri kullanmadan önce sor"),
        "settingsNetworkCellularAuto": MessageLookupByLibrary.simpleMessage(
            "Hücresel (mobil) veri kullanarak otomatik indir"),
        "settingsNetworkCellularAutoDes": MessageLookupByLibrary.simpleMessage(
            "Liste yönetimi sayfasında podcast otomatik indirme seçeneklerini ayarlayabilirsin"),
        "settingsNetworkCellularDes": MessageLookupByLibrary.simpleMessage(
            "Hücresel veri ile bölüm indirmek için sor"),
        "settingsPlayDes":
            MessageLookupByLibrary.simpleMessage("Çalma listesi ve oynatıcı"),
        "settingsPlayerHeight":
            MessageLookupByLibrary.simpleMessage("Oynatıcı yüksekliği"),
        "settingsPlayerHeightDes": MessageLookupByLibrary.simpleMessage(
            "Oynatıcı widget yüksekliğini ayarla"),
        "settingsPopupMenu": MessageLookupByLibrary.simpleMessage(
            "Bölümlerin açılır pencere menüsü"),
        "settingsPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Bölümlerin açılır pencere menüsünü değiştir"),
        "settingsPrefrence": MessageLookupByLibrary.simpleMessage("Tercihler"),
        "settingsRealDark":
            MessageLookupByLibrary.simpleMessage("Gerçek koyu mod"),
        "settingsRealDarkDes": MessageLookupByLibrary.simpleMessage(
            "Sadece koyu mod yeterli gelmediğinde..."),
        "settingsRewindSec":
            MessageLookupByLibrary.simpleMessage("Geri sarma hızı"),
        "settingsRewindSecDes": MessageLookupByLibrary.simpleMessage(
            "Oynatıcıda geri sarma saniyesini belirle"),
        "settingsSTAuto":
            MessageLookupByLibrary.simpleMessage("Otomatik uyku zamanlayıcısı"),
        "settingsSTAutoDes": MessageLookupByLibrary.simpleMessage(
            "Uyku zamanlayıcısını programlanan zamanda otomatik başlat"),
        "settingsSTDefaultTime":
            MessageLookupByLibrary.simpleMessage("Varsayılan zaman"),
        "settingsSTDefautTimeDes": MessageLookupByLibrary.simpleMessage(
            "Uyku zamanlayıcısı için varsayılan zaman"),
        "settingsSTMode":
            MessageLookupByLibrary.simpleMessage("Uyku zamanlayıcısı modu"),
        "settingsSpeeds": MessageLookupByLibrary.simpleMessage("Hız"),
        "settingsSpeedsDes":
            MessageLookupByLibrary.simpleMessage("Mevcut hızı ayarla"),
        "settingsStorageDes": MessageLookupByLibrary.simpleMessage(
            "Cache ve indirme seçeneklerini yönet"),
        "settingsSyncing":
            MessageLookupByLibrary.simpleMessage("Senkronizasyon"),
        "settingsSyncingDes": MessageLookupByLibrary.simpleMessage(
            "Podcastleri arka planla güncelle"),
        "settingsTapToOpenPopupMenu":
            MessageLookupByLibrary.simpleMessage("Menüyü açmak için tıkla"),
        "settingsTapToOpenPopupMenuDes": MessageLookupByLibrary.simpleMessage(
            "Bölüm sayfasını açmak için uzun basmalısın"),
        "settingsTheme": MessageLookupByLibrary.simpleMessage("Tema"),
        "settingsUpdateInterval":
            MessageLookupByLibrary.simpleMessage("Güncelleme aralığı"),
        "settingsUpdateIntervalDes":
            MessageLookupByLibrary.simpleMessage("Varsayılan 24 saat"),
        "share": MessageLookupByLibrary.simpleMessage("Paylaş"),
        "showNotesFonts":
            MessageLookupByLibrary.simpleMessage("Not yazı tipini göster"),
        "size": MessageLookupByLibrary.simpleMessage("Boyut"),
        "skipSecondsAtEnd":
            MessageLookupByLibrary.simpleMessage("Sondaki saniyeleri atla"),
        "skipSecondsAtStart":
            MessageLookupByLibrary.simpleMessage("Başlangıçta saniyeleri atla"),
        "skipSilence": MessageLookupByLibrary.simpleMessage("Boşlukları atla"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("Sonrakine geç"),
        "sleepTimer":
            MessageLookupByLibrary.simpleMessage("Uyku zamanlayıcısı"),
        "status": MessageLookupByLibrary.simpleMessage("Durum"),
        "statusAuthError":
            MessageLookupByLibrary.simpleMessage("Doğrulama hatası"),
        "statusFail": MessageLookupByLibrary.simpleMessage("Başarısız oldu"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Başarılı"),
        "stop": MessageLookupByLibrary.simpleMessage("Dur"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Abone ol"),
        "subscribeExportDes": MessageLookupByLibrary.simpleMessage(
            "Tüm podcastlerin bulunduğu OPML dosyasını içe aktar"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Senkronize et"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("Sistemi izle"),
        "timeLastPlayed": m27,
        "timeLeft": m28,
        "to": m29,
        "toastAddPlaylist":
            MessageLookupByLibrary.simpleMessage("Çalma listesine eklendi"),
        "toastDiscovery": MessageLookupByLibrary.simpleMessage(
            "Keşfet seçeneği tekrar etkinleştirildi, lütfen uygulamayı baştan başlatın."),
        "toastFileError": MessageLookupByLibrary.simpleMessage(
            "Dosya hatası, abonelik başarısız"),
        "toastFileNotValid":
            MessageLookupByLibrary.simpleMessage("Dosya geçersiz"),
        "toastHomeGroupNotSupport": MessageLookupByLibrary.simpleMessage(
            "Başlangıç sayfası desteklenmemekte"),
        "toastImportSettingsSuccess":
            MessageLookupByLibrary.simpleMessage("Ayarlar başarıyla aktarıldı"),
        "toastOneGroup":
            MessageLookupByLibrary.simpleMessage("En az bir liste seçin"),
        "toastPodcastRecovering": MessageLookupByLibrary.simpleMessage(
            "Kurtarılıyor, lütfen bekleyin"),
        "toastReadFile":
            MessageLookupByLibrary.simpleMessage("Dosya başarıyla okundu"),
        "toastRecoverFailed": MessageLookupByLibrary.simpleMessage(
            "Podcast kurtarma başarısız oldu"),
        "toastRemovePlaylist": MessageLookupByLibrary.simpleMessage(
            "Bölüm çalma listesinden kaldırıldı"),
        "toastSettingSaved":
            MessageLookupByLibrary.simpleMessage("Ayarlar kaydedildi"),
        "toastTimeEqualEnd": MessageLookupByLibrary.simpleMessage(
            "Zaman bitiş zamanına eşit olmalıdır"),
        "toastTimeEqualStart": MessageLookupByLibrary.simpleMessage(
            "Zaman başlangıç zamanına eşit olmalıdır"),
        "translators": MessageLookupByLibrary.simpleMessage("Çevirmenler"),
        "understood": MessageLookupByLibrary.simpleMessage("Anlaşıldı"),
        "undo": MessageLookupByLibrary.simpleMessage("GERİ AL"),
        "unlike": MessageLookupByLibrary.simpleMessage("Beğenme"),
        "unliked": MessageLookupByLibrary.simpleMessage(
            "Bölüm favorilerden kaldırıldı"),
        "updateDate":
            MessageLookupByLibrary.simpleMessage("Güncellenme tarihi"),
        "updateEpisodesCount": m30,
        "updateFailed": MessageLookupByLibrary.simpleMessage(
            "Güncelleme başarısız, bağlantı hatası"),
        "useWallpaperTheme": MessageLookupByLibrary.simpleMessage(""),
        "useWallpaperThemeDes": MessageLookupByLibrary.simpleMessage(""),
        "username": MessageLookupByLibrary.simpleMessage("Kullanıcı adı"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Kullanıcı adı gerekli"),
        "version": m31
      };
}
