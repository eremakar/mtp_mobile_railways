import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? routeSheetId;

  @HiveField(3)
  String? trainNumber;

  @HiveField(4)
  String? wagonNumber;

  @HiveField(5)
  int? filialId;

  @HiveField(6)
  int? departmentId;

  @HiveField(7)
  String? token;

  @HiveField(8)
  int employeeId;

  @HiveField(9)
  String login;

  @HiveField(10)
  String password;

  @HiveField(11)
  int? userId;

  UserModel(
      {required this.id,
      required this.name,
      this.routeSheetId,
      this.trainNumber,
      this.wagonNumber,
      this.filialId,
      this.departmentId,
      required this.employeeId,
      required this.login,
      required this.password,
      this.token,
      this.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        employeeId: json['employeeId'] ?? 0,
        login: json['login'] ?? '',
        password: json['password'] ?? '',
        userId: json['userId'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'userId': userId};
}
