import 'dart:convert';

class Vu8RemarkSearchResponse {
  final List<Vu8Remark> result;
  final int? total;
  final int? pageCount;

  Vu8RemarkSearchResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  factory Vu8RemarkSearchResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['result'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Vu8Remark.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Vu8RemarkSearchResponse(
      result: list,
      total: json['total'] is int ? json['total'] as int : null,
      pageCount: json['pageCount'] is int ? json['pageCount'] as int : null,
    );
  }
}

class Vu8Remark {
  final int id;
  final String text;
  final Vu8ImageS3? image;
  final DateTime createdTime;
  final String? completedText;

  final int wagonId;
  final int employeeId;
  final int routeId;
  final int routeSheetId;
  final int typeId;

  final Vu8Wagon? wagon;
  final Vu8Employee? employee;
  final Vu8Type? type;

  String? get imageUrl => image?.key;
  String? get imageBucketName => image?.bucketName;
  String? get imageObjectName => image?.objectName;

  Vu8Remark({
    required this.id,
    required this.text,
    required this.image,
    required this.createdTime,
    required this.completedText,
    required this.wagonId,
    required this.employeeId,
    required this.routeId,
    required this.routeSheetId,
    required this.typeId,
    required this.wagon,
    required this.employee,
    required this.type,
  });

  factory Vu8Remark.fromJson(Map<String, dynamic> json) {
    return Vu8Remark(
      id: (json['id'] as num?)?.toInt() ?? 0,
      text: (json['text'] as String?) ?? '',
      image: Vu8ImageS3.tryParse(json['imageUrl']),
      createdTime: DateTime.tryParse((json['createdTime'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      completedText: json['completedText'] as String?,
      wagonId: (json['wagonId'] as num?)?.toInt() ?? 0,
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      routeId: (json['routeId'] as num?)?.toInt() ?? 0,
      routeSheetId: (json['routeSheetId'] as num?)?.toInt() ?? 0,
      typeId: (json['typeId'] as num?)?.toInt() ?? 0,
      wagon: json['wagon'] is Map<String, dynamic>
          ? Vu8Wagon.fromJson(json['wagon'] as Map<String, dynamic>)
          : null,
      employee: json['employee'] is Map<String, dynamic>
          ? Vu8Employee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      type: json['type'] is Map<String, dynamic>
          ? Vu8Type.fromJson(json['type'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Vu8ImageS3 {
  final String? key;
  final int? size;
  final String? fileName;
  final String? fullName;
  final String? bucketName;
  final String? objectName;

  Vu8ImageS3({
    this.key,
    this.size,
    this.fileName,
    this.fullName,
    this.bucketName,
    this.objectName,
  });

  static Vu8ImageS3? tryParse(dynamic raw) {
    if (raw == null) return null;

    if (raw is Map<String, dynamic>) {
      return Vu8ImageS3.fromJson(raw);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>)
          return Vu8ImageS3.fromJson(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory Vu8ImageS3.fromJson(Map<String, dynamic> json) {
    return Vu8ImageS3(
      key: json['key'] as String?,
      size: (json['size'] as num?)?.toInt(),
      fileName: json['fileName'] as String?,
      fullName: json['fullName'] as String?,
      bucketName: json['bucketName'] as String?,
      objectName: json['objectName'] as String?,
    );
  }
}

class Vu8Type {
  final int id;
  final String name;
  final String? description;

  Vu8Type({required this.id, required this.name, this.description});

  factory Vu8Type.fromJson(Map<String, dynamic> json) => Vu8Type(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['name'] as String?) ?? '',
        description: json['description'] as String?,
      );
}

class Vu8TypeSearchResponse {
  final List<Vu8Type> result;
  final int? total;
  final int? pageCount;

  Vu8TypeSearchResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  factory Vu8TypeSearchResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['result'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Vu8Type.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Vu8TypeSearchResponse(
      result: list,
      total: json['total'] is int ? json['total'] as int : null,
      pageCount: json['pageCount'] is int ? json['pageCount'] as int : null,
    );
  }
}

class Vu8Employee {
  final int id;
  final String lastName;
  final String firstName;
  final String? fatherName;

  Vu8Employee({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.fatherName,
  });

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  String get shortName {
    final f = firstName.isNotEmpty ? '${firstName[0]}.' : '';
    final p = (fatherName ?? '').isNotEmpty ? '${fatherName![0]}.' : '';
    return '$lastName $f$p'.trim();
  }

  factory Vu8Employee.fromJson(Map<String, dynamic> json) => Vu8Employee(
        id: (json['id'] as num?)?.toInt() ?? 0,
        lastName: (json['lastName'] as String?) ?? '',
        firstName: (json['firstName'] as String?) ?? '',
        fatherName: json['fatherName'] as String?,
      );
}

class Vu8Wagon {
  final int id;
  final String number;
  final String? type;

  Vu8Wagon({required this.id, required this.number, this.type});

  factory Vu8Wagon.fromJson(Map<String, dynamic> json) => Vu8Wagon(
        id: (json['id'] as num?)?.toInt() ?? 0,
        number: (json['number'] as String?) ?? '',
        type: json['type'] as String?,
      );
}
