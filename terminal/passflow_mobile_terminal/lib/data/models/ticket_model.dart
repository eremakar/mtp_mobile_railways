import 'package:hive/hive.dart';
import 'package:passflow_app/helpers/parse_helper.dart';

part 'ticket_model.g.dart';

List<TicketModel> ticketModelsFromJson(List<dynamic> json) =>
    json.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();

@HiveType(typeId: 15)
class StationModel extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? code;

  @HiveField(3)
  final String? shortName;

  @HiveField(4)
  final String? nameEn;

  @HiveField(5)
  final String? shortNameEn;

  @HiveField(6)
  final String? railwayName;

  @HiveField(7)
  final String? railwayShortName;

  @HiveField(8)
  final String? countryCode;

  @HiveField(9)
  final String? countryTlf;

  StationModel({
    this.id,
    this.name,
    this.code,
    this.shortName,
    this.nameEn,
    this.shortNameEn,
    this.railwayName,
    this.railwayShortName,
    this.countryCode,
    this.countryTlf,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      shortName: json['shortName'] as String?,
      nameEn: json['nameEn'] as String?,
      shortNameEn: json['shortNameEn'] as String?,
      railwayName: json['railwayName'] as String?,
      railwayShortName: json['railwayShortName'] as String?,
      countryCode: json['countryCode'] as String?,
      countryTlf: json['countryTlf'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'shortName': shortName,
        'nameEn': nameEn,
        'shortNameEn': shortNameEn,
        'railwayName': railwayName,
        'railwayShortName': railwayShortName,
        'countryCode': countryCode,
        'countryTlf': countryTlf,
      };
}

@HiveType(typeId: 16)
class PassengerModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String identityNumber;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String birthDate;

  @HiveField(4)
  final String citizenship;

  @HiveField(5)
  final String gender;

  PassengerModel({
    required this.id,
    required this.identityNumber,
    required this.fullName,
    required this.birthDate,
    required this.citizenship,
    required this.gender,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['id'] as int,
      identityNumber: json['identityNumber'] != null
          ? ParseHelper.normalizeIin(json['identityNumber'] as String)
          : "",
      fullName: json['fullName'] != null
          ? ParseHelper.normalizeFullName(json['fullName'] as String)
          : "",
      birthDate: json['birthDate'] != null ? json['birthDate'] as String : "",
      citizenship:
          json['citizenship'] != null ? json['citizenship'] as String : "",
      gender: json['gender'] != null ? json['gender'] as String : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identityNumber': identityNumber,
      'fullName': fullName,
      'birthDate': birthDate,
      'citizenship': citizenship,
      'gender': gender,
    };
  }
}

