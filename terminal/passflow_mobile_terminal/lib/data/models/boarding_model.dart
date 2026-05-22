class TicketsSearchModel {
  String train;
  String departure;
  String departureDate;
  int offset;
  int limit;
  String? startStationCode;

  TicketsSearchModel({
    required this.train,
    required this.departure,
    required this.departureDate,
    this.startStationCode,
    this.offset = 0,
    this.limit = 20,
  });

  factory TicketsSearchModel.fromJson(Map<String, dynamic> json) =>
      TicketsSearchModel(
        train: json['train'] as String,
        departure: json['departure'] as String,
        startStationCode: json['startStationCode'] as String?,
        offset: json['offset'] ?? 0,
        limit: json['limit'] ?? 20,
        departureDate: (json['departureDate'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'train': train,
        'departure': departure,
        'offset': offset,
        'limit': limit,
        'startStationCode': startStationCode,
        'departureDate': departureDate,
      };
}
