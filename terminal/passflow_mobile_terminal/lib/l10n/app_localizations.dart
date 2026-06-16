import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru'),
    Locale('kk')
  ];

  /// No description provided for @light.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get light;

  /// No description provided for @menu.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get menu;

  /// No description provided for @my_profile.
  ///
  /// In ru, this message translates to:
  /// **'Мой профиль'**
  String get my_profile;

  /// No description provided for @route_change.
  ///
  /// In ru, this message translates to:
  /// **'Изменение в маршруте'**
  String get route_change;

  /// No description provided for @choose_route.
  ///
  /// In ru, this message translates to:
  /// **'Перевыбрать маршрут'**
  String get choose_route;

  /// No description provided for @settings_notifications.
  ///
  /// In ru, this message translates to:
  /// **'Настройки и уведомления'**
  String get settings_notifications;

  /// No description provided for @terminalSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки терминала'**
  String get terminalSettings;

  /// No description provided for @help_support.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и поддержка'**
  String get help_support;

  /// No description provided for @knowledge_base.
  ///
  /// In ru, this message translates to:
  /// **'База знаний'**
  String get knowledge_base;

  /// No description provided for @report_error.
  ///
  /// In ru, this message translates to:
  /// **'Сообщить об ошибке'**
  String get report_error;

  /// No description provided for @tech_support.
  ///
  /// In ru, this message translates to:
  /// **'Тех. поддержка приложения'**
  String get tech_support;

  /// No description provided for @user_name.
  ///
  /// In ru, this message translates to:
  /// **'Имя пользователя'**
  String get user_name;

  /// No description provided for @terminalSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки терминала'**
  String get terminalSettingsTitle;

  /// No description provided for @appLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get appLanguage;

  /// No description provided for @themeInterface.
  ///
  /// In ru, this message translates to:
  /// **'Тема интерфейса'**
  String get themeInterface;

  /// No description provided for @aboutAppTerminal.
  ///
  /// In ru, this message translates to:
  /// **'О приложении и терминале'**
  String get aboutAppTerminal;

  /// No description provided for @appVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия приложения: {version}'**
  String appVersion(Object version);

  /// No description provided for @logoutApp.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из приложения'**
  String get logoutApp;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из приложения?'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно хотите выйти из приложения? Сессия будет завершена.'**
  String get logoutDialogMessage;

  /// No description provided for @confirmLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get confirmLogout;

  /// No description provided for @chooseLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите язык'**
  String get chooseLanguage;

  /// No description provided for @lang_ru.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get lang_ru;

  /// No description provided for @lang_kk.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get lang_kk;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @dark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get dark;

  /// No description provided for @about_app.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about_app;

  /// No description provided for @selectLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите язык приложения'**
  String get selectLanguage;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get version;

  /// No description provided for @exit.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get exit;

  /// No description provided for @home.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home;

  /// No description provided for @payment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get payment;

  /// No description provided for @services.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы'**
  String get services;

  /// No description provided for @boarding.
  ///
  /// In ru, this message translates to:
  /// **'Посадка'**
  String get boarding;

  /// No description provided for @train_number.
  ///
  /// In ru, this message translates to:
  /// **'Номер поезда'**
  String get train_number;

  /// No description provided for @wagon_number.
  ///
  /// In ru, this message translates to:
  /// **'Номер вагона'**
  String get wagon_number;

  /// No description provided for @departure_time.
  ///
  /// In ru, this message translates to:
  /// **'Время отправления'**
  String get departure_time;

  /// No description provided for @arrival_time.
  ///
  /// In ru, this message translates to:
  /// **'Время прибытия'**
  String get arrival_time;

  /// No description provided for @no_trains.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных по поездам'**
  String get no_trains;

  /// No description provided for @no_stations.
  ///
  /// In ru, this message translates to:
  /// **'Нет станций в данных'**
  String get no_stations;

  /// No description provided for @choose.
  ///
  /// In ru, this message translates to:
  /// **'Выберите'**
  String get choose;

  /// No description provided for @ticket_status.
  ///
  /// In ru, this message translates to:
  /// **'Статус билета'**
  String get ticket_status;

  /// No description provided for @boarding_pass.
  ///
  /// In ru, this message translates to:
  /// **'Посадочный талон'**
  String get boarding_pass;

  /// No description provided for @cancel_ticket.
  ///
  /// In ru, this message translates to:
  /// **'Отменить билет'**
  String get cancel_ticket;

  /// No description provided for @confirm_ticket.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить билет'**
  String get confirm_ticket;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @profile_settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки профиля'**
  String get profile_settings;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @help.
  ///
  /// In ru, this message translates to:
  /// **'Помощь'**
  String get help;

  /// No description provided for @support.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get support;

  /// No description provided for @taskRouteAppBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Маршруты'**
  String get taskRouteAppBarTitle;

  /// No description provided for @languageSelectedRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский язык выбран'**
  String get languageSelectedRussian;

  /// No description provided for @languageSelectedKazakh.
  ///
  /// In ru, this message translates to:
  /// **'Қазақ тілі таңдалды'**
  String get languageSelectedKazakh;

  /// No description provided for @languageSelectedOther.
  ///
  /// In ru, this message translates to:
  /// **'Язык выбран: {lang}'**
  String languageSelectedOther(Object lang);

  /// No description provided for @selectRouteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите маршрут'**
  String get selectRouteTitle;

  /// No description provided for @routeStatusNotApproved.
  ///
  /// In ru, this message translates to:
  /// **'Не заполнено'**
  String get routeStatusNotApproved;

  /// No description provided for @routeStatusCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Текущий'**
  String get routeStatusCurrent;

  /// No description provided for @routeStatusApproved.
  ///
  /// In ru, this message translates to:
  /// **'Заполнено'**
  String get routeStatusApproved;

  /// No description provided for @routeDateTimeFormat.
  ///
  /// In ru, this message translates to:
  /// **'с {date} {time}'**
  String routeDateTimeFormat(Object date, Object time);

  /// No description provided for @profilePageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мой профиль'**
  String get profilePageTitle;

  /// No description provided for @changePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Изменить фото'**
  String get changePhoto;

  /// No description provided for @iin.
  ///
  /// In ru, this message translates to:
  /// **'ИИН'**
  String get iin;

  /// No description provided for @tabNumber.
  ///
  /// In ru, this message translates to:
  /// **'Табельный номер'**
  String get tabNumber;

  /// No description provided for @category.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get category;

  /// No description provided for @position.
  ///
  /// In ru, this message translates to:
  /// **'Должность'**
  String get position;

  /// No description provided for @brigade.
  ///
  /// In ru, this message translates to:
  /// **'Бригада'**
  String get brigade;

  /// No description provided for @branch.
  ///
  /// In ru, this message translates to:
  /// **'Филиал'**
  String get branch;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// No description provided for @notificationInfo.
  ///
  /// In ru, this message translates to:
  /// **'На указанный номер телефона и электронный адрес\nВы будете получать уведомления и СМС-коды.'**
  String get notificationInfo;

  /// No description provided for @copy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @operation_success.
  ///
  /// In ru, this message translates to:
  /// **'Операция выполнена'**
  String get operation_success;

  /// No description provided for @operation_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: операция не выполнена'**
  String get operation_error;

  /// No description provided for @boarding_title.
  ///
  /// In ru, this message translates to:
  /// **'Посадка пассажиров'**
  String get boarding_title;

  /// No description provided for @preview_title.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр'**
  String get preview_title;

  /// No description provided for @print.
  ///
  /// In ru, this message translates to:
  /// **'Печать'**
  String get print;

  /// No description provided for @printer_not_connected.
  ///
  /// In ru, this message translates to:
  /// **'Принтер не подключён'**
  String get printer_not_connected;

  /// No description provided for @printer_not_ready.
  ///
  /// In ru, this message translates to:
  /// **'Принтер не готов: {status}'**
  String printer_not_ready(Object status);

  /// No description provided for @sent_to_print.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено на печать'**
  String get sent_to_print;

  /// No description provided for @print_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка печати: {error}'**
  String print_error(Object error);

  /// No description provided for @search_hint.
  ///
  /// In ru, this message translates to:
  /// **'ИИН или ФИО'**
  String get search_hint;

  /// No description provided for @load_filter_tooltip.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить данные по текущему фильтру'**
  String get load_filter_tooltip;

  /// No description provided for @segment_all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get segment_all;

  /// No description provided for @segment_not_boarded.
  ///
  /// In ru, this message translates to:
  /// **'Не посажены'**
  String get segment_not_boarded;

  /// No description provided for @segment_boarded.
  ///
  /// In ru, this message translates to:
  /// **'Посажены'**
  String get segment_boarded;

  /// No description provided for @segment_disembarked.
  ///
  /// In ru, this message translates to:
  /// **'Высадки'**
  String get segment_disembarked;

  /// No description provided for @dash_placeholder.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get dash_placeholder;

  /// No description provided for @quick_board.
  ///
  /// In ru, this message translates to:
  /// **'Посадить'**
  String get quick_board;

  /// No description provided for @no_data_export.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных для экспорта'**
  String get no_data_export;

  /// No description provided for @data_loaded_success.
  ///
  /// In ru, this message translates to:
  /// **'Данные успешно загружены'**
  String get data_loaded_success;

  /// No description provided for @data_loaded_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: не удалось загрузить данные'**
  String get data_loaded_error;

  /// No description provided for @filter_label.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filter_label;

  /// No description provided for @filter_tooltip.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать фильтр'**
  String get filter_tooltip;

  /// No description provided for @wagon_tag.
  ///
  /// In ru, this message translates to:
  /// **'# Вагон: №{wagon}'**
  String wagon_tag(Object wagon);

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @load.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить'**
  String get load;

  /// No description provided for @station_tag.
  ///
  /// In ru, this message translates to:
  /// **'# Станция: {station}'**
  String station_tag(Object station);

  /// No description provided for @boarding_filterPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Выберите в фильтре параметры для посадки'**
  String get boarding_filterPrompt;

  /// No description provided for @boarding_error_message.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String boarding_error_message(Object error);

  /// No description provided for @boarding_operation_success.
  ///
  /// In ru, this message translates to:
  /// **'Операция выполнена'**
  String get boarding_operation_success;

  /// No description provided for @boarding_operation_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: операция не выполнена'**
  String get boarding_operation_error;

  /// No description provided for @title.
  ///
  /// In ru, this message translates to:
  /// **'Выбор данных для загрузки'**
  String get title;

  /// No description provided for @reset_all.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить всё'**
  String get reset_all;

  /// No description provided for @recent_requests.
  ///
  /// In ru, this message translates to:
  /// **'Недавние запросы'**
  String get recent_requests;

  /// No description provided for @history_bullet.
  ///
  /// In ru, this message translates to:
  /// **'•'**
  String get history_bullet;

  /// No description provided for @departure_label.
  ///
  /// In ru, this message translates to:
  /// **'Отправка {dep}'**
  String departure_label(Object dep);

  /// No description provided for @request_label.
  ///
  /// In ru, this message translates to:
  /// **'Запрос {when}'**
  String request_label(Object when);

  /// No description provided for @train_section.
  ///
  /// In ru, this message translates to:
  /// **'Поезд'**
  String get train_section;

  /// No description provided for @station.
  ///
  /// In ru, this message translates to:
  /// **'Станция'**
  String get station;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @download.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить'**
  String get download;

  /// No description provided for @document.
  ///
  /// In ru, this message translates to:
  /// **'Документ'**
  String get document;

  /// No description provided for @departure.
  ///
  /// In ru, this message translates to:
  /// **'Отправление'**
  String get departure;

  /// No description provided for @arrival.
  ///
  /// In ru, this message translates to:
  /// **'Прибытие'**
  String get arrival;

  /// No description provided for @departure_date.
  ///
  /// In ru, this message translates to:
  /// **'Дата отправления'**
  String get departure_date;

  /// No description provided for @order_date.
  ///
  /// In ru, this message translates to:
  /// **'Дата регистрации'**
  String get order_date;

  /// No description provided for @order_time.
  ///
  /// In ru, this message translates to:
  /// **'Время регистрации'**
  String get order_time;

  /// No description provided for @terminal.
  ///
  /// In ru, this message translates to:
  /// **'Терминал'**
  String get terminal;

  /// No description provided for @conductor.
  ///
  /// In ru, this message translates to:
  /// **'Проводник'**
  String get conductor;

  /// No description provided for @train_number_label.
  ///
  /// In ru, this message translates to:
  /// **'Поезд №'**
  String get train_number_label;

  /// No description provided for @wagon_type.
  ///
  /// In ru, this message translates to:
  /// **'Тип вагона'**
  String get wagon_type;

  /// No description provided for @wagon_number_label.
  ///
  /// In ru, this message translates to:
  /// **'Вагон №'**
  String get wagon_number_label;

  /// No description provided for @ticket_price.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость электронного \nпроездного документа'**
  String get ticket_price;

  /// No description provided for @wish.
  ///
  /// In ru, this message translates to:
  /// **'Счастливого пути!'**
  String get wish;

  /// No description provided for @company_label.
  ///
  /// In ru, this message translates to:
  /// **'«КТЖ» «УК» АҚ'**
  String get company_label;

  /// No description provided for @discount.
  ///
  /// In ru, this message translates to:
  /// **'Дисконт'**
  String get discount;

  /// No description provided for @full_name.
  ///
  /// In ru, this message translates to:
  /// **'ФИО'**
  String get full_name;

  /// No description provided for @train_bar.
  ///
  /// In ru, this message translates to:
  /// **'ПОЕЗД'**
  String get train_bar;

  /// No description provided for @arrival_date.
  ///
  /// In ru, this message translates to:
  /// **'Дата прибытия'**
  String get arrival_date;

  /// No description provided for @generated.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировано в приложении'**
  String get generated;

  /// No description provided for @boarded.
  ///
  /// In ru, this message translates to:
  /// **'Посажен'**
  String get boarded;

  /// No description provided for @not_boarded.
  ///
  /// In ru, this message translates to:
  /// **'Не посажен'**
  String get not_boarded;

  /// Приветствие в шапке. {commaAndName} — либо пусто, либо ", <Имя>"
  ///
  /// In ru, this message translates to:
  /// **'Здравствуйте{commaAndName}!'**
  String hello_name(String commaAndName);

  /// No description provided for @check_connection.
  ///
  /// In ru, this message translates to:
  /// **'Проверить подключение'**
  String get check_connection;

  /// No description provided for @offline_banner.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения с интернетом. Доступен оффлайн-режим.'**
  String get offline_banner;

  /// No description provided for @offline_mode.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн режим'**
  String get offline_mode;

  /// No description provided for @offline_mode_active.
  ///
  /// In ru, this message translates to:
  /// **'Данные сохраняются локально и отправятся при выходе из офлайн-режима'**
  String get offline_mode_active;

  /// No description provided for @choose_action.
  ///
  /// In ru, this message translates to:
  /// **'Выберите действие'**
  String get choose_action;

  /// No description provided for @services_title.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы по вагону'**
  String get services_title;

  /// No description provided for @services_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Приемка вагона, ЛУ-72, ВУ-8'**
  String get services_subtitle;

  /// No description provided for @working_title.
  ///
  /// In ru, this message translates to:
  /// **'Нормы часов и графики'**
  String get working_title;

  /// No description provided for @reporting_title.
  ///
  /// In ru, this message translates to:
  /// **'Время явки'**
  String get reporting_title;

  /// No description provided for @boarding_card_title.
  ///
  /// In ru, this message translates to:
  /// **'Посадка пассажиров'**
  String get boarding_card_title;

  /// No description provided for @faceid_card_title.
  ///
  /// In ru, this message translates to:
  /// **'Информация прохождения Face ID'**
  String get faceid_card_title;

  /// No description provided for @boarding_card_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ведомость, талоны, операции'**
  String get boarding_card_subtitle;

  /// No description provided for @payment_title.
  ///
  /// In ru, this message translates to:
  /// **'Прием оплаты'**
  String get payment_title;

  /// No description provided for @payment_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Билеты и другие услуги'**
  String get payment_subtitle;

  /// No description provided for @wagon_number_label_alt.
  ///
  /// In ru, this message translates to:
  /// **'Номер вагона:'**
  String get wagon_number_label_alt;

  /// No description provided for @status_label.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get status_label;

  /// No description provided for @seat.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get seat;

  /// No description provided for @route_not_started.
  ///
  /// In ru, this message translates to:
  /// **'Рейс не начат'**
  String get route_not_started;

  /// No description provided for @route_started.
  ///
  /// In ru, this message translates to:
  /// **'Старт рейса'**
  String get route_started;

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'passflow'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In ru, this message translates to:
  /// **'Мобильное приложение для проводников пассажирских поездов, созданное для упрощения рабочих процессов, повышения эффективности и улучшения качества обслуживания пассажиров.'**
  String get appDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyPolicy;

  /// No description provided for @terminalInfo.
  ///
  /// In ru, this message translates to:
  /// **'Информация о терминале'**
  String get terminalInfo;

  /// No description provided for @terminal_title.
  ///
  /// In ru, this message translates to:
  /// **'Об Терминале'**
  String get terminal_title;

  /// No description provided for @show_full.
  ///
  /// In ru, this message translates to:
  /// **'Показать полностью'**
  String get show_full;

  /// No description provided for @hide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get hide;

  /// No description provided for @info_section.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get info_section;

  /// No description provided for @ios_no_imei_title.
  ///
  /// In ru, this message translates to:
  /// **'iOS не предоставляет IMEI'**
  String get ios_no_imei_title;

  /// No description provided for @ios_no_imei_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'На устройствах Apple IMEI недоступен для сторонних приложений.'**
  String get ios_no_imei_subtitle;

  /// No description provided for @error_section.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка обновления'**
  String get error_section;

  /// No description provided for @error_update_failed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить данные'**
  String get error_update_failed;

  /// No description provided for @error_update_retry.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте ещё раз. Если повторится — проверьте разрешения.'**
  String get error_update_retry;

  /// No description provided for @denied_section.
  ///
  /// In ru, this message translates to:
  /// **'Доступ к данным телефона'**
  String get denied_section;

  /// No description provided for @denied_no_access_title.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к телефонным данным'**
  String get denied_no_access_title;

  /// No description provided for @denied_no_access_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите «Телефон» для показа IMEI.'**
  String get denied_no_access_subtitle;

  /// No description provided for @denied_allow_access.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить доступ'**
  String get denied_allow_access;

  /// No description provided for @denied_open_settings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get denied_open_settings;

  /// No description provided for @imei_unavailable_section.
  ///
  /// In ru, this message translates to:
  /// **'IMEI недоступен'**
  String get imei_unavailable_section;

  /// No description provided for @imei_device_section.
  ///
  /// In ru, this message translates to:
  /// **'IMEI устройства'**
  String get imei_device_section;

  /// No description provided for @imei_label.
  ///
  /// In ru, this message translates to:
  /// **'IMEI {index}'**
  String imei_label(int index);

  /// No description provided for @alt_id.
  ///
  /// In ru, this message translates to:
  /// **'Альтернативный ID'**
  String get alt_id;

  /// No description provided for @alt_id_device.
  ///
  /// In ru, this message translates to:
  /// **'Альтернативный ID устройства'**
  String get alt_id_device;

  /// No description provided for @tooltip_copy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get tooltip_copy;

  /// No description provided for @copied_imei.
  ///
  /// In ru, this message translates to:
  /// **'IMEI скопирован'**
  String get copied_imei;

  /// No description provided for @copied_id.
  ///
  /// In ru, this message translates to:
  /// **'ID скопирован'**
  String get copied_id;

  /// No description provided for @note_android10.
  ///
  /// In ru, this message translates to:
  /// **'Примечание: на Android 10+ система может не возвращать IMEI'**
  String get note_android10;

  /// No description provided for @payment_accept.
  ///
  /// In ru, this message translates to:
  /// **'Прием оплаты'**
  String get payment_accept;

  /// No description provided for @payment_history.
  ///
  /// In ru, this message translates to:
  /// **'История оплаты (2)'**
  String get payment_history;

  /// No description provided for @service_for_payment.
  ///
  /// In ru, this message translates to:
  /// **'Услуга для оплаты'**
  String get service_for_payment;

  /// No description provided for @payment_amount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма оплаты'**
  String get payment_amount;

  /// No description provided for @choose_bank.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать банк'**
  String get choose_bank;

  /// No description provided for @generate_qr_start_payment.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать QR / Начать оплату'**
  String get generate_qr_start_payment;

  /// No description provided for @history_payment_item.
  ///
  /// In ru, this message translates to:
  /// **'Оплата услуги • 5 000 ₸'**
  String get history_payment_item;

  /// No description provided for @status_success.
  ///
  /// In ru, this message translates to:
  /// **'Успешно'**
  String get status_success;

  /// No description provided for @status_cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get status_cancel;

  /// No description provided for @choose_service.
  ///
  /// In ru, this message translates to:
  /// **'Выберите услугу'**
  String get choose_service;

  /// No description provided for @service_tea_coffee.
  ///
  /// In ru, this message translates to:
  /// **'Чай / кофе'**
  String get service_tea_coffee;

  /// No description provided for @service_bedding.
  ///
  /// In ru, this message translates to:
  /// **'Постельное бельё'**
  String get service_bedding;

  /// No description provided for @service_extra_baggage.
  ///
  /// In ru, this message translates to:
  /// **'Доп. багаж'**
  String get service_extra_baggage;

  /// No description provided for @service_other.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get service_other;

  /// No description provided for @enter_amount_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введите сумму, ₸'**
  String get enter_amount_hint;

  /// No description provided for @bank_kaspi.
  ///
  /// In ru, this message translates to:
  /// **'Kaspi'**
  String get bank_kaspi;

  /// No description provided for @bank_jusan.
  ///
  /// In ru, this message translates to:
  /// **'Jusan'**
  String get bank_jusan;

  /// No description provided for @bank_halyk.
  ///
  /// In ru, this message translates to:
  /// **'Halyk'**
  String get bank_halyk;

  /// No description provided for @bank_forte.
  ///
  /// In ru, this message translates to:
  /// **'Forte'**
  String get bank_forte;

  /// No description provided for @payment_started.
  ///
  /// In ru, this message translates to:
  /// **'Начата оплата: {service} • {amount} ₸ • {bank}'**
  String payment_started(String service, String amount, String bank);

  /// No description provided for @clear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear;

  /// No description provided for @today_time.
  ///
  /// In ru, this message translates to:
  /// **'сегодня {time}'**
  String today_time(Object time);

  /// No description provided for @yesterday_time.
  ///
  /// In ru, this message translates to:
  /// **'вчера {time}'**
  String yesterday_time(Object time);

  /// No description provided for @share.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get share;

  /// No description provided for @gender_male_short.
  ///
  /// In ru, this message translates to:
  /// **'муж'**
  String get gender_male_short;

  /// No description provided for @gender_female_short.
  ///
  /// In ru, this message translates to:
  /// **'жен'**
  String get gender_female_short;
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
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
