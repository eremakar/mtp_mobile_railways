enum BoardingStatus {
  pending,
  onboarded,
  success,
}

class Boarding {
  final String name;
  final String docNumber;
  final String seat;
  final BoardingStatus status;
  final bool isSelected;

  Boarding({
    required this.name,
    required this.docNumber,
    required this.seat,
    required this.status,
    this.isSelected = false,
  });

  Boarding copyWith({
    String? name,
    String? docNumber,
    String? seat,
    BoardingStatus? status,
    bool? isSelected,
  }) {
    return Boarding(
      name: name ?? this.name,
      docNumber: docNumber ?? this.docNumber,
      seat: seat ?? this.seat,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
