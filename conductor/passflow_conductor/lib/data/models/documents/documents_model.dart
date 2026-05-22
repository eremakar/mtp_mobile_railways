import 'dart:convert';

class DocumentsSearchResponse {
  final List<DocumentItem> result;
  final int? total;
  final int? pageCount;

  const DocumentsSearchResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  factory DocumentsSearchResponse.fromJson(Map<String, dynamic> json) {
    return DocumentsSearchResponse(
      result: (json['result'] as List? ?? [])
          .map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] is int ? json['total'] as int : null,
      pageCount: json['pageCount'] is int ? json['pageCount'] as int : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'result': result.map((e) => e.toJson()).toList(),
        'total': total,
        'pageCount': pageCount,
      };

  DocumentsSearchResponse copyWith({
    List<DocumentItem>? result,
    int? total,
    int? pageCount,
  }) {
    return DocumentsSearchResponse(
      result: result ?? this.result,
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
    );
  }
}

class DocumentItem {
  final int id;
  final String? name;
  final String? number;
  final String? issueDate; 
  final String? expirationDate; 
  final int? filesCount;
  final bool? isExpired;
  final int? state;
  final int? documentTypeId;
  final int? documentCategoryId;
  final int? ownerId;
  final int? filialId;
  final int? departmentId;

  final DocumentTypeInfo? documentType;
  final DocumentCategoryInfo? documentCategory;
  final OwnerInfo? owner;
  final FilialInfo? filial;
  final DepartmentInfo? department;

  final List<DocumentFile> files;
  final List<dynamic> tags;

