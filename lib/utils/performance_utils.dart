import 'dart:async';

/// Performans yardımcı sınıfları

// Debouncer - Gereksiz API çağrılarını önler
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Throttler - Aşırı sık işlemleri sınırlar
class Throttler {
  final Duration duration;
  bool _isReady = true;

  Throttler({this.duration = const Duration(milliseconds: 300)});

  void call(void Function() action) {
    if (_isReady) {
      _isReady = false;
      action();
      Timer(duration, () {
        _isReady = true;
      });
    }
  }
}

// Cache Manager - Basit cache sistemi
class CacheManager<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration expiry;

  CacheManager({this.expiry = const Duration(minutes: 15)});

  void set(String key, T value) {
    _cache[key] = CacheEntry(value, DateTime.now().add(expiry));
  }

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value;
  }

  void clear() {
    _cache.clear();
  }

  bool has(String key) {
    return get(key) != null;
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiry;

  CacheEntry(this.value, this.expiry);
}
