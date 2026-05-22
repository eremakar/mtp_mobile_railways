import 'package:passflow_app/core/helpers/date.helper.dart';

class EmployeeStatisticsModel {
  final int id;
  final double planHours;
  final double workedHours;
  final double normHours;
  final DateTime month;
  final int monthlyNormId;
  final int employeeId;
  final List<TripModel> trips;
  final MonthlyNorm? monthlyNorm;
  final Employee? employee;
  final List<EmployeeDayStatisticModel> employeeDayStatistics;

  EmployeeStatisticsModel({
    required this.id,
    required this.planHours,
    required this.workedHours,
    required this.normHours,
    required this.month,
    required this.monthlyNormId,
    required this.employeeId,
    required this.trips,
    this.monthlyNorm,
    this.employee,
    required this.employeeDayStatistics,
  });

  double get plan => planHours;

  factory EmployeeStatisticsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeStatisticsModel(
      id: json['id'],
      planHours: (json['planHours'] ?? json['plan'] ?? 0).toDouble(),
      workedHours: (json['workedHours'] ?? 0).toDouble(),
      normHours:
          (json['normHours'] ?? json['monthlyNorm']?['norm'] ?? 0).toDouble(),
      month: DateTime.parse(json['month']),
      monthlyNormId: json['monthlyNormId'],
      employeeId: json['employeeId'],
      trips: (json['result'] as List<dynamic>?)
              ?.map((e) => TripModel.fromJson(e))
              .toList() ??
          [],
      monthlyNorm: json['monthlyNorm'] != null
          ? MonthlyNorm.fromJson(json['monthlyNorm'])
          : null,
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      employeeDayStatistics: (json['employeeDayStatistics'] as List<dynamic>?)
              ?.map((e) => EmployeeDayStatisticModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TripModel {
  final String routeName;
  final String startTime;
  final String endTime;
  final double workedHours;

  TripModel({
    required this.routeName,
    required this.startTime,
    required this.endTime,
    required this.workedHours,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final routeSheet = json['routeSheet'] ?? {};
    final routeClass = routeSheet['class'] ?? {};

    return TripModel(
      routeName: routeClass['name'] ?? routeSheet['name'] ?? '',
      startTime: routeSheet['routeStartTime'] ?? '',
      endTime: routeSheet['routeEndTime'] ?? '',
      workedHours: (json['workedHours'] ?? 0).toDouble(),
    );
  }
}

class MonthlyNorm {
  final int id;
  final int norm;
  final int monthNumber;

  MonthlyNorm({
    required this.id,
    required this.norm,
    required this.monthNumber,
  });

  factory MonthlyNorm.fromJson(Map<String, dynamic> json) {
    return MonthlyNorm(
      id: json['id'],
      norm: json['norm'],
      monthNumber: json['monthNumber'],
    );
  }
}

class Employee {
  final int id;
  final String lastName;
  final String firstName;
  final String fatherName;
  final String phone;
  final String iin;
  final int? roleId;
  final int? departmentId;
  final int? userId;
  final int? managerId;
  final int? positionId;
  final int? teamId;
  final int? teamRoleId;

  Employee({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.fatherName,
    required this.phone,
    required this.iin,
    this.roleId,
    this.departmentId,
    this.userId,
    this.managerId,
    this.positionId,
    this.teamId,
    this.teamRoleId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      fatherName: json['fatherName'] ?? '',
      phone: json['phone'] ?? '',
      iin: json['iin'] ?? '',
      roleId: json['roleId'],
      departmentId: json['departmentId'],
      userId: json['userId'],
      managerId: json['managerId'],
      positionId: json['positionId'],
      teamId: json['teamId'],
      teamRoleId: json['teamRoleId'],
    );
  }
}

class EmployeeDayStatisticModel {
  final int id;
  final double workedHours;
  final DateTime date;
  final int employeeDayStateId;
  final TripModel? trip;

  EmployeeDayStatisticModel({
    required this.id,
    required this.workedHours,
    required this.date,
    required this.employeeDayStateId,
    this.trip,
  });

  factory EmployeeDayStatisticModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDayStatisticModel(
      id: json['id'],
      workedHours: (json['workedHours'] ?? 0).toDouble(),
      date: DateHelper.parseDate(json['date']) ?? DateTime.now(),
      employeeDayStateId: json['employeeDayStateId'] ?? 0,
      trip: json['trip'] != null ? TripModel.fromJson(json['trip']) : null,
    );
  }
}
