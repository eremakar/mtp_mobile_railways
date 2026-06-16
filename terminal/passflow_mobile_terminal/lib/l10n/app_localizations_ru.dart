// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get light => 'Светлая';

  @override
  String get menu => 'Меню';

  @override
  String get my_profile => 'Мой профиль';

  @override
  String get route_change => 'Изменение в маршруте';

  @override
  String get choose_route => 'Перевыбрать маршрут';

  @override
  String get settings_notifications => 'Настройки и уведомления';

  @override
  String get terminalSettings => 'Настройки терминала';

  @override
  String get help_support => 'Помощь и поддержка';

  @override
  String get knowledge_base => 'База знаний';

  @override
  String get report_error => 'Сообщить об ошибке';

  @override
  String get tech_support => 'Тех. поддержка приложения';

  @override
  String get user_name => 'Имя пользователя';

  @override
  String get terminalSettingsTitle => 'Настройки терминала';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get themeInterface => 'Тема интерфейса';

  @override
  String get aboutAppTerminal => 'О приложении и терминале';

  @override
  String appVersion(Object version) {
    return 'Версия приложения: $version';
  }

  @override
  String get logoutApp => 'Выйти из приложения';

  @override
  String get logoutDialogTitle => 'Выйти из приложения?';

  @override
  String get logoutDialogMessage =>
      'Вы действительно хотите выйти из приложения? Сессия будет завершена.';

  @override
  String get confirmLogout => 'Выйти';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get lang_ru => 'Русский';

  @override
  String get lang_kk => 'Қазақша';

  @override
  String get done => 'Готово';

  @override
  String get dark => 'Тёмная';

  @override
  String get about_app => 'О приложении';

  @override
  String get selectLanguage => 'Выберите язык приложения';

  @override
  String get version => 'Версия';

  @override
  String get exit => 'Выход';

  @override
  String get home => 'Главная';

  @override
  String get payment => 'Оплата';

  @override
  String get services => 'Сервисы';

  @override
  String get boarding => 'Посадка';

  @override
  String get train_number => 'Номер поезда';

  @override
  String get wagon_number => 'Номер вагона';

  @override
  String get departure_time => 'Время отправления';

  @override
  String get arrival_time => 'Время прибытия';

  @override
  String get no_trains => 'Нет данных по поездам';

  @override
  String get no_stations => 'Нет станций в данных';

  @override
  String get choose => 'Выберите';

  @override
  String get ticket_status => 'Статус билета';

  @override
  String get boarding_pass => 'Посадочный талон';

  @override
  String get cancel_ticket => 'Отменить билет';

  @override
  String get confirm_ticket => 'Подтвердить билет';

  @override
  String get notifications => 'Уведомления';

  @override
  String get profile_settings => 'Настройки профиля';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get help => 'Помощь';

  @override
  String get support => 'Поддержка';

  @override
  String get taskRouteAppBarTitle => 'Маршруты';

  @override
  String get languageSelectedRussian => 'Русский язык выбран';

  @override
  String get languageSelectedKazakh => 'Қазақ тілі таңдалды';

  @override
  String languageSelectedOther(Object lang) {
    return 'Язык выбран: $lang';
  }

  @override
  String get selectRouteTitle => 'Выберите маршрут';

  @override
  String get routeStatusNotApproved => 'Не заполнено';

  @override
  String get routeStatusCurrent => 'Текущий';

  @override
  String get routeStatusApproved => 'Заполнено';

  @override
  String routeDateTimeFormat(Object date, Object time) {
    return 'с $date $time';
  }

  @override
  String get profilePageTitle => 'Мой профиль';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get iin => 'ИИН';

  @override
  String get tabNumber => 'Табельный номер';

  @override
  String get category => 'Категория';

  @override
  String get position => 'Должность';

  @override
  String get brigade => 'Бригада';

  @override
  String get branch => 'Филиал';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Телефон';

  @override
  String get notificationInfo =>
      'На указанный номер телефона и электронный адрес\nВы будете получать уведомления и СМС-коды.';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get edit => 'Изменить';

  @override
  String get close => 'Закрыть';

  @override
  String get operation_success => 'Операция выполнена';

  @override
  String get operation_error => 'Ошибка: операция не выполнена';

  @override
  String get boarding_title => 'Посадка пассажиров';

  @override
  String get preview_title => 'Предпросмотр';

  @override
  String get print => 'Печать';

  @override
  String get printer_not_connected => 'Принтер не подключён';

  @override
  String printer_not_ready(Object status) {
    return 'Принтер не готов: $status';
  }

  @override
  String get sent_to_print => 'Отправлено на печать';

  @override
  String print_error(Object error) {
    return 'Ошибка печати: $error';
  }

  @override
  String get search_hint => 'ИИН или ФИО';

  @override
  String get load_filter_tooltip => 'Загрузить данные по текущему фильтру';

  @override
  String get segment_all => 'Все';

  @override
  String get segment_not_boarded => 'Не посажены';

  @override
  String get segment_boarded => 'Посажены';

  @override
  String get segment_disembarked => 'Высадки';

  @override
  String get dash_placeholder => '—';

  @override
  String get quick_board => 'Посадить';

  @override
  String get no_data_export => 'Нет данных для экспорта';

  @override
  String get data_loaded_success => 'Данные успешно загружены';

  @override
  String get data_loaded_error => 'Ошибка: не удалось загрузить данные';

  @override
  String get filter_label => 'Фильтр';

  @override
  String get filter_tooltip => 'Выбрать фильтр';

  @override
  String wagon_tag(Object wagon) {
    return '# Вагон: №$wagon';
  }

  @override
  String get error => 'Ошибка';

  @override
  String get load => 'Загрузить';

  @override
  String station_tag(Object station) {
    return '# Станция: $station';
  }

  @override
  String get boarding_filterPrompt =>
      'Выберите в фильтре параметры для посадки';

  @override
  String boarding_error_message(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get boarding_operation_success => 'Операция выполнена';

  @override
  String get boarding_operation_error => 'Ошибка: операция не выполнена';

  @override
  String get title => 'Выбор данных для загрузки';

  @override
  String get reset_all => 'Сбросить всё';

  @override
  String get recent_requests => 'Недавние запросы';

  @override
  String get history_bullet => '•';

  @override
  String departure_label(Object dep) {
    return 'Отправка $dep';
  }

  @override
  String request_label(Object when) {
    return 'Запрос $when';
  }

  @override
  String get train_section => 'Поезд';

  @override
  String get station => 'Станция';

  @override
  String get cancel => 'Отмена';

  @override
  String get download => 'Загрузить';

  @override
  String get document => 'Документ';

  @override
  String get departure => 'Отправление';

  @override
  String get arrival => 'Прибытие';

  @override
  String get departure_date => 'Дата отправления';

  @override
  String get order_date => 'Дата регистрации';

  @override
  String get order_time => 'Время регистрации';

  @override
  String get terminal => 'Терминал';

  @override
  String get conductor => 'Проводник';

  @override
  String get train_number_label => 'Поезд №';

  @override
  String get wagon_type => 'Тип вагона';

  @override
  String get wagon_number_label => 'Вагон №';

  @override
  String get ticket_price => 'Стоимость электронного \nпроездного документа';

  @override
  String get wish => 'Счастливого пути!';

  @override
  String get company_label => '«КТЖ» «УК» АҚ';

  @override
  String get discount => 'Дисконт';

  @override
  String get full_name => 'ФИО';

  @override
  String get train_bar => 'ПОЕЗД';

  @override
  String get arrival_date => 'Дата прибытия';

  @override
  String get generated => 'Сгенерировано в приложении';

  @override
  String get boarded => 'Посажен';

  @override
  String get not_boarded => 'Не посажен';

  @override
  String hello_name(String commaAndName) {
    return 'Здравствуйте$commaAndName!';
  }

  @override
  String get check_connection => 'Проверить подключение';

  @override
  String get offline_banner =>
      'Нет соединения с интернетом. Доступен оффлайн-режим.';

  @override
  String get offline_mode => 'Офлайн режим';

  @override
  String get offline_mode_active =>
      'Данные сохраняются локально и отправятся при выходе из офлайн-режима';

  @override
  String get choose_action => 'Выберите действие';

  @override
  String get services_title => 'Сервисы по вагону';

  @override
  String get services_subtitle => 'Приемка вагона, ЛУ-72, ВУ-8';

  @override
  String get working_title => 'Нормы часов и графики';

  @override
  String get reporting_title => 'Время явки';

  @override
  String get boarding_card_title => 'Посадка пассажиров';

  @override
  String get faceid_card_title => 'Информация прохождения Face ID';

  @override
  String get boarding_card_subtitle => 'Ведомость, талоны, операции';

  @override
  String get payment_title => 'Прием оплаты';

  @override
  String get payment_subtitle => 'Билеты и другие услуги';

  @override
  String get wagon_number_label_alt => 'Номер вагона:';

  @override
  String get status_label => 'Статус';

  @override
  String get seat => 'Место';

  @override
  String get route_not_started => 'Рейс не начат';

  @override
  String get route_started => 'Старт рейса';

  @override
  String get appName => 'passflow';

  @override
  String get appDescription =>
      'Мобильное приложение для проводников пассажирских поездов, созданное для упрощения рабочих процессов, повышения эффективности и улучшения качества обслуживания пассажиров.';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get terminalInfo => 'Информация о терминале';

  @override
  String get terminal_title => 'Об Терминале';

  @override
  String get show_full => 'Показать полностью';

  @override
  String get hide => 'Скрыть';

  @override
  String get info_section => 'Информация';

  @override
  String get ios_no_imei_title => 'iOS не предоставляет IMEI';

  @override
  String get ios_no_imei_subtitle =>
      'На устройствах Apple IMEI недоступен для сторонних приложений.';

  @override
  String get error_section => 'Ошибка обновления';

  @override
  String get error_update_failed => 'Не удалось обновить данные';

  @override
  String get error_update_retry =>
      'Попробуйте ещё раз. Если повторится — проверьте разрешения.';

  @override
  String get denied_section => 'Доступ к данным телефона';

  @override
  String get denied_no_access_title => 'Нет доступа к телефонным данным';

  @override
  String get denied_no_access_subtitle =>
      'Разрешите «Телефон» для показа IMEI.';

  @override
  String get denied_allow_access => 'Разрешить доступ';

  @override
  String get denied_open_settings => 'Открыть настройки';

  @override
  String get imei_unavailable_section => 'IMEI недоступен';

  @override
  String get imei_device_section => 'IMEI устройства';

  @override
  String imei_label(int index) {
    return 'IMEI $index';
  }

  @override
  String get alt_id => 'Альтернативный ID';

  @override
  String get alt_id_device => 'Альтернативный ID устройства';

  @override
  String get tooltip_copy => 'Копировать';

  @override
  String get copied_imei => 'IMEI скопирован';

  @override
  String get copied_id => 'ID скопирован';

  @override
  String get note_android10 =>
      'Примечание: на Android 10+ система может не возвращать IMEI';

  @override
  String get payment_accept => 'Прием оплаты';

  @override
  String get payment_history => 'История оплаты (2)';

  @override
  String get service_for_payment => 'Услуга для оплаты';

  @override
  String get payment_amount => 'Сумма оплаты';

  @override
  String get choose_bank => 'Выбрать банк';

  @override
  String get generate_qr_start_payment => 'Сгенерировать QR / Начать оплату';

  @override
  String get history_payment_item => 'Оплата услуги • 5 000 ₸';

  @override
  String get status_success => 'Успешно';

  @override
  String get status_cancel => 'Отмена';

  @override
  String get choose_service => 'Выберите услугу';

  @override
  String get service_tea_coffee => 'Чай / кофе';

  @override
  String get service_bedding => 'Постельное бельё';

  @override
  String get service_extra_baggage => 'Доп. багаж';

  @override
  String get service_other => 'Другое';

  @override
  String get enter_amount_hint => 'Введите сумму, ₸';

  @override
  String get bank_kaspi => 'Kaspi';

  @override
  String get bank_jusan => 'Jusan';

  @override
  String get bank_halyk => 'Halyk';

  @override
  String get bank_forte => 'Forte';

  @override
  String payment_started(String service, String amount, String bank) {
    return 'Начата оплата: $service • $amount ₸ • $bank';
  }

  @override
  String get clear => 'Очистить';

  @override
  String today_time(Object time) {
    return 'сегодня $time';
  }

  @override
  String yesterday_time(Object time) {
    return 'вчера $time';
  }

  @override
  String get share => 'Поделиться';

  @override
  String get gender_male_short => 'муж';

  @override
  String get gender_female_short => 'жен';
}
