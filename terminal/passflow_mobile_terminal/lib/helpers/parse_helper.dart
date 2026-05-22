import 'package:intl/intl.dart';

class ParseHelper {
  static DateTime? parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  static String? parseDateWithFormat(dynamic v, String format) {
    if (v == null) return null;
    if (v is DateTime) return DateFormat(format).format(v);
    final s = v.toString();
    if (s.isEmpty) return null;
    try {
      final p = DateTime.parse(s);
      return DateFormat(format).format(p);
    } catch (_) {
      return null;
    }
  }

  static int? asNulableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static int asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String? asStringOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static int? asIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String normalizeIin(Object? v) {
    final s = v?.toString() ?? '';
    // Оставляем только цифры (из "ИИ590923401589" -> "590923401589")
    return s.replaceAll(RegExp(r'\D+'), '').padLeft(12, '0');
  }

  static String normalizeFullName(Object? v) {
    var s = (v ?? '').toString();

    // 1) "=" -> пробел
    s = s.replaceAll('=', ' ');

    // 2) Удалить всё, кроме букв/пробелов/дефисов/апострофов
    s = s.replaceAll(RegExp(r"[^\p{L}\s\-'’]+", unicode: true), '');

    // 3) Удалить висячие дефисы по краям
    s = s.replaceAll(RegExp(r"(^|\s)[\-–—]+(\s|$)"), ' ');

    // 4) Схлопнуть повторы пробелов/дефисов
    s = s
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\-+'), '-')
        .trim();

    // 5) (опционально) Тайтлкейс:
    // s = s.split(' ').map((w) => w.split('-').map(_cap).join('-')).join(' ');

    return s;
  }

  /// "КУРМАНГАЗИНА ЗАМЗАГУЛЬ ЕСЕНКЕЛДИЕВНА" -> "КУРМАНГАЗИНА З.Е"
  /// "=" и лишние символы убираются; фамилия UPPERCASE, инициалы из 1-й буквы слов.
  /// Если отчества нет: "Иванова Анна" -> "ИВАНОВА А."
  static String abbreviateFullName(Object? v) {
    var s = (v ?? '').toString();

    // Нормализация шума: "=" -> пробел, убираем посторонние символы
    s = s.replaceAll('=', ' ');
    s = s.replaceAll(RegExp(r"[^\p{L}\s\-’']", unicode: true), '');
    // Убираем висячие дефисы и схлопываем пробелы
    s = s.replaceAll(RegExp(r"(^|\s)[\-–—]+(\s|$)"), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (s.isEmpty) return '';

    final parts = s.split(' ');
    final surname = parts.first.toUpperCase();

    String? initial(String? word) {
      if (word == null || word.isEmpty) return null;
      final m = RegExp(r'\p{L}', unicode: true).firstMatch(word);
      return m != null ? m.group(0)!.toUpperCase() : null;
    }

    final i1 = parts.length >= 2 ? initial(parts[1]) : null; // имя
    final i2 = parts.length >= 3 ? initial(parts[2]) : null; // отчество

    if (i1 == null && i2 == null) return surname;
    if (i2 == null) return '$surname ${i1}.'; // одна инициала с точкой
    return '$surname ${i1}.${i2}'; // как просили: без точки после второй
  }
}