@HiveType(typeId: 17)
class TicketModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String trainNumber;

  @HiveField(2)
  final String departure;

  @HiveField(3)
  final String wagonNumber;

  @HiveField(4)
  final String placeNumber;

  @HiveField(5)
  final String orderNumber;

  @HiveField(6)
  final bool boardingPassed;

  @HiveField(7)
  final List<PassengerModel> passengers;

  @HiveField(8)
  final StationModel? deparute; // опечатка сохранена для совместимости

  @HiveField(9)
  final StationModel? arrival;

  @HiveField(10)
  final String documentKind;

  @HiveField(11)
  final bool? isSendToServer;

  @HiveField(12)
  final String wagonCategory;

  @HiveField(13)
  final String serviceClass;

  @HiveField(14)
  final String? orderDate;

  @HiveField(15)
  final num? operatorEmployeeId;
  @HiveField(16)
  final String? operatorEmployeeName;
  @HiveField(17)
  final String? operatorUpdatedTime;

  @HiveField(18)
  final String? operatorEmployeeTableNumber;

  @HiveField(19)
  final String? arrivalTime;

  TicketModel({
    required this.id,
    required this.trainNumber,
    required this.departure,
    required this.wagonNumber,
    required this.placeNumber,
    required this.orderNumber,
    required this.boardingPassed,
    required this.passengers,
    required this.documentKind,
    required this.wagonCategory,
    required this.serviceClass,
    this.deparute,
    this.arrival,
    this.isSendToServer,
    this.orderDate,
    this.operatorEmployeeId,
    this.operatorEmployeeName,
    this.operatorUpdatedTime,
    this.operatorEmployeeTableNumber,
    this.arrivalTime,
  });

  TicketModel copyWith(
      {int? id,
      String? trainNumber,
      String? departure,
      String? wagonNumber,
      String? placeNumber,
      String? orderNumber,
      bool? boardingPassed,
      List<PassengerModel>? passengers,
      String? documentKind,
      StationModel? deparute,
      StationModel? arrival,
      bool? isSendToServer,
      String? wagonCategory,
      String? serviceClass,
      String? orderDate,
      num? operatorEmployeeId,
      String? operatorEmployeeName,
      String? operatorUpdatedTime,
      String? operatorEmployeeTableNumber,
      String? arrivalTime}) {
    return TicketModel(
      id: id ?? this.id,
      trainNumber: trainNumber ?? this.trainNumber,
      departure: departure ?? this.departure,
      wagonNumber: wagonNumber ?? this.wagonNumber,
      placeNumber: placeNumber ?? this.placeNumber,
      orderNumber: orderNumber ?? this.orderNumber,
      boardingPassed: boardingPassed ?? this.boardingPassed,
      passengers: passengers ?? this.passengers,
      documentKind: documentKind ?? this.documentKind,
      deparute: deparute ?? this.deparute,
      arrival: arrival ?? this.arrival,
      isSendToServer: isSendToServer ?? this.isSendToServer,
      wagonCategory: wagonCategory ?? this.wagonCategory,
      serviceClass: serviceClass ?? this.serviceClass,
      orderDate: orderDate ?? this.orderDate,
      operatorEmployeeId: operatorEmployeeId ?? this.operatorEmployeeId,
      operatorEmployeeName: operatorEmployeeName ?? this.operatorEmployeeName,
      operatorUpdatedTime: operatorUpdatedTime ?? this.operatorUpdatedTime,
      operatorEmployeeTableNumber:
          operatorEmployeeTableNumber ?? this.operatorEmployeeTableNumber,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final passengersRaw = (json['passengers'] as List?) ?? const [];
    return TicketModel(
      id: json['id'] as int,
      trainNumber:
          json['trainNumber'] != null ? json['trainNumber'] as String : "",
      departure: json['departure'] != null ? json['departure'] as String : "",
      wagonNumber:
          json['wagonNumber'] != null ? json['wagonNumber'] as String : "",
      placeNumber:
          json['placeNumber'] != null ? json['placeNumber'] as String : "",
      orderNumber:
          json['orderNumber'] != null ? json['orderNumber'] as String : "",
      boardingPassed: json['boardingPassed'] != null
          ? json['boardingPassed'] as bool
          : false,
      documentKind:
          json['documentKind'] != null ? json['documentKind'] as String : "",
      passengers: passengersRaw
          .map((e) => PassengerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deparute: json['deparute'] != null
          ? StationModel.fromJson(json['deparute'] as Map<String, dynamic>)
          : null,
      arrival: json['arrival'] != null
          ? StationModel.fromJson(json['arrival'] as Map<String, dynamic>)
          : null,
      isSendToServer: json['isSendToServer'] as bool?,
      wagonCategory:
          json['wagonCategory'] != null ? json['wagonCategory'] as String : "",
      serviceClass:
          json['serviceClass'] != null ? json['serviceClass'] as String : "",
      orderDate: json['orderDate'] != null ? json['orderDate'] as String : null,
      operatorEmployeeId: json['operatorEmployeeId'] as num?,
      operatorEmployeeName: json['operatorEmployeeName'] as String?,
      operatorUpdatedTime: json['operatorUpdatedTime'] as String?,
      operatorEmployeeTableNumber:
          json['operatorEmployeeTableNumber'] as String?,
      arrivalTime: json['arrivalTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainNumber': trainNumber,
      'departure': departure,
      'wagonNumber': wagonNumber,
      'placeNumber': placeNumber,
      'orderNumber': orderNumber,
      'boardingPassed': boardingPassed,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'deparute': deparute?.toJson(),
      'arrival': arrival?.toJson(),
      'documentKind': documentKind,
      'isSendToServer': isSendToServer,
      'serviceClass': serviceClass,
      'wagonCategory': wagonCategory,
      'orderDate': orderDate,
      'operatorEmployeeId': operatorEmployeeId,
      'operatorEmployeeName': operatorEmployeeName,
      'operatorUpdatedTime': operatorUpdatedTime,
      'operatorEmployeeTableNumber': operatorEmployeeTableNumber,
      'arrivalTime': arrivalTime,
    };
  }
}
