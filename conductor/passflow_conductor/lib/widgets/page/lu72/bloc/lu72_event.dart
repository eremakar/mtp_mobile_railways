import 'package:meta/meta.dart';

@immutable
sealed class Lu72Event {
  const Lu72Event();
}

final class Lu72LoadRequested extends Lu72Event {
  const Lu72LoadRequested();
}

final class Lu72WagonSelected extends Lu72Event {
  const Lu72WagonSelected(this.wagon);
  final String wagon;
}

final class Lu72SaveRequested extends Lu72Event {
  const Lu72SaveRequested({
    required this.stationId,
    required this.seats,
  });

  final int stationId;
  final Set<int> seats;
}

final class Lu72SummaryMetaSaveRequested extends Lu72Event {
  const Lu72SummaryMetaSaveRequested({
    this.lu72AttendantsCount,
    this.lu72StaffiCount,
  });

  final int? lu72AttendantsCount;
  final int? lu72StaffiCount;
}

final class Lu72ApprovalToggled extends Lu72Event {
  const Lu72ApprovalToggled({required this.approved});
  final bool approved;
}
