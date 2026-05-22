import 'package:intl/intl.dart';

class DateHelper {
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    final String s = value.toString().trim();
    if (s.isEmpty) return null;

    // 1. Пробуем ISO: 2025-08-08
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // 2. Пробуем формат 22.08.2025
    try {
      return DateFormat('dd.MM.yyyy').parse(s);
    } catch (_) {
      return null; // или кинь исключение, если нужно
    }
  }
}
