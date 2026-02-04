import 'package:flutter/foundation.dart';

class TasbihModeService {
  static final TasbihModeService _instance = TasbihModeService._internal();

  factory TasbihModeService() {
    return _instance;
  }

  TasbihModeService._internal();

  static TasbihModeService get instance => _instance;

  final ValueNotifier<bool> camiiModeEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<bool> notificationsMuted = ValueNotifier<bool>(false);
  bool _isFriday = false;
  bool _isSpecialDay = false;

  Future<void> initialize() async {
    // Initialization placeholder
  }

  Future<void> initialise() async {
    // British spelling alias
    await initialize();
  }

  void setCamiiModeEnabled(bool enabled) {
    camiiModeEnabled.value = enabled;
  }

  void setCamiiMode(bool enabled) {
    setCamiiModeEnabled(enabled);
  }

  void setNotificationsMuted(bool muted) {
    notificationsMuted.value = muted;
  }

  bool get isFriday => _isFriday;
  bool get isSpecialDay => _isSpecialDay;

  Future<void> maybeShowSpecialDayNotification() async {
    // Placeholder
  }
}
