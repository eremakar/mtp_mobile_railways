class RouteSheetSearchCache {
  RouteSheetSearchCache._();

  static const Duration ttl = Duration(minutes: 5);

  static final Map<String, _CacheEntry> _store = {};

  static T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.at) > ttl) {
      _store.remove(key);
      return null;
    }
    return entry.value as T;
  }

  static void set<T>(String key, T value) {
    _store[key] = _CacheEntry(value, DateTime.now());
  }

  static void remove(String key) => _store.remove(key);

  static void invalidate() => _store.clear();
}

class _CacheEntry {
  _CacheEntry(this.value, this.at);

  final Object? value;
  final DateTime at;
}
