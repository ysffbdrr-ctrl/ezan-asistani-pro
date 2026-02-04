import 'package:shared_preferences/shared_preferences.dart';

class AyarlarService {
  static final AyarlarService _instance = AyarlarService._internal();
  factory AyarlarService() => _instance;
  AyarlarService._internal();

  // Ayar anahtarları
  static const String _bildirimlerAktifKey = 'bildirimler_aktif';
  static const String _sesliUyariKey = 'sesli_uyari';
  static const String _titresimKey = 'titresim';
  static const String _bildirimSuresiKey = 'bildirim_suresi';
  static const String _secilenTemaKey = 'secilen_tema';
  static const String _karanlikModKey = 'karanlik_mod';
  static const String _buyukYaziKey = 'buyuk_yazi';
  static const String _otomatikKonumKey = 'otomatik_konum';
  static const String _manuelSehirKey = 'manuel_sehir';
  static const String _manuelLatKey = 'manuel_lat';
  static const String _manuelLonKey = 'manuel_lon';
  static const String _use12HourFormatKey = 'time_format_12h';

  // Varsayılan değerler
  static const bool _defaultBildirimlerAktif = true;
  static const bool _defaultSesliUyari = true;
  static const bool _defaultTitresim = true;
  static const int _defaultBildirimSuresi = 10;
  static const String _defaultSecilenTema = 'Sarı';
  static const bool _defaultKaranlikMod = false;
  static const bool _defaultBuyukYazi = false;
  static const bool _defaultOtomatikKonum = true;
  static const bool _defaultUse12HourFormat = false;

  // Getters
  Future<bool> get bildirimlerAktif async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bildirimlerAktifKey) ?? _defaultBildirimlerAktif;
  }

  Future<bool> get sesliUyari async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sesliUyariKey) ?? _defaultSesliUyari;
  }

  Future<bool> get titresim async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_titresimKey) ?? _defaultTitresim;
  }

  Future<int> get bildirimSuresi async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bildirimSuresiKey) ?? _defaultBildirimSuresi;
  }

  Future<String> get secilenTema async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_secilenTemaKey) ?? _defaultSecilenTema;
  }

  Future<bool> get karanlikMod async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_karanlikModKey) ?? _defaultKaranlikMod;
  }

  Future<bool> get buyukYazi async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_buyukYaziKey) ?? _defaultBuyukYazi;
  }

  Future<bool> get otomatikKonum async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_otomatikKonumKey) ?? _defaultOtomatikKonum;
  }

  Future<String?> get manuelSehir async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_manuelSehirKey);
  }

  Future<double?> get manuelLat async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_manuelLatKey);
  }

  Future<double?> get manuelLon async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_manuelLonKey);
  }

  Future<bool> get use12HourFormat async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_use12HourFormatKey) ?? _defaultUse12HourFormat;
  }

  // Setters
  Future<void> setBildirimlerAktif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bildirimlerAktifKey, value);
  }

  Future<void> setSesliUyari(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sesliUyariKey, value);
  }

  Future<void> setTitresim(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_titresimKey, value);
  }

  Future<void> setBildirimSuresi(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bildirimSuresiKey, value);
  }

  Future<void> setSecilenTema(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_secilenTemaKey, value);
  }

  Future<void> setKaranlikMod(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_karanlikModKey, value);
  }

  Future<void> setBuyukYazi(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_buyukYaziKey, value);
  }

  Future<void> setOtomatikKonum(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_otomatikKonumKey, value);
  }

  Future<void> setManuelKonum(String sehir, double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_manuelSehirKey, sehir);
    await prefs.setDouble(_manuelLatKey, lat);
    await prefs.setDouble(_manuelLonKey, lon);
  }

  Future<void> clearManuelKonum() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_manuelSehirKey);
    await prefs.remove(_manuelLatKey);
    await prefs.remove(_manuelLonKey);
  }

  Future<void> setUse12HourFormat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_use12HourFormatKey, value);
  }

  // Tüm ayarları varsayılan değerlere döndür
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Tüm ayarları bir Map olarak al
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'bildirimlerAktif': await bildirimlerAktif,
      'sesliUyari': await sesliUyari,
      'titresim': await titresim,
      'bildirimSuresi': await bildirimSuresi,
      'secilenTema': await secilenTema,
      'karanlikMod': await karanlikMod,
      'buyukYazi': await buyukYazi,
      'otomatikKonum': await otomatikKonum,
      'use12HourFormat': await use12HourFormat,
    };
  }
}
