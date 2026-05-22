class DocumentsSearchRequest {
  final DocumentsFilter filter;

  DocumentsSearchRequest({required this.filter});

  Map<String, dynamic> toJson() => {
        'filter': filter.toJson(),
      };
}

class DocumentsFilter {
  final FilterCondition? ownerId;
  final FilterCondition? documentTypeId;

  DocumentsFilter({
    this.ownerId,
    this.documentTypeId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ownerId != null) map['ownerId'] = ownerId!.toJson();
    if (documentTypeId != null) map['documentTypeId'] = documentTypeId!.toJson();
    return map;
  }
}

class FilterCondition {
  final int operand1;
  final String operator; 

  FilterCondition({
    required this.operand1,
    required this.operator,
  });

  Map<String, dynamic> toJson() => {
        'operand1': operand1,
        'operator': operator,
      };
}