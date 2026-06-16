// lib/pages/boardings_list/bloc/list_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';
import 'package:passflow_app/data/models/boarding_model.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/data/models/tickets_search_entry_model.dart';
import 'package:passflow_app/data/models/train_direction_model.dart';
import 'package:passflow_app/data/models/train_directions_response.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/data/repositories/tickets_repository.dart';
import 'package:passflow_app/data/repositories/train_direction_repository.dart';
import 'package:passflow_app/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_event.dart';
import 'list_state.dart';

/// Внутреннее событие: бокс `tickets` изменился
class _TicketsBoxUpdated extends BoardingsListEvent {
  final List<TicketModel> tickets;
  const _TicketsBoxUpdated(this.tickets);
}

class BoardingsListBloc extends Bloc<BoardingsListEvent, BoardingsState> {
  final TicketsRepository repository = sl<TicketsRepository>();
  final StationsRepo stationsRepository = sl<StationsRepo>();
  final TrainDirectionsRepository trainDirectionsRepository =
      sl<TrainDirectionsRepository>();

  // Hive боксы
  final ticketsBox = Hive.box<TicketModel>('tickets');
  final routeSheetBox = Hive.box<RouteSheetModel>('routeSheets');
  final userBox = Hive.box<UserModel>('userBox');

  // Новые боксы: история и кеш
  final historyBox =
      Hive.box<TicketSearchEntryModel>('search_history'); // key -> entry
  final cacheBox = Hive.box('tickets_cache'); // key -> List<TicketModel>

  StreamSubscription? _ticketsSub;
  String? _currentCacheKey;

  BoardingsListBloc() : super(const BoardingsListState()) {
    // Подписка на Hive-бокс с билетами
    on<WatchTicketsEvent>(_onWatchTickets);
    on<_TicketsBoxUpdated>(_onTicketsBoxUpdated);

    // Операции бэка
    on<RegisterBoardingEvent>(_onRegisterBoarding);
    on<CancelBoardingEvent>(_onCancelBoarding);
    on<DenyBoardingEvent>(_onDenyBoarding);

    // Сброс уведомления
    on<ClearBoardingSuccessEvent>(_onClearBoardingSuccess);

    // Поиск/загрузка (онлайн/офлайн + история)
    on<LoadTicketsByFilterEvent>(_onLoadTickets);

    // Инициализация
    on<InitTicketsEvent>(_onInitTickets);

    // История
    on<LoadSearchHistoryEvent>(_onLoadSearchHistory);
    on<SelectHistoryEntryEvent>(_onSelectHistoryEntry);

    // Legacy redirect
    on<LoadTicketsEvent>(_onLoadTicketsRedirect);
    on<ClearErrorEvent>((event, emit) {
      if (state is! BoardingsListState) return;
      final s = state as BoardingsListState;
      emit(s.copyWith(clearError: true));
    });
  }

  // ---------------- Хелперы истории/кеша ----------------

