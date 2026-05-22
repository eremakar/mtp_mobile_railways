import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/boarding_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/helpers/parse_helper.dart';

// Возвращаемая структура: список билетов + общее количество (total)
class TicketsSearchResult {
  final List<TicketModel> items;
  final int total;
  const TicketsSearchResult({required this.items, required this.total});
}

// tickets_repository.dart (добавь сверху)
enum BoardingOp { passReg, passUnReg, passDeny }

String _opField(BoardingOp op) {
  switch (op) {
    case BoardingOp.passReg:
      return 'passReg';
    case BoardingOp.passUnReg:
      return 'passUnReg';
    case BoardingOp.passDeny:
      return 'passDeny';
  }
}

BoardingOp _opFromString(String? value) {
  switch (value) {
    case 'passUnReg':
      return BoardingOp.passUnReg;
    case 'passDeny':
      return BoardingOp.passDeny;
    default:
      return BoardingOp.passReg;
  }
}

class TicketsRepository {
  static const String _hiveBoxName = 'pending_boarding';
  final StationsRepo stationsRepository = sl<StationsRepo>();

  Future<List<TicketModel>?> searchTicketsSSPD(
    TicketsSearchModel searchModel, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // throw Exception("ОШ T: UN25: ВЕДОМОСТЬ ПОЛУЧАТЬ РАНО");
      // if (kDebugMode) {
      //   searchModel.train = "829А";
      //   searchModel.departure = "17.11.2025";
      //   searchModel.startStationCode = "2708000";
      // }
      final response = await DioClient.dio.post(
        '/sspd/api/v2/sspd/ticketsList',
        data: json.encode({
          "ListType": "1530",
          "ListVer": "3",
          "TrainNumber": searchModel.train,
          "DepDate": searchModel.departure,
          "StationCode": searchModel.startStationCode,
          "DocType": "*"
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ сервер прислал "errors" при 200
        if (data is Map &&
            data['errors'] is List &&
            (data['errors'] as List).isNotEmpty) {
          final err = (data['errors'] as List).first;
          final msg = (err is Map && err['message'] is String)
              ? (err['message'] as String)
              : 'Неизвестная ошибка';
          throw Exception(msg); // пробрасываем вверх
        }

        if (data['result'] is List && data['result'].isNotEmpty) {
          // return ticketModelsFromJson(data['result']);
          return await searchTickets(searchModel, limit: limit, offset: offset);
        }
        return [];
      }

      throw Exception('Код ответа: ${response.statusCode}');
    } catch (e) {
      // Можно логировать тут technical details
      rethrow; // важно пробросить дальше
    }
  }

  Future<TicketModel?> searchTicketsByOrderNumber(String orderNumber) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/tickets/search',
        data: json.encode({
          "filter": {
            "orderNumber": {"operand1": orderNumber, "operator": 1}
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ сервер прислал "errors" при 200
        if (data is Map &&
            data['errors'] is List &&
            (data['errors'] as List).isNotEmpty) {
          final err = (data['errors'] as List).first;
          final msg = (err is Map && err['message'] is String)
              ? (err['message'] as String)
              : 'Неизвестная ошибка';
          throw Exception(msg); // пробрасываем вверх
        }

        if (data['result'] is List && data['result'].isNotEmpty) {
          return ticketModelsFromJson(data['result']).length > 0
              ? ticketModelsFromJson(data['result']).first
              : throw Exception('Билет не найден');
        }
        return null;
      }

      throw Exception('Код ответа: ${response.statusCode}');
    } catch (e) {
      // Можно логировать тут technical details
      rethrow; // важно пробросить дальше
    }
  }

  Future<List<TicketModel>?> searchTickets(
    TicketsSearchModel searchModel, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/tickets/search',
        data: json.encode({
          "filter": {
            "trainNumber": {"operand1": searchModel.train, "operator": 1},
            "departure": {"operand1": searchModel.departureDate, "operator": 1}
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ сервер прислал "errors" при 200
        if (data is Map &&
            data['errors'] is List &&
            (data['errors'] as List).isNotEmpty) {
          final err = (data['errors'] as List).first;
          final msg = (err is Map && err['message'] is String)
              ? (err['message'] as String)
              : 'Неизвестная ошибка';
          throw Exception(msg); // пробрасываем вверх
        }

        if (data['result'] is List && data['result'].isNotEmpty) {
          return ticketModelsFromJson(data['result']);
        }
        return [];
      }

      throw Exception('Код ответа: ${response.statusCode}');
    } catch (e) {
      // Можно логировать тут technical details
      rethrow; // важно пробросить дальше
    }
  }

  Future<void> resendAllPendingBoardings() async {
    final box = Hive.box<String>(_hiveBoxName);
    if (box.isEmpty) {
      print('📂 Нет локальных операций посадки.');
      return;
    }

    print('📤 Отправка ${box.length} локальных операций...');
    final keysToRemove = <dynamic>[];
    final ticketsBox = Hive.box<TicketModel>('tickets');

    for (final key in List.of(box.keys)) {
      final jsonString = box.get(key);
      if (jsonString == null) continue;

      try {
        final data = json.decode(jsonString);

        BoardingOp op;
        TicketModel ticket;

        if (data is Map && data['op'] != null && data['ticket'] != null) {
          final ticketMap = Map<String, dynamic>.from(data['ticket'] as Map);
          op = _opFromString(data['op'] as String?);
          ticket = TicketModel.fromJson(ticketMap);
        } else if (data is Map) {
          op = BoardingOp.passReg;
          ticket = TicketModel.fromJson(Map<String, dynamic>.from(data));
        } else {
          throw Exception('Неверный формат локальной записи: $data');
        }

        final result = await _submitBoardingRequest(ticket, op);

        if (result.success) {
          print('✅ Посадка отправлена успешно: ${ticket.orderNumber}');
          keysToRemove.add(key);
          final current = ticketsBox.get(ticket.orderNumber);
          await ticketsBox.put(
            ticket.orderNumber,
            (current ?? ticket).copyWith(isSendToServer: true),
          );
        } else {
          final current = ticketsBox.get(ticket.orderNumber);
          if (current != null) {
            await ticketsBox.put(
              ticket.orderNumber,
              current.copyWith(isSendToServer: false),
            );
          }
          print(
              '⚠️ Ошибка отправки посадки ${ticket.orderNumber}: ${result.message ?? ''}');
        }
      } catch (e) {
        print('❌ Ошибка при отправке ключа $key: $e');
      }
    }

    if (keysToRemove.isNotEmpty) {
      await box.deleteAll(keysToRemove);
      print('🧹 Удалено успешно отправленных: ${keysToRemove.length}');
    }
  }

  String? _prepareDateForPayload(dynamic raw) {
    final formatted = ParseHelper.parseDateWithFormat(raw, 'dd.MM.yyyy');
    if (formatted != null && formatted.isNotEmpty) {
      return formatted;
    }
    if (raw == null) return null;
    final value = raw.toString();
    return value.isEmpty ? null : value;
  }

  Future<BoardingResult> _submitBoardingRequest(
    TicketModel model,
    BoardingOp op,
  ) async {
    final payload = <String, dynamic>{
      'trainNumber': model.trainNumber,
      'depDate': _prepareDateForPayload(model.departure),
      _opField(op): [model.orderNumber],
    };

    final orderDate = _prepareDateForPayload(model.orderDate);
    if (orderDate != null) {
      payload['orderDate'] = orderDate;
    }

    payload.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    try {
      final response = await DioClient.dio.post(
        '/api/v1/sspd/boardingPass',
        data: json.encode(payload),
      );

      if (response.statusCode != 200) {
        return BoardingResult(
          success: false,
          message: 'HTTP ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data = response.data is String
          ? json.decode(response.data as String) as Map<String, dynamic>
          : (response.data as Map<String, dynamic>? ?? const {});

      final section = data[_opField(op)] as Map<String, dynamic>?;
      final passes = (section?['boardingPasses'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final item = passes.firstWhere(
        (e) => (e['number']?.toString() ?? '') == model.orderNumber,
        orElse: () => const <String, dynamic>{},
      );

      final kop = int.tryParse(item['kop']?.toString() ?? '') ?? 1;
      final statusStr = item['status']?.toString();

      if (kop == 0) {
        return BoardingResult(success: true);
      }

      return BoardingResult(
        success: false,
        message: statusText(statusStr),
      );
    } catch (e) {
      return BoardingResult(success: false, message: e.toString());
    }
  }

  Future<BoardingResult> _sendBoardingOp(
      TicketModel model, BoardingOp op) async {
    final box = Hive.box<String>(_hiveBoxName);
    final ticketsBox = Hive.box<TicketModel>('tickets');
    final key = '${_opField(op)}:${model.orderNumber}';

    final storedTicket = ticketsBox.get(model.orderNumber);
    final pendingTicket =
        (storedTicket ?? model).copyWith(isSendToServer: false);
    await ticketsBox.put(model.orderNumber, pendingTicket);

    await box.put(
      key,
      json.encode({'op': _opField(op), 'ticket': model.toJson()}),
    );

    final result = await _submitBoardingRequest(model, op);

    if (result.success) {
      await box.delete(key);
      await ticketsBox.put(
        model.orderNumber,
        (storedTicket ?? model).copyWith(isSendToServer: true),
      );
    } else {
      print(
        '⚠️ Не удалось отправить посадку ${model.orderNumber}: ${result.message ?? ''}',
      );
    }

    return result;
  }

  Future<BoardingResult> registerBoarding(TicketModel model) =>
      _sendBoardingOp(model, BoardingOp.passReg);

  Future<BoardingResult> cancelBoarding(TicketModel model) =>
      _sendBoardingOp(model, BoardingOp.passUnReg);

  Future<BoardingResult> denyBoarding(TicketModel model) =>
      _sendBoardingOp(model, BoardingOp.passDeny);

  /// Нормализуем код: убираем пробелы, приводим к верхнему регистру,
  /// и заменяем кириллическую 'С' на латинскую 'C' (часто путают).
  String _normStatusCode(String? code) {
    if (code == null) return '';
    final s = code.trim().toUpperCase().replaceAll('С', 'C');
    return s;
  }

  /// Человекочитаемый текст по статус-коду из ответа ССПД
  String statusText(String? code) {
    switch (_normStatusCode(code)) {
      case '1':
        return 'Погашен';
      case '2':
        return 'Возвращен';
      case '3':
        return 'Выполнен частичный возврат';
      case '4':
        return 'Возвращены места';
      case '5':
        return 'Переоформлен';
      case '6':
        return 'Выдан дубликат (бумажная копия) или регистрация посадки недопустима после отказа в посадке';
      case '7':
        return 'Выполнено прерывание поездки';
      case '8':
        return 'Электронный билет без ЭР';
      case '9':
        return 'Посадка зарегистрирована ранее';
      case 'A':
        return 'Посадки не было';
      case 'B':
        return 'Документ не найден';
      case 'C':
        return 'Синтаксическая ошибка';
      case 'D':
        return 'Информация недоступна';
      case 'E':
        return 'Не совпали номер поезда и дата отправления';
      default:
        return 'Неизвестный статус';
    }
  }
}

class BoardingResult {
  bool success;
  String? message;

  BoardingResult({
    required this.success,
    this.message,
  });
}
