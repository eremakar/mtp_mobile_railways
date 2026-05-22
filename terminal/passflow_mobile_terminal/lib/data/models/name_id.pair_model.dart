class NameIdPairModel {
  int id;

  String name;
  String? code;

  NameIdPairModel({required this.id, required this.name, this.code});

  factory NameIdPairModel.fromJson(Map<String, dynamic> json) =>
      NameIdPairModel(
        id: json['id'],
        name: json['name'],
        code: json['code'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
}
