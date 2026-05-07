import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('tk'), Locale('ru')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'tk': {
      'appTitle': 'Usta hyzmaty',
      'loading': 'Ýüklenýär...',
      'phoneLoginTitle': 'Hoş geldiňiz!',
      'phoneLoginSubtitle':
          'Sistema girmek üçin telefon belgiňizi ýazyň. Biz size tassyklayş kodyny (OTP) ugradarys.',
      'phoneNumber': 'Telefon belgisi',
      'continueAction': 'Giriş',
      'termsNotice': 'Ulgama girişi dowam etdirip, siz biziň',
      'termsLink': 'Şertnamamyzy',
      'termsAccept': 'kabul edýärsiňiz.',
      'verifiedMasters': 'HÜNÄRMENLER\nTassyklanan',
      'fastService': 'HYZMAT\nTiz wagtda',
      'copyright': '© 2024 Usta hyzmaty. Ähli hukuklar goragly.',
      'otpTitle': 'OTP tassyklama',
      'otpSubtitle': 'Telefon belgiňize gelen kody giriziň.',
      'otpCode': 'OTP kody',
      'verify': 'Tassyklamak',
      'profileSetupTitle': 'Profil maglumatlary',
      'profileSetupSubtitle':
          'Adyňyz, familiýaňyz we şäheriňiz API bilen doldurylar.',
      'completeProfile': 'Profili tamamla',
      'categorySetupTitle': 'Hyzmat kategoriýalary',
      'categorySetupSubtitle':
          'Bir ýa-da birnäçe hyzmat kategoriýasyny saýlaň.',
      'completeCategories': 'Kategoriýalary tamamla',
      'homeTitle': 'Ussa paneli',
      'homeGreeting': 'Hoş geldiňiz, Myrat!',
      'homeSubtitle': 'Bugun täze sargytlar bar.',
      'active': 'AKTIW',
      'completed': 'TAMAMLANAN',
      'earnings': 'GAZANÇ',
      'currentJob': 'Häzirki iş',
      'started': 'Işe başlandy',
      'customer': 'Müşderi',
      'openMap': 'Kartany aç',
      'notCash': 'NAGT DÄL',
      'complete': 'Tamamla',
      'newOrders': 'Täze sargytlar',
      'seeAll': 'Hemmesini gör',
      'newOrder': 'Täze',
      'newRequest': 'Täze sargyt',
      'yourLocation': 'SENIŇ ÝERIŇ',
      'installSocket': 'Rozetka\ngurnamak',
      'distanceTime': '2.5 km • 12 min',
      'cardNotCash': 'Sowma däl',
      'sleep': 'Ýatyr',
      'accept': 'Kabul et',
      'homeTab': 'Baş sahypa',
      'ordersTab': 'Sargytlarym',
      'mapTab': 'Karta',
      'profileTab': 'Profil',
      'jobs': 'Sargytlar',
      'myJobsTitle': 'Meniň işlerim',
      'myJobsSubtitle': 'Bellenen we ýerine ýetirilýän sargytlar',
      'assigned': 'Bellenen',
      'inProgress': 'Dowam\nedýär',
      'startJob': 'Işe başla',
      'ordersHistory': 'Sargytlaryň taryhy',
      'completedOrdersSubtitle': 'Öň tamamlanan işleriniz',
      'report': 'Hasabat',
      'completeOrderTitle': 'Sargydy tamamla',
      'before': '"Öň" (Before)',
      'after': '"Soň" (After)',
      'photo': 'Surat',
      'addPhoto': 'Surat goş',
      'priceConfirmation': 'Baha tassyklamak',
      'priceConfirmationDescription':
          'Jemi bahany anyklamak we tassyklatmak üçin operatorymyz bilen hökman habarlaşyň. Baha operator tarapyndan ulgama giriziler.',
      'callOperator': 'Operatora jaň et',
      'completionNote':
          '"Tamamla" düwmesine basmak bilen hyzmatyň doly we talabalaýyk ýerine ýetirilendigini, şeýle hem ähli gerekli suratlaryň goşulandygyny tassyklaýarsyňyz.',
      'history': 'Taryh',
      'payments': 'Tölegler',
      'settings': 'Sazlamalar',
      'accountSettings': 'HASAP SAZLAMALARY',
      'paymentHistory': 'Töleg taryhy',
      'support': 'Goldaw',
      'profileLocation': 'Aşgabat, Türkmenistan',
      'accessActive': 'Elýeterlilik işjeň',
      'accessExpired': 'Elýeterlilik möhleti gutardy',
      'signOut': 'Çykmak',
      'placeholder': 'Bu bölüm API şertnamasy taýýar bolanda ösdüriler.',
    },
    'ru': {
      'appTitle': 'Сервис мастеров',
      'loading': 'Загрузка...',
      'phoneLoginTitle': 'Ваш телефон',
      'phoneLoginSubtitle': 'Для входа вы получите OTP-код.',
      'phoneNumber': 'Номер телефона',
      'continueAction': 'Продолжить',
      'termsNotice': 'Продолжая вход, вы принимаете',
      'termsLink': 'условия сервиса',
      'termsAccept': '.',
      'verifiedMasters': 'МАСТЕРА\nПроверенные',
      'fastService': 'СЕРВИС\nБыстро',
      'copyright': '© 2024 Usta hyzmaty. Все права защищены.',
      'otpTitle': 'Подтверждение OTP',
      'otpSubtitle': 'Введите код, отправленный на ваш телефон.',
      'otpCode': 'OTP-код',
      'verify': 'Подтвердить',
      'profileSetupTitle': 'Профиль мастера',
      'profileSetupSubtitle':
          'Имя, фамилия и город будут заполняться через API.',
      'completeProfile': 'Завершить профиль',
      'categorySetupTitle': 'Категории услуг',
      'categorySetupSubtitle': 'Выберите одну или несколько категорий услуг.',
      'completeCategories': 'Завершить категории',
      'homeTitle': 'Панель мастера',
      'homeGreeting': 'Добро пожаловать, Мурат!',
      'homeSubtitle': 'Сегодня есть новые заявки.',
      'active': 'АКТИВНЫЕ',
      'completed': 'ЗАВЕРШЕНО',
      'earnings': 'ДОХОД',
      'currentJob': 'Текущая работа',
      'started': 'Работа началась',
      'customer': 'Клиент',
      'openMap': 'Открыть карту',
      'notCash': 'БЕЗНАЛ',
      'complete': 'Завершить',
      'newOrders': 'Новые заявки',
      'seeAll': 'Смотреть все',
      'newOrder': 'Новая',
      'newRequest': 'Новая заявка',
      'yourLocation': 'ВАШЕ МЕСТО',
      'installSocket': 'Установить\nрозетку',
      'distanceTime': '2.5 км • 12 мин',
      'cardNotCash': 'Безнал',
      'sleep': 'Спит',
      'accept': 'Принять',
      'homeTab': 'Главная',
      'ordersTab': 'Мои заявки',
      'mapTab': 'Карта',
      'profileTab': 'Профиль',
      'jobs': 'Заявки',
      'myJobsTitle': 'Мои работы',
      'myJobsSubtitle': 'Назначенные и выполняемые заявки',
      'assigned': 'Назначена',
      'inProgress': 'В работе',
      'startJob': 'Начать',
      'ordersHistory': 'История заявок',
      'completedOrdersSubtitle': 'Ваши завершенные работы',
      'report': 'Отчет',
      'completeOrderTitle': 'Завершить заявку',
      'before': '"До" (Before)',
      'after': '"После" (After)',
      'photo': 'Фото',
      'addPhoto': 'Добавить фото',
      'priceConfirmation': 'Подтверждение цены',
      'priceConfirmationDescription':
          'Для уточнения и подтверждения итоговой суммы обязательно свяжитесь с оператором. Цена будет внесена оператором в систему.',
      'callOperator': 'Позвонить оператору',
      'completionNote':
          'Нажимая "Завершить", вы подтверждаете, что услуга выполнена полностью и по требованиям, а все необходимые фотографии добавлены.',
      'history': 'История',
      'payments': 'Выплаты',
      'settings': 'Настройки',
      'accountSettings': 'НАСТРОЙКИ АККАУНТА',
      'paymentHistory': 'История оплат',
      'support': 'Поддержка',
      'profileLocation': 'Ашхабад, Туркменистан',
      'accessActive': 'Доступ активен',
      'accessExpired': 'Срок доступа истек',
      'signOut': 'Выйти',
      'placeholder': 'Раздел будет развит после готовности API-контракта.',
    },
  };

  String text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['tk']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
