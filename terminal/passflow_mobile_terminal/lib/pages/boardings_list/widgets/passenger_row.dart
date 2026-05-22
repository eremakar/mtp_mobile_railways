import 'package:passflow_app/data/models/ticket_model.dart';

class PassengerRow {
  final TicketModel ticket;
  final PassengerModel passenger;

  PassengerRow({
    required this.ticket,
    required this.passenger,
  });

  // Основные поля
  String get fullName => passenger.fullName;
  String get doc => passenger.identityNumber;
  String get wagon => ticket.wagonNumber;
  String get seat => ticket.placeNumber;
  String get gender => passenger.gender;

  /// Станция: сначала прибытие, затем отправление (fallback)
  String get station => ticket.arrival?.name ?? ticket.deparute?.name ?? '';

  /// Посадка проставлена локально/по серверу
  bool get boarded => ticket.boardingPassed;

  /// Отправлено ли изменение статуса на сервер и подтверждено бэком
  bool get isSynced => ticket.isSendToServer == true;

  /// Номер билета для отображения:
  /// если есть orderNumber — используем его, иначе составной
  String get ticketNumber {
    if (ticket.orderNumber.isNotEmpty) return ticket.orderNumber;
    final w = wagon.isEmpty ? '00' : wagon;
    final s = seat.isEmpty ? '0' : seat;
    final d = doc.isEmpty ? '000000' : doc;
    return '$w-$s-$d';
  }

  /// Удобные маркеры по типу документа
  bool get isChild => ticket.documentKind.toUpperCase() == 'ДЕТСКИЙ';
  bool get isAdult => ticket.documentKind.toUpperCase() == 'ВЗРОСЛЫЙ';
}
