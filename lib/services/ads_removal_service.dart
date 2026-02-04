import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsRemovalService {
  static const String _adsRemovedKey = 'ads_removed';

  static final ValueNotifier<bool> adsRemoved = ValueNotifier<bool>(false);

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    adsRemoved.value = prefs.getBool(_adsRemovedKey) ?? false;
  }

  static Future<void> setAdsRemoved(bool removed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsRemovedKey, removed);
    adsRemoved.value = removed;
  }

  static Future<bool> getAdsRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adsRemovedKey) ?? false;
  }
}