  const DocumentItem({
    required this.id,
    this.name,
    this.number,
    this.issueDate,
    this.expirationDate,
    this.filesCount,
    this.isExpired,
    this.state,
    this.documentTypeId,
    this.documentCategoryId,
    this.ownerId,
    this.filialId,
    this.departmentId,
    this.documentType,
    this.documentCategory,
    this.owner,
    this.filial,
    this.department,
    required this.files,
    required this.tags,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: (json['id'] ?? 0) as int,
      name: json['name'] as String?,
      number: json['number'] as String?,
      issueDate: json['issueDate'] as String?,
      expirationDate: json['expirationDate'] as String?,
      filesCount: json['filesCount'] as int?,
      isExpired: json['isExpired'] as bool?,
      state: json['state'] as int?,
      documentTypeId: json['documentTypeId'] as int?,
      documentCategoryId: json['documentCategoryId'] as int?,
      ownerId: json['ownerId'] as int?,
      filialId: json['filialId'] as int?,
      departmentId: json['departmentId'] as int?,
      documentType: json['documentType'] is Map<String, dynamic>
          ? DocumentTypeInfo.fromJson(json['documentType'])
          : null,
      documentCategory: json['documentCategory'] is Map<String, dynamic>
          ? DocumentCategoryInfo.fromJson(json['documentCategory'])
          : null,
      owner: json['owner'] is Map<String, dynamic>
          ? OwnerInfo.fromJson(json['owner'])
          : null,
      filial: json['filial'] is Map<String, dynamic>
          ? FilialInfo.fromJson(json['filial'])
          : null,
      department: json['department'] is Map<String, dynamic>
          ? DepartmentInfo.fromJson(json['department'])
          : null,
      files: (json['files'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => DocumentFile.fromJson(e))
          .toList(),
      tags: (json['tags'] as List? ?? const []).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'number': number,
        'issueDate': issueDate,
        'expirationDate': expirationDate,
        'filesCount': filesCount,
        'isExpired': isExpired,
        'state': state,
        'documentTypeId': documentTypeId,
        'documentCategoryId': documentCategoryId,
        'ownerId': ownerId,
        'filialId': filialId,
        'departmentId': departmentId,
        'documentType': documentType?.toJson(),
        'documentCategory': documentCategory?.toJson(),
        'owner': owner?.toJson(),
        'filial': filial?.toJson(),
        'department': department?.toJson(),
        'files': files.map((e) => e.toJson()).toList(),
        'tags': tags,
      };
}

class DocumentTypeInfo {
  final int id;
  final String? name;
  final String? code;

  const DocumentTypeInfo({
    required this.id,
    this.name,
    this.code,
  });

  factory DocumentTypeInfo.fromJson(Map<String, dynamic> json) {
    return DocumentTypeInfo(
      id: (json['id'] ?? 0) as int,
      name: json['name'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
      };
}

class DocumentCategoryInfo {
  final int id;
  final String? name;
  final String? code;
  final int? parentId;
  final dynamic parent;

  const DocumentCategoryInfo({
    required this.id,
    this.name,
    this.code,
    this.parentId,
    this.parent,
  });

  factory DocumentCategoryInfo.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryInfo(
      id: (json['id'] ?? 0) as int,
      name: json['name'] as String?,
      code: json['code'] as String?,
      parentId: json['parentId'] as int?,
      parent: json['parent'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'parentId': parentId,
        'parent': parent,
      };
}

class FilialInfo {
  final int id;
  final String? name;

  const FilialInfo({
    required this.id,
    this.name,
  });

  factory FilialInfo.fromJson(Map<String, dynamic> json) {
    return FilialInfo(
      id: (json['id'] ?? 0) as int,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DepartmentInfo {
  final int id;
  final String? name;
  final int? filialId;
  final dynamic filial;

  const DepartmentInfo({
    required this.id,
    this.name,
    this.filialId,
    this.filial,
  });

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) {
    return DepartmentInfo(
      id: (json['id'] ?? 0) as int,
      name: json['name'] as String?,
      filialId: json['filialId'] as int?,
      filial: json['filial'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filialId': filialId,
        'filial': filial,
      };
}

class OwnerInfo {
  final int id;
  final String? lastName;
  final String? firstName;
  final String? fatherName;
  final String? phone;
  final String? iin;
  final String? tableNumber;
  final String? s3Photo;
  final String? birthdate;
  final int? roleId;
  final int? departmentId;
  final int? userId;
  final int? managerId;
  final int? positionId;
  final int? teamId;
  final int? teamRoleId;
  final dynamic role;
  final dynamic department;
  final dynamic user;
  final dynamic manager;
  final dynamic position;
  final dynamic team;
  final dynamic teamRole;
  final dynamic routeSheets;

  const OwnerInfo({
    required this.id,
    this.lastName,
    this.firstName,
    this.fatherName,
    this.phone,
    this.iin,
    this.tableNumber,
    this.s3Photo,
    this.birthdate,
    this.roleId,
    this.departmentId,
    this.userId,
    this.managerId,
    this.positionId,
    this.teamId,
    this.teamRoleId,
    this.role,
    this.department,
    this.user,
    this.manager,
    this.position,
    this.team,
    this.teamRole,
    this.routeSheets,
  });

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      id: (json['id'] ?? 0) as int,
      lastName: json['lastName'] as String?,
      firstName: json['firstName'] as String?,
      fatherName: json['fatherName'] as String?,
      phone: json['phone'] as String?,
      iin: json['iin'] as String?,
      tableNumber: json['tableNumber'] as String?,
      s3Photo: json['s3Photo'] as String?,
      birthdate: json['birthdate'] as String?,
      roleId: json['roleId'] as int?,
      departmentId: json['departmentId'] as int?,
      userId: json['userId'] as int?,
      managerId: json['managerId'] as int?,
      positionId: json['positionId'] as int?,
      teamId: json['teamId'] as int?,
      teamRoleId: json['teamRoleId'] as int?,
      role: json['role'],
      department: json['department'],
      user: json['user'],
      manager: json['manager'],
      position: json['position'],
      team: json['team'],
      teamRole: json['teamRole'],
      routeSheets: json['routeSheets'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lastName': lastName,
        'firstName': firstName,
        'fatherName': fatherName,
        'phone': phone,
        'iin': iin,
        'tableNumber': tableNumber,
        's3Photo': s3Photo,
        'birthdate': birthdate,
        'roleId': roleId,
        'departmentId': departmentId,
        'userId': userId,
        'managerId': managerId,
        'positionId': positionId,
        'teamId': teamId,
        'teamRoleId': teamRoleId,
        'role': role,
        'department': department,
        'user': user,
        'manager': manager,
        'position': position,
        'team': team,
        'teamRole': teamRole,
        'routeSheets': routeSheets,
      };
}

class DocumentFile {
  final int id;
  final String? name;
  final S3PathInfo? s3Path; 
  final String? createdTime;
  final int? documentId;
  final int? authorId;
  final dynamic document;
  final OwnerInfo? author;
  final dynamic tags;

  const DocumentFile({
    required this.id,
    this.name,
    this.s3Path,
    this.createdTime,
    this.documentId,
    this.authorId,
    this.document,
    this.author,
    this.tags,
  });

  factory DocumentFile.fromJson(Map<String, dynamic> json) {
    return DocumentFile(
      id: (json['id'] ?? 0) as int,
      name: json['name'] as String?,
      s3Path: _parseS3Path(json['s3Path']),
      createdTime: json['createdTime'] as String?,
      documentId: json['documentId'] as int?,
      authorId: json['authorId'] as int?,
      document: json['document'],
      author: json['author'] is Map<String, dynamic>
          ? OwnerInfo.fromJson(json['author'])
          : null,
      tags: json['tags'],
    );
  }

  static S3PathInfo? _parseS3Path(dynamic raw) {
    if (raw == null) return null;

    if (raw is Map<String, dynamic>) {
      return S3PathInfo.fromJson(raw);
    }

    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return S3PathInfo.fromJson(decoded);
        }
      } catch (_) {
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        's3Path': s3Path?.toJson(),
        'createdTime': createdTime,
        'documentId': documentId,
        'authorId': authorId,
        'document': document,
        'author': author?.toJson(),
        'tags': tags,
      };
}

class S3PathInfo {
  final String? key;
  final int? size;
  final String? fileName;
  final String? fullName;
  final String? bucketName;
  final String? objectName;

  const S3PathInfo({
    this.key,
    this.size,
    this.fileName,
    this.fullName,
    this.bucketName,
    this.objectName,
  });

  factory S3PathInfo.fromJson(Map<String, dynamic> json) {
    return S3PathInfo(
      key: json['key'] as String?,
      size: json['size'] as int?,
      fileName: json['fileName'] as String?,
      fullName: json['fullName'] as String?,
      bucketName: json['bucketName'] as String?,
      objectName: json['objectName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'size': size,
        'fileName': fileName,
        'fullName': fullName,
        'bucketName': bucketName,
        'objectName': objectName,
      };
}