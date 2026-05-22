class RouteSheetEmployeeModel {
  final int id;
  final bool isArrived;
  final DateTime arriveTime;
  final DateTime leaveTime;
  final double workedHours;
  final double? plannedHours;
  final int routeSheetId;
  final int employeeId;
  final int? month1StatisticId;
  final int? month2StatisticId;
  final bool? isBusy;
  final RouteSheet routeSheet;
  final Employee employee;
  final RouteSheetItem routeSheetItem;
  final bool isLead;

  RouteSheetEmployeeModel({
    required this.id,
    required this.isArrived,
    required this.arriveTime,
    required this.leaveTime,
    required this.workedHours,
    this.plannedHours,
    required this.routeSheetId,
    required this.employeeId,
    required this.routeSheet,
    required this.employee,
    required this.routeSheetItem,
    this.month1StatisticId,
    this.month2StatisticId,
    this.isBusy,
    this.isLead = false,
  });

  factory RouteSheetEmployeeModel.fromJson(Map<String, dynamic> json) {
    return RouteSheetEmployeeModel(
      id: json['id'],
      isArrived: json['isArrived'],
      arriveTime: DateTime.parse(json['arriveTime']),
      leaveTime: DateTime.parse(json['leaveTime']),
      workedHours: (json['workedHours'] as num).toDouble(),
      plannedHours: (json['plannedHours'] != null)
          ? (json['plannedHours'] as num).toDouble()
          : null,
      routeSheetId: json['routeSheetId'],
      employeeId: json['employeeId'],
      month1StatisticId: json['month1StatisticId'],
      month2StatisticId: json['month2StatisticId'],
      isBusy: json['isBusy'],
      routeSheet: RouteSheet.fromJson(json['routeSheet']),
      employee: Employee.fromJson(json['employee']),
      routeSheetItem: RouteSheetItem.fromJson(json['routeSheetItem']),
      isLead: json['isLead'] ?? false,
    );
  }
}

class RouteSheet {
  final int id;
  final String name;
  final bool isArchive;
  final String sapId;
  final int type;
  final String state;
  final DateTime comeTime;
  final DateTime leaveTime;
  final DateTime editedDate;
  final int state2Id;
  final DateTime? routeStartTime;
  final int ownerEmployeeId;
  final int routeId;
  final int departmentId;
  final int? parentId;
  final int taskListTypeId;
  final int taskMenuTypeId;
  String? statusName;

  RouteSheet({
    required this.id,
    required this.name,
    required this.isArchive,
    required this.sapId,
    required this.type,
    required this.state,
    required this.comeTime,
    required this.leaveTime,
    required this.editedDate,
    required this.state2Id,
    this.routeStartTime,
    required this.ownerEmployeeId,
    required this.routeId,
    required this.departmentId,
    this.parentId,
    required this.taskListTypeId,
    required this.taskMenuTypeId,
    this.statusName,
  });

  factory RouteSheet.fromJson(Map<String, dynamic> json) {
    return RouteSheet(
        id: json['id'],
        name: json['name'],
        isArchive: json['isArchive'],
        sapId: json['sapId'],
        type: json['type'],
        state: json['state'],
        comeTime: DateTime.parse(json['comeTime']),
        leaveTime: DateTime.parse(json['leaveTime']),
        editedDate: DateTime.parse(json['editedDate']),
        state2Id: json['state2Id'] ?? 0,
        routeStartTime: json['routeStartTime'] != null
            ? DateTime.tryParse(json['routeStartTime'])
            : null,
        ownerEmployeeId: json['ownerEmployeeId'],
        routeId: json['routeId'],
        departmentId: json['departmentId'],
        parentId: json['parentId'],
        taskListTypeId: json['taskListTypeId'],
        taskMenuTypeId: json['taskMenuTypeId'],
        statusName: getStatusName(json['state']));
  }

  static String getStatusName(String state) {
    return switch (state) {
      "0" => "Не сформирован",
      "1" => "Сформирован",
      "2" => "Создан",
      "3" => "Предрейсовая подготовка",
      "4" => "В пути",
      "5" => "Завершено",
      _ => "false",
    };
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
      lastName: json['lastName'],
      firstName: json['firstName'],
      fatherName: json['fatherName'],
      phone: json['phone'],
      iin: json['iin'],
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

class RouteSheetItem {
  final int id;
  final int routeSheetId;
  final int groupNumber;
  final Wagon? wagon;

  RouteSheetItem({
    required this.id,
    required this.routeSheetId,
    required this.groupNumber,
    this.wagon,
  });

  factory RouteSheetItem.fromJson(Map<String, dynamic> json) {
    return RouteSheetItem(
      id: json['id'],
      routeSheetId: json['routeSheetId'],
      groupNumber: json['groupNumber'] ?? 0,
      wagon: json['wagon'] != null ? Wagon.fromJson(json['wagon']) : null,
    );
  }
}

class Wagon {
  final int id;
  final String? number;
  final int? routeClassId;

  Wagon({
    required this.id,
    this.number,
    this.routeClassId,
  });

  factory Wagon.fromJson(Map<String, dynamic> json) {
    return Wagon(
      id: json['id'],
      number: json['number']?.toString(),
      routeClassId: json['routeClassId'],
    );
  }
}
