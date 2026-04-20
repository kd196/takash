import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takaş'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Doğrula'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni mi unuttun?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get dontHaveAccount;

  /// No description provided for @haveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get haveAccount;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get changePassword;

  /// No description provided for @changeEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Değiştir'**
  String get changeEmail;

  /// No description provided for @listings.
  ///
  /// In tr, this message translates to:
  /// **'İlanlar'**
  String get listings;

  /// No description provided for @favorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get favorites;

  /// No description provided for @myListings.
  ///
  /// In tr, this message translates to:
  /// **'İlanlarım'**
  String get myListings;

  /// No description provided for @createListing.
  ///
  /// In tr, this message translates to:
  /// **'İlan Ver'**
  String get createListing;

  /// No description provided for @title.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get title;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @price.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat'**
  String get price;

  /// No description provided for @location.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get location;

  /// No description provided for @photos.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar'**
  String get photos;

  /// No description provided for @images.
  ///
  /// In tr, this message translates to:
  /// **'Görseller'**
  String get images;

  /// No description provided for @chat.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet'**
  String get chat;

  /// No description provided for @messages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messages;

  /// No description provided for @sendMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj Gönder'**
  String get sendMessage;

  /// No description provided for @typeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınızı yazın...'**
  String get typeMessage;

  /// No description provided for @map.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get map;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filter;

  /// No description provided for @apply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Hata oluştu'**
  String get errorOccurred;

  /// No description provided for @somethingWentWrong.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// No description provided for @refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  /// No description provided for @noData.
  ///
  /// In tr, this message translates to:
  /// **'Veri bulunmuyor'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// No description provided for @validEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get validEmail;

  /// No description provided for @validPassword.
  ///
  /// In tr, this message translates to:
  /// **'En az 6 karakter girin'**
  String get validPassword;

  /// No description provided for @fieldRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan zorunludur'**
  String get fieldRequired;

  /// No description provided for @welcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldiniz'**
  String get welcome;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz bulunmuyor'**
  String get noNotifications;

  /// No description provided for @all.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  /// No description provided for @newCondition.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get newCondition;

  /// No description provided for @used.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılmış'**
  String get used;

  /// No description provided for @good.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get good;

  /// No description provided for @active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @sold.
  ///
  /// In tr, this message translates to:
  /// **'Satıldı'**
  String get sold;

  /// No description provided for @available.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut'**
  String get available;

  /// No description provided for @contactSeller.
  ///
  /// In tr, this message translates to:
  /// **'Satıcıya Mesaj At'**
  String get contactSeller;

  /// No description provided for @viewOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada Gör'**
  String get viewOnMap;

  /// No description provided for @addToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere Ekle'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden Kaldır'**
  String get removeFromFavorites;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seç'**
  String get selectLanguage;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account;

  /// No description provided for @appearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get darkTheme;

  /// No description provided for @systemDefault.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Varsayılanı'**
  String get systemDefault;

  /// No description provided for @pushNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Push Bildirimleri'**
  String get pushNotifications;

  /// No description provided for @locationSharing.
  ///
  /// In tr, this message translates to:
  /// **'Konum Paylaşımı'**
  String get locationSharing;

  /// No description provided for @visibleToNearbyUsers.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki kullanıcılara görün'**
  String get visibleToNearbyUsers;

  /// No description provided for @profileVisibility.
  ///
  /// In tr, this message translates to:
  /// **'Profil Görünürlüğü'**
  String get profileVisibility;

  /// No description provided for @profileIsPublic.
  ///
  /// In tr, this message translates to:
  /// **'Profiliniz herkese açık'**
  String get profileIsPublic;

  /// No description provided for @support.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In tr, this message translates to:
  /// **'Yardım Merkezi'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulaşın'**
  String get contactUs;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinize emin misiniz?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @discover.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get discover;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In tr, this message translates to:
  /// **'Ne arıyorsun?'**
  String get whatAreYouLookingFor;

  /// No description provided for @searchResultsFor.
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" için sonuçlar'**
  String searchResultsFor(Object query);

  /// No description provided for @noResultsFound.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResultsFound;

  /// No description provided for @noListingsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ilan yok'**
  String get noListingsYet;

  /// No description provided for @clearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri Temizle'**
  String get clearFilters;

  /// No description provided for @searchListing.
  ///
  /// In tr, this message translates to:
  /// **'İlan Ara'**
  String get searchListing;

  /// No description provided for @loginRequired.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapmalısınız.'**
  String get loginRequired;

  /// No description provided for @userNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı.'**
  String get userNotFound;

  /// No description provided for @createNewAccount.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hesap Oluştur'**
  String get createNewAccount;

  /// No description provided for @joinSwapWorld.
  ///
  /// In tr, this message translates to:
  /// **'Yakınındaki takas dünyasına katıl!'**
  String get joinSwapWorld;

  /// No description provided for @displayName.
  ///
  /// In tr, this message translates to:
  /// **'İsim Soyisim'**
  String get displayName;

  /// No description provided for @enterYourName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen isminizi girin'**
  String get enterYourName;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get signInWithGoogle;

  /// No description provided for @or.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get or;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
