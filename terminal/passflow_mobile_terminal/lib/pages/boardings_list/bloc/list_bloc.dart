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
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/data/repositories/tickets_repository.dart';
import 'package:passflow_app/data/repositories/train_direction_repository.dart';
import 'package:passflow_app/utils/network_utils.dart';

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
    final currentUser = userBox.get('currentUser');
    try {
      // final currentRouteSheet = routeSheetBox.get(user?.routeSheetId);

      // if (user?.id == null) {
      //   emit(s.copyWith(isLoading: false, error: 'Нет текущего пользователя'));
      //   return;
      // }
      // if (currentRouteSheet == null) {
      //   emit(s.copyWith(isLoading: false, error: 'Нет маршрутного листа'));
      //   return;
      // }

      final trainDirections = await trainDirectionsRepository.searchByFilial(
          filialId: currentUser?.filialId ?? 0);

      if (trainDirections == null || trainDirections.result.isEmpty) {
        emit(s.copyWith(
          isLoading: false,
          error: 'Нет данных по направлениям',
        ));
        return;
      }

      // final startTime = currentRouteSheet.routeSheetDate != null
      //     ? DateFormat('dd.MM.yyyy HH:mm')
      //         .format(currentRouteSheet.routeSheetDate!)
      //     : '';

      // final trainNumbers = currentRouteSheet.directions
      //     ?.map((e) =>
      //         '${e.trainDirection?.fullName} - ${e.startDate != null ? DateFormat('dd.MM.yyyy').format(e.startDate) : ''}')
      //     .toSet()
      //     .toList();

      emit(s.copyWith(
        isLoading: false,
        // stations: stations,
        trainDirections: trainDirections.result,
        // startTime: startTime,
        history: _readHistory(), // сразу поднимем историю в стейт
      ));
    } catch (e) {
      emit(s.copyWith(isLoading: false, error: e.toString()));
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
  }

  // -------------- Backend ops (оптимистично) --------------

  Future<void> _onRegisterBoarding(
    RegisterBoardingEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;

    // 1) Оптимистично обновляем Hive
    final t0 = ticketsBox.get(event.model.orderNumber);
    if (t0 != null) {
      await ticketsBox.put(
        event.model.orderNumber,
        t0.copyWith(boardingPassed: true, isSendToServer: false),
      );
    }

    // 2) Снимаем локальные флаги отказ/высадка
    final cur1 = state as BoardingsListState;
    final refused1 = Set<String>.from(cur1.refusedTicketIds)
      ..remove(event.model.orderNumber);
    final disemb1 = Set<String>.from(cur1.disembarkedTicketIds)
      ..remove(event.model.orderNumber);
    emit(cur1.copyWith(
      refusedTicketIds: refused1,
      disembarkedTicketIds: disemb1,
    ));

    // 3) Отправляем на сервер; обновляем флаг sync
    try {
      final boardingResult = await repository.registerBoarding(event.model);
      final savedModel =
          await repository.searchTicketsByOrderNumber(event.model.orderNumber);

      final t1 = ticketsBox.get(event.model.orderNumber);

      if (t1 != null) {
        // Берем приоритетно модель, пришедшую с сервера, иначе — локальную
        final base = savedModel ?? t1;

        final updated = base.copyWith(
          isSendToServer: boardingResult.success,
        );

        await ticketsBox.put(event.model.orderNumber, updated);
      }

      final cur2 = state as BoardingsListState;
      emit(cur2.copyWith(
        boardingSuccess: boardingResult.success,
        error: boardingResult.message,
        tickets: ticketsBox.values.toList(),
      ));
    } catch (e) {
      final curErr = state as BoardingsListState;
      emit(curErr.copyWith(
        error: e.toString(),
        boardingSuccess: false,
        tickets: ticketsBox.values.toList(),
      ));
    }
  }

  Future<void> _onCancelBoarding(
    CancelBoardingEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;

    // 1) Оптимистично: снять посадку
    final t0 = ticketsBox.get(event.model.orderNumber);
    if (t0 != null) {
      await ticketsBox.put(
        event.model.orderNumber,
        t0.copyWith(boardingPassed: false, isSendToServer: false),
      );
    }

    // 2) Локальные наборы
    final cur1 = state as BoardingsListState;
    final disemb1 = Set<String>.from(cur1.disembarkedTicketIds)
      ..add(event.model.orderNumber);
    final refused1 = Set<String>.from(cur1.refusedTicketIds)
      ..remove(event.model.orderNumber);
    emit(cur1.copyWith(
      disembarkedTicketIds: disemb1,
      refusedTicketIds: refused1,
    ));

    // 3) Бэк → флаг sync
    try {
      final boardingResult = await repository.cancelBoarding(event.model);
      final savedModel =
          await repository.searchTicketsByOrderNumber(event.model.orderNumber);

      final t1 = ticketsBox.get(event.model.orderNumber);

      if (t1 != null) {
        final base = savedModel ?? t1;
        final updated = base.copyWith(
          isSendToServer: boardingResult.success,
        );
        await ticketsBox.put(event.model.orderNumber, updated);
      }

      final cur2 = state as BoardingsListState;
      emit(cur2.copyWith(
        boardingSuccess: boardingResult.success,
        tickets: ticketsBox.values.toList(),
        error: boardingResult.message,
      ));
    } catch (e) {
      final curErr = state as BoardingsListState;
      emit(curErr.copyWith(
        error: e.toString(),
        boardingSuccess: false,
        tickets: ticketsBox.values.toList(),
      ));
    }
  }

  Future<void> _onDenyBoarding(
    DenyBoardingEvent event,
    Emitter<BoardingsState> emit,
  ) async {
    if (state is! BoardingsListState) return;

    // 1) Оптимистично: снять посадку
    final t0 = ticketsBox.get(event.model.orderNumber);
    if (t0 != null) {
      await ticketsBox.put(
        event.model.orderNumber,
        t0.copyWith(boardingPassed: false, isSendToServer: false),
      );
    }

    // 2) Локальные наборы
    final cur1 = state as BoardingsListState;
    final refused1 = Set<String>.from(cur1.refusedTicketIds)
      ..add(event.model.orderNumber);
    final disemb1 = Set<String>.from(cur1.disembarkedTicketIds)
      ..remove(event.model.orderNumber);
    emit(cur1.copyWith(
      refusedTicketIds: refused1,
      disembarkedTicketIds: disemb1,
    ));

    // 3) Бэк → флаг sync
    try {
      final boardingResult = await repository.denyBoarding(event.model);

      final savedModel =
          await repository.searchTicketsByOrderNumber(event.model.orderNumber);
      final t1 = ticketsBox.get(event.model.orderNumber);
      if (t1 != null) {
        final base = savedModel ?? t1;
        final updated = base.copyWith(
          isSendToServer: boardingResult.success,
        );
        await ticketsBox.put(event.model.orderNumber, updated);
      }

      final cur2 = state as BoardingsListState;
      emit(cur2.copyWith(
        boardingSuccess: boardingResult.success,
        tickets: ticketsBox.values.toList(),
        error: boardingResult.message,
      ));
    } catch (e) {
      final curErr = state as BoardingsListState;
      emit(curErr.copyWith(
        error: e.toString(),
        boardingSuccess: false,
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
    emit(s.copyWith(boardingSuccess: null));
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
      final raw = cacheBox.get(event.historyKey);
      final savedTickets = (raw as List).cast<TicketModel>();

      final merged = _mergeWithLocal(savedTickets);

      await ticketsBox.clear();
      await ticketsBox.putAll({for (final e in merged) e.orderNumber: e});

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
      if (stationCode == null) {
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

      List<TicketModel> result = const [];
      final hasNet = await NetworkUtils.hasConnection();

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

          // Сохраним историю + кеш (в кеш кладём "сырые" server tickets)
          await _saveHistoryAndCache(
            trainStr: trainNumber,
            stationName: event.searchModel['stationName'],
            departureStr: departureStr,
            stationCode: stationCode,
            tickets: result,
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

    final cached =
        (cacheBox.get(event.entry.key) as List?)?.cast<TicketModel>() ??
            const <TicketModel>[];
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