  List<TicketSearchEntryModel> _readHistory() {
    final list = historyBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _saveHistoryAndCache({
    required String trainStr,
    required String stationName,
    required String departureStr,
    required String? stationCode,
    required List<TicketModel> tickets,
  }) async {
    final key = TicketSearchEntryModel.buildKey(
      train: trainStr,
      station: stationName,
      departure: departureStr,
      startStationCode: stationCode ?? '',
    );

    // put по ключу = автоматическая дедупликация
    final entry = TicketSearchEntryModel(
      train: trainStr,
      station: stationName,
      departure: departureStr,
      startStationCode: stationCode ?? '',
      createdAt: DateTime.now(),
      key: key,
    );

    await historyBox.put(key, entry);
    await cacheBox.put(key, tickets);
  }

  List<TicketModel>? _readTicketsFromCache(String? key) {
    if (key == null || !cacheBox.containsKey(key)) return null;
    final raw = cacheBox.get(key);
    if (raw is! List) return null;
    return raw.cast<TicketModel>();
  }

  Future<List<TicketModel>> _restoreCachedTickets({String? preferredKey}) async {
    final key = preferredKey ??
        _currentCacheKey ??
        (_readHistory().isNotEmpty ? _readHistory().first.key : null);
    final cached = _readTicketsFromCache(key);
    if (cached == null || cached.isEmpty) {
      return ticketsBox.values.toList(growable: false);
    }

    _currentCacheKey = key;
    final merged = _mergeWithLocal(cached);
    await ticketsBox.clear();
    await ticketsBox.putAll({for (final e in merged) e.orderNumber: e});
    return merged;
  }

  Future<List<TicketModel>> _restoreBestCachedTickets() async {
    final history = _readHistory();
    for (final entry in history) {
      final cached = _readTicketsFromCache(entry.key);
      if (cached != null && cached.isNotEmpty) {
        return _restoreCachedTickets(preferredKey: entry.key);
      }
    }
    if (history.isNotEmpty) {
      return _restoreCachedTickets(preferredKey: history.first.key);
    }
    return ticketsBox.values.toList(growable: false);
  }

  Future<int> _resolveFilialId() async {
    final currentUser = userBox.get('currentUser');
    final fromUser = currentUser?.filialId;
    if (fromUser != null && fromUser > 0) return fromUser;

    final directionsBox =
        Hive.box<TrainDirectionsResponse>('train_directions');
    for (final key in directionsBox.keys) {
      if (key is int && key > 0) return key;
    }

    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getInt('last_filial_id');
    if (fromPrefs != null && fromPrefs > 0) return fromPrefs;

    return 0;
  }

  Future<void> _syncCurrentCache(List<TicketModel> tickets) async {
    if (_currentCacheKey == null || tickets.isEmpty) return;
    await cacheBox.put(_currentCacheKey, tickets);
  }

  Future<void> _ensureTicketsWatch() async {
    if (_ticketsSub != null) return;
    _ticketsSub = ticketsBox.watch().listen((_) {
      final current = ticketsBox.values.toList(growable: false);
      add(_TicketsBoxUpdated(current));
    });
  }

  Future<TicketModel?> _fetchSavedTicketIfOnline(String orderNumber) async {
    if (!await NetworkUtils.isNetworkAvailable()) return null;
    try {
      return await repository.searchTicketsByOrderNumber(orderNumber);
    } catch (_) {
      return null;
    }
  }

  /// Сливает входящие билеты с локальными (из ticketsBox),
  /// чтобы сохранить boardingPassed/isSendToServer и прочие локальные флаги.
  List<TicketModel> _mergeWithLocal(List<TicketModel> incoming) {
    final merged = <TicketModel>[];
    for (final t in incoming) {
      final local = ticketsBox.get(t.orderNumber);
      if (local != null) {
        merged.add(
          t.copyWith(
            boardingPassed: local.boardingPassed,
            isSendToServer: local.isSendToServer,
          ),
        );
      } else {
        merged.add(t);
      }
    }
    return merged;
  }

  // ---------------- Init ----------------

  Future<void> _onInitTickets(
    InitTicketsEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;

    emit(s.copyWith(isLoading: true, error: null));
    try {
      final filialId = await _resolveFilialId();
      final trainDirections =
          await trainDirectionsRepository.searchByFilial(filialId: filialId);

      final history = _readHistory();
      var tickets = ticketsBox.values.toList(growable: false);

      if (tickets.isEmpty) {
        tickets = await _restoreBestCachedTickets();
      } else if (history.isNotEmpty) {
        _currentCacheKey ??= history.first.key;
      }

      await _ensureTicketsWatch();

      final directions = trainDirections?.result;
      final hasDirections = directions != null && directions.isNotEmpty;
      final hasTickets = tickets.isNotEmpty;
      final hasHistory = history.isNotEmpty;

      String? error;
      if (!hasTickets && !hasDirections && !hasHistory) {
        error = 'Нет данных по направлениям';
      }

      emit(s.copyWith(
        isLoading: false,
        trainDirections: directions,
        history: history,
        tickets: tickets,
        offset: tickets.length,
        hasMore: false,
        error: error,
      ));
    } catch (e) {
      final restored = await _restoreBestCachedTickets();
      final directions =
          (await trainDirectionsRepository.searchByFilial(filialId: await _resolveFilialId()))
              ?.result;
      emit(s.copyWith(
        isLoading: false,
        trainDirections: directions,
        tickets: restored,
        offset: restored.length,
        hasMore: false,
        history: _readHistory(),
        error: restored.isEmpty && (directions == null || directions.isEmpty)
            ? e.toString()
            : null,
      ));
    }
  }

  // -------------- Watch tickets box --------------

  Future<void> _onWatchTickets(
    WatchTicketsEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;

    emit(s.copyWith(isLoading: true));
    // await HiveService.preloadTicketsSoft(clearBefore: true);

    // Первичная выдача
    final initial = ticketsBox.values.toList(growable: false);
    emit(s.copyWith(
      tickets: initial,
      isLoading: false,
      offset: initial.length,
      hasMore: false,
      error: null,
    ));

    // Подписка на изменения бокса
    await _ticketsSub?.cancel();
    _ticketsSub = ticketsBox.watch().listen((_) {
      final current = ticketsBox.values.toList(growable: false);
      add(_TicketsBoxUpdated(current));
    });
  }

  void _onTicketsBoxUpdated(
    _TicketsBoxUpdated event,
    Emitter<BoardingsState> emit,
  ) {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;

    emit(s.copyWith(
      tickets: event.tickets,
      offset: event.tickets.length,
      hasMore: false,
      isLoading: false,
      // boardingSuccess оставляем как есть
    ));
    unawaited(_syncCurrentCache(event.tickets));
  }

  // -------------- Backend ops (оптимистично) --------------

  Future<void> _onRegisterBoarding(
    RegisterBoardingEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final cur = state as BoardingsListState;

    try {
      final hasNet = await NetworkUtils.isNetworkAvailable();
      final boardingResult = await repository.registerBoarding(event.model);
      final savedModel =
          await _fetchSavedTicketIfOnline(event.model.orderNumber);
      final t0 = ticketsBox.get(event.model.orderNumber);

      if (boardingResult.success) {
        if (t0 != null) {
          final base = savedModel ?? t0;
          await ticketsBox.put(
            event.model.orderNumber,
            base.copyWith(boardingPassed: true, isSendToServer: hasNet),
          );
        }

        final refused1 = Set<String>.from(cur.refusedTicketIds)
          ..remove(event.model.orderNumber);
        final disemb1 = Set<String>.from(cur.disembarkedTicketIds)
          ..remove(event.model.orderNumber);

        emit(cur.copyWith(
          boardingSuccess: true,
          clearBoardingMessage: true,
          refusedTicketIds: refused1,
          disembarkedTicketIds: disemb1,
          tickets: ticketsBox.values.toList(),
        ));
      } else {
        emit(cur.copyWith(
          boardingSuccess: false,
          boardingMessage: boardingResult.message,
          tickets: ticketsBox.values.toList(),
        ));
      }
    } catch (e) {
      final curErr = state as BoardingsListState;
      emit(curErr.copyWith(
        boardingSuccess: false,
        boardingMessage: e.toString(),
        tickets: ticketsBox.values.toList(),
      ));
    }
  }

  Future<void> _onCancelBoarding(
    CancelBoardingEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final cur = state as BoardingsListState;

    try {
      final hasNet = await NetworkUtils.isNetworkAvailable();
      final boardingResult = await repository.cancelBoarding(event.model);
      final savedModel =
          await _fetchSavedTicketIfOnline(event.model.orderNumber);
      final t0 = ticketsBox.get(event.model.orderNumber);

      if (boardingResult.success) {
        if (t0 != null) {
          final base = savedModel ?? t0;
          await ticketsBox.put(
            event.model.orderNumber,
            base.copyWith(boardingPassed: false, isSendToServer: hasNet),
          );
        }

        final disemb1 = Set<String>.from(cur.disembarkedTicketIds)
          ..add(event.model.orderNumber);
        final refused1 = Set<String>.from(cur.refusedTicketIds)
          ..remove(event.model.orderNumber);

        emit(cur.copyWith(
          boardingSuccess: true,
          clearBoardingMessage: true,
          disembarkedTicketIds: disemb1,
          refusedTicketIds: refused1,
          tickets: ticketsBox.values.toList(),
        ));
      } else {
        emit(cur.copyWith(
          boardingSuccess: false,
          boardingMessage: boardingResult.message,
          tickets: ticketsBox.values.toList(),
        ));
      }
    } catch (e) {
      final curErr = state as BoardingsListState;
      emit(curErr.copyWith(
        boardingSuccess: false,
        boardingMessage: e.toString(),
        tickets: ticketsBox.values.toList(),
      ));
    }
  }

  Future<void> _onDenyBoarding(
    DenyBoardingEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final cur = state as BoardingsListState;

    try {
      final hasNet = await NetworkUtils.isNetworkAvailable();
      final boardingResult = await repository.denyBoarding(event.model);
      final savedModel =
          await _fetchSavedTicketIfOnline(event.model.orderNumber);
      final t0 = ticketsBox.get(event.model.orderNumber);

      if (boardingResult.success) {
        if (t0 != null) {
          final base = savedModel ?? t0;
          await ticketsBox.put(
            event.model.orderNumber,
            base.copyWith(boardingPassed: false, isSendToServer: hasNet),
          );
        }

        final refused1 = Set<String>.from(cur.refusedTicketIds)
          ..add(event.model.orderNumber);
        final disemb1 = Set<String>.from(cur.disembarkedTicketIds)
          ..remove(event.model.orderNumber);

        emit(cur.copyWith(
          boardingSuccess: true,
          clearBoardingMessage: true,
          refusedTicketIds: refused1,
          disembarkedTicketIds: disemb1,
          tickets: ticketsBox.values.toList(),
        ));
      } else {
        emit(cur.copyWith(
          boardingSuccess: false,
          boardingMessage: boardingResult.message,
          tickets: ticketsBox.values.toList(),
        ));
      }
    } catch (e) {
      final curErr = state as BoardingsListState;
      emit(curErr.copyWith(
        boardingSuccess: false,
        boardingMessage: e.toString(),
        tickets: ticketsBox.values.toList(),
      ));
    }
  }

  void _onClearBoardingSuccess(
    ClearBoardingSuccessEvent event,
    Emitter<BoardingsState> emit,
  ) {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;
    emit(s.copyWith(boardingSuccess: null, clearBoardingMessage: true));
  }

  // -------------- Legacy redirect --------------

  Future<void> _onLoadTicketsRedirect(
    LoadTicketsEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    add(WatchTicketsEvent());
  }

  // -------------- Поиск/загрузка с историей и офлайн --------------

  Future<void> _onLoadTickets(
    LoadTicketsByFilterEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;

    emit(s.copyWith(isLoading: true, error: null));

    // Быстрая загрузка по ключу истории — берём кеш и СЛИВАЕМ с локальными флагами
    if (event.historyKey != null && cacheBox.containsKey(event.historyKey)) {
      _currentCacheKey = event.historyKey;
      final savedTickets = _readTicketsFromCache(event.historyKey) ?? const [];

      final merged = _mergeWithLocal(savedTickets);

      await ticketsBox.clear();
      await ticketsBox.putAll({for (final e in merged) e.orderNumber: e});
      await _syncCurrentCache(merged);

      emit(s.copyWith(
        tickets: merged,
        offset: merged.length,
        hasMore: false,
        isLoading: false,
        error: null,
        history: _readHistory(),
      ));
      return;
    }

    try {
      final trainNumber = event.searchModel['trainAsuName'] ?? '';
      String? stationCode = event.searchModel['stationCode'] as String?;
      final stationName = (event.searchModel['stationName'] ?? '') as String;
      if (stationCode == null || stationCode.isEmpty) {
        stationCode =
            Hive.box<String>('station_codes').get(stationName.trim().toLowerCase());
      }
      final hasNet = await NetworkUtils.isNetworkAvailable();
      if ((stationCode == null || stationCode.isEmpty) && hasNet) {
        stationCode =
            await stationsRepository.searchSspdStationCode(stationName);
      }
      final selectedDate = event.searchModel['date'] as DateTime?;

      final departureStr = selectedDate != null
          ? DateFormat('dd.MM.yyyy').format(selectedDate)
          : DateFormat('dd.MM.yyyy').format(DateTime.now());

      final departureDateStr = selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Модель запроса к бэку
      final searchModel = TicketsSearchModel(
        train: trainNumber, // код поезда, 829А и т.п.
        departure: departureStr,
        startStationCode: stationCode,
        departureDate: departureDateStr,
      );

      // Ключ кеша/истории
      final key = TicketSearchEntryModel.buildKey(
        train: trainNumber,
        station: stationName,
        departure: departureStr,
        startStationCode: stationCode ?? '',
      );
      _currentCacheKey = key;

      List<TicketModel> result = const [];

      if (hasNet) {
        try {
          final online = await repository.searchTicketsSSPD(searchModel) ??
              const <TicketModel>[];
          result = online;

          // Сливаем с локальными флагами для отображения
          final merged = _mergeWithLocal(result);

          // Обновим основной бокс (UI читает отсюда)
          await ticketsBox.clear();
          if (merged.isNotEmpty) {
            await ticketsBox.putAll({
              for (final e in merged) e.orderNumber: e,
            });
          }

          // Сохраним историю + кеш (с учётом локальных флагов посадки)
          await _saveHistoryAndCache(
            trainStr: trainNumber,
            stationName: event.searchModel['stationName'],
            departureStr: departureStr,
            stationCode: stationCode,
            tickets: merged,
          );

          // Обновим состояние (включая историю)
          emit(s.copyWith(
            tickets: merged,
            offset: merged.length,
            hasMore: false,
            isLoading: false,
            error: null,
            clearError: true,
            history: _readHistory(),
          ));
          return;
        } catch (e) {
          // Падение онлайна — фолбек на кеш
          final cached = (cacheBox.get(key) as List?)?.cast<TicketModel>() ??
              const <TicketModel>[];
          if (cached.isEmpty) {
            emit(
              s.copyWith(
                isLoading: false,
                error: (e is Exception)
                    ? '${e.toString()}\n'
                    : 'Нет сохранённых данных по этому фильтру',
                history: _readHistory(),
              ),
            );
            return;
          }
          final merged = _mergeWithLocal(cached);
          await ticketsBox.clear();
          await ticketsBox.putAll({
            for (final e in merged) e.orderNumber: e,
          });

          emit(s.copyWith(
            tickets: merged,
            offset: merged.length,
            hasMore: false,
            isLoading: false,
            error: e.toString(),
            history: _readHistory(),
          ));
          return;
        }
      } else {
        // Сразу офлайн
        final cached = (cacheBox.get(key) as List?)?.cast<TicketModel>() ??
            const <TicketModel>[];
        if (cached.isEmpty) {
          emit(s.copyWith(
            isLoading: false,
            error: 'Нет сохранённых данных по этому фильтру',
            history: _readHistory(),
          ));
          return;
        }
        final merged = _mergeWithLocal(cached);
        await ticketsBox.clear();
        await ticketsBox.putAll({
          for (final e in merged) e.orderNumber: e,
        });

        emit(s.copyWith(
          tickets: merged,
          offset: merged.length,
          hasMore: false,
          isLoading: false,
          error: null,
          history: _readHistory(),
        ));
        return;
      }
    } catch (e) {
      emit(s.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // -------------- История: загрузка и выбор офлайн --------------

  Future<void> _onLoadSearchHistory(
    LoadSearchHistoryEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;
    emit(s.copyWith(history: _readHistory()));
  }

  Future<void> _onSelectHistoryEntry(
    SelectHistoryEntryEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;
    final s = state as BoardingsListState;

    _currentCacheKey = event.entry.key;
    final cached = _readTicketsFromCache(event.entry.key) ?? const <TicketModel>[];
    if (cached.isEmpty) {
      emit(s.copyWith(
        tickets: const [],
        offset: 0,
        hasMore: false,
        isLoading: false,
        error: 'Нет сохранённых данных по этому запросу',
        history: _readHistory(),
      ));
      return;
    }

    final merged = _mergeWithLocal(cached);

    // Переливаем в ticketsBox для единого источника правды
    await ticketsBox.clear();
    await ticketsBox.putAll({
      for (final e in merged) e.orderNumber: e,
    });
    await _syncCurrentCache(merged);

    emit(s.copyWith(
      tickets: merged,
      offset: merged.length,
      hasMore: false,
      isLoading: false,
      error: null,
      history: _readHistory(),
    ));
  }

  // -------------- Close --------------

  @override
  Future<void> close() async {
    await _ticketsSub?.cancel();
    return super.close();
  }
}
