import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/l10n/app_localizations.dart';
import 'package:ezan_asistani/services/tasbih_mode_service.dart';
import 'package:ezan_asistani/services/gamification_service.dart' as gamification_service;

class TasbihDhikr {
  const TasbihDhikr({
    required this.id,
    required this.name,
    required this.target,
    required this.isDefault,
    this.currentCount = 0,
    this.totalCount = 0,
    this.lastReset,
  });

  final String id;
  final String name;
  final int target;
  final bool isDefault;
  final int currentCount;
  final int totalCount;
  final DateTime? lastReset;

  TasbihDhikr copyWith({
    String? name,
    int? target,
    bool? isDefault,
    int? currentCount,
    int? totalCount,
    DateTime? lastReset,
  }) {
    return TasbihDhikr(
      id: id,
      name: name ?? this.name,
      target: target ?? this.target,
      isDefault: isDefault ?? this.isDefault,
      currentCount: currentCount ?? this.currentCount,
      totalCount: totalCount ?? this.totalCount,
      lastReset: lastReset ?? this.lastReset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target': target,
      'isDefault': isDefault,
      'currentCount': currentCount,
      'totalCount': totalCount,
      'lastReset': lastReset?.toIso8601String(),
    };
  }

  factory TasbihDhikr.fromMap(Map<String, dynamic> map) {
    return TasbihDhikr(
      id: map['id'] as String,
      name: map['name'] as String,
      target: (map['target'] as num).toInt(),
      isDefault: map['isDefault'] as bool? ?? false,
      currentCount: (map['currentCount'] as num?)?.toInt() ?? 0,
      totalCount: (map['totalCount'] as num?)?.toInt() ?? 0,
      lastReset: map['lastReset'] != null
          ? DateTime.tryParse(map['lastReset'] as String)
          : null,
    );
  }

  static List<TasbihDhikr> defaults() {
    final now = DateTime.now();
    return [
      TasbihDhikr(
        id: 'subhanallah',
        name: 'Subhanallah',
        target: 33,
        isDefault: true,
        lastReset: now,
      ),
      TasbihDhikr(
        id: 'elhamdulillah',
        name: 'Elhamdulillah',
        target: 33,
        isDefault: true,
        lastReset: now,
      ),
      TasbihDhikr(
        id: 'allahu_ekber',
        name: 'Allahu Ekber',
        target: 33,
        isDefault: true,
        lastReset: now,
      ),
    ];
  }
}

class Zikirmatik extends StatefulWidget {
  const Zikirmatik({super.key});

  @override
  State<Zikirmatik> createState() => _ZikirmatikState();
}

class _ZikirmatikState extends State<Zikirmatik>
    with SingleTickerProviderStateMixin {
  static const _dhikrsKey = 'tasbih_dhikrs';
  static const _selectedDhikrKey = 'tasbih_selected_dhikr';
  static const _soundEnabledKey = 'tasbih_sound_enabled';
  static const _vibrationEnabledKey = 'tasbih_vibration_enabled';
  static const _dailyCountsKey = 'tasbih_daily_counts';
  static const _totalZikirKey = 'toplam_zikir';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  SharedPreferences? _prefs;
  bool _loading = true;

  List<TasbihDhikr> _dhikrs = [];
  String? _selectedDhikrId;
  Map<String, int> _dailyCounts = {};
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  final TasbihModeService _modeService = TasbihModeService.instance;
  late VoidCallback _camiiListener;
  late VoidCallback _muteListener;
  bool _camiiModeEnabled = false;
  bool _notificationsMuted = false;

  Future<void> _silenceFeedbackForCamii() async {
    if (_soundEnabled) {
      await _toggleSound(false);
    }
    if (_vibrationEnabled) {
      await _toggleVibration(false);
    }
  }

  Widget _buildSpecialDayCard(AppLocalizations loc) {
    final isFriday = _modeService.isFriday;
    final title = isFriday
        ? loc.translate('special_day_mode_cuma')
        : loc.translate('special_day_mode_kandil');
    final banner = isFriday
        ? loc.translate('special_day_friday_banner')
        : loc.translate('special_day_kandil_banner');

    final gradient = LinearGradient(
      colors: isFriday
          ? [Colors.orange.shade300, AppTheme.primaryYellow]
          : [Colors.deepPurple.shade200, Colors.pink.shade200],
    );

    final duas = [
      loc.translate('special_day_dua_salavat'),
      loc.translate('special_day_dua_tesbih'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            banner,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            loc.translate('tasbih_special_dua_note'),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            loc.translate('special_day_duas_title'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...duas.map(
            (dua) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Text(
                      dua,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCamiiMode(bool value, AppLocalizations loc) async {
    _modeService.setCamiiMode(value);
    if (mounted) {
      setState(() {
        _camiiModeEnabled = value;
      });
    }

    if (value) {
      await _silenceFeedbackForCamii();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('camii_mode_enabled_message')),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('camii_mode_disabled_message')),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleNotificationsMute(
      bool value, AppLocalizations loc) async {
    _modeService.setNotificationsMuted(value);
    if (mounted) {
      setState(() {
        _notificationsMuted = value;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? loc.translate('tasbih_notifications_muted_message')
              : loc.translate('tasbih_notifications_unmuted_message'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  TasbihDhikr? get _selectedDhikr {
    if (_selectedDhikrId == null) return null;
    return _dhikrs.firstWhere(
      (dhikr) => dhikr.id == _selectedDhikrId,
      orElse: () =>
          _dhikrs.isEmpty ? TasbihDhikr.defaults().first : _dhikrs.first,
    );
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _animationController.reverse();
          }
        }),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();

    _soundEnabled = _prefs!.getBool(_soundEnabledKey) ?? true;
    _vibrationEnabled = _prefs!.getBool(_vibrationEnabledKey) ?? true;

    final storedDhikrs = _prefs!.getString(_dhikrsKey);
    if (storedDhikrs == null) {
      _dhikrs = TasbihDhikr.defaults();
      await _saveDhikrs();
    } else {
      final dynamic decoded = json.decode(storedDhikrs);
      if (decoded is List) {
        _dhikrs = decoded
            .map((entry) =>
                TasbihDhikr.fromMap(Map<String, dynamic>.from(entry as Map)))
            .toList();
      }
      if (_dhikrs.isEmpty) {
        _dhikrs = TasbihDhikr.defaults();
      }
    }

    _selectedDhikrId = _prefs!.getString(_selectedDhikrKey) ?? _dhikrs.first.id;

    final storedDailyCounts = _prefs!.getString(_dailyCountsKey);
    if (storedDailyCounts != null) {
      final dynamic decoded = json.decode(storedDailyCounts);
      if (decoded is Map) {
        _dailyCounts = decoded.map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        );
      }
    }

    await _modeService.initialise();
    _camiiModeEnabled = _modeService.camiiModeEnabled.value;
    _notificationsMuted = _modeService.notificationsMuted.value;
    _camiiListener = () {
      final enabled = _modeService.camiiModeEnabled.value;
      if (enabled) {
        unawaited(_silenceFeedbackForCamii());
      }
      if (mounted) {
        setState(() {
          _camiiModeEnabled = enabled;
        });
      }
    };
    _muteListener = () {
      if (mounted) {
        setState(() {
          _notificationsMuted = _modeService.notificationsMuted.value;
        });
      }
    };
    _modeService.camiiModeEnabled.addListener(_camiiListener);
    _modeService.notificationsMuted.addListener(_muteListener);

    await _modeService.maybeShowSpecialDayNotification();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _modeService.camiiModeEnabled.removeListener(_camiiListener);
    _modeService.notificationsMuted.removeListener(_muteListener);
    super.dispose();
  }

  Future<void> _saveDhikrs() async {
    if (_prefs == null) return;
    final encoded = json.encode(_dhikrs.map((dhikr) => dhikr.toMap()).toList());
    await _prefs!.setString(_dhikrsKey, encoded);
  }

  Future<void> _saveDailyCounts() async {
    if (_prefs == null) return;
    await _prefs!.setString(_dailyCountsKey, json.encode(_dailyCounts));
  }

  Future<void> _updateToplamZikir(int delta) async {
    if (_prefs == null) return;
    final mevcut = _prefs!.getInt(_totalZikirKey) ?? 0;
    await _prefs!.setInt(_totalZikirKey, mevcut + delta);
  }

  Future<void> _handleGamificationForZikir(int delta) async {
    try {
      final current =
          await gamification_service.GamificationService.getAchievement('zikir_total');
      final next = current + delta;
      await gamification_service.GamificationService.recordAchievement(
        'zikir_total',
        next,
      );

      if (delta > 0) {
        await gamification_service.GamificationService.addPoints('zikir', delta);
      }

      if (next >= 1000) {
        await gamification_service.GamificationService.addBadge('zikr_1000');
      }
      if (next >= 10000) {
        await gamification_service.GamificationService.addBadge('zikr_10000');
      }
    } catch (_) {
      // ignore
    }
  }

  int _todayZikirCount() {
    final todayKey = _dateKey(DateTime.now());
    return _dailyCounts[todayKey] ?? 0;
  }

  int _totalZikirCount() {
    return _prefs?.getInt(_totalZikirKey) ?? 0;
  }

  Future<void> _selectDhikr(String id) async {
    setState(() {
      _selectedDhikrId = id;
    });
    if (_prefs != null) {
      await _prefs!.setString(_selectedDhikrKey, id);
    }
  }

  Future<void> _toggleSound(bool value) async {
    setState(() {
      _soundEnabled = value;
    });
    if (_prefs != null) {
      await _prefs!.setBool(_soundEnabledKey, value);
    }
  }

  Future<void> _toggleVibration(bool value) async {
    setState(() {
      _vibrationEnabled = value;
    });
    if (_prefs != null) {
      await _prefs!.setBool(_vibrationEnabledKey, value);
    }
  }

  Future<void> _incrementCounter(
      {int amount = 1, bool fromPhysical = false}) async {
    if (_selectedDhikr == null) return;

    final dhikr = _selectedDhikr!;
    final updated = dhikr.copyWith(
      currentCount: dhikr.currentCount + amount,
      totalCount: dhikr.totalCount + amount,
    );

    final index = _dhikrs.indexWhere((element) => element.id == dhikr.id);
    if (index != -1) {
      setState(() {
        _dhikrs[index] = updated;
      });
      await _saveDhikrs();
    }

    _registerDailyCount(amount);
    await _updateToplamZikir(amount);
    await _handleGamificationForZikir(amount);

    if (!fromPhysical) {
      _triggerFeedback();
    }

    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0);
    }

    if (updated.target > 0 && updated.currentCount >= updated.target) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${updated.name} hedefe ulaştı: ${updated.target}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _registerDailyCount(int amount) async {
    final todayKey = _dateKey(DateTime.now());
    final updated = Map<String, int>.from(_dailyCounts);
    updated[todayKey] = (updated[todayKey] ?? 0) + amount;

    // Sadece son 30 günü tut
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    updated.removeWhere((key, value) {
      final parsed = DateTime.tryParse(key);
      return parsed != null && parsed.isBefore(cutoff);
    });

    setState(() {
      _dailyCounts = updated;
    });

    await _saveDailyCounts();
  }

  Future<void> _resetCurrentDhikr() async {
    if (_selectedDhikr == null) return;

    final dhikr = _selectedDhikr!;
    final index = _dhikrs.indexWhere((element) => element.id == dhikr.id);
    if (index == -1) return;

    setState(() {
      _dhikrs[index] = dhikr.copyWith(
        currentCount: 0,
        lastReset: DateTime.now(),
      );
    });
    await _saveDhikrs();
  }

  Future<void> _addOrEditDhikr({TasbihDhikr? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final targetController =
        TextEditingController(text: (existing?.target ?? 33).toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Yeni Zikir Ekle' : 'Zikri Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Zikir adı',
                  hintText: 'Örn: Lâ ilâhe illallah',
                ),
                maxLength: 40,
              ),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(
                  labelText: 'Hedef',
                  hintText: 'Örn: 33, 100, 1000',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final name = nameController.text.trim();
    final target = int.tryParse(targetController.text.trim());

    if (name.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir ad ve hedef girin.')),
      );
      return;
    }

    if (existing == null) {
      final newDhikr = TasbihDhikr(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        target: target,
        isDefault: false,
        lastReset: DateTime.now(),
      );
      setState(() {
        _dhikrs.add(newDhikr);
        _selectedDhikrId = newDhikr.id;
      });
    } else {
      final index = _dhikrs.indexWhere((element) => element.id == existing.id);
      if (index != -1) {
        setState(() {
          _dhikrs[index] = existing.copyWith(name: name, target: target);
        });
      }
    }

    await _saveDhikrs();
    if (_prefs != null && _selectedDhikrId != null) {
      await _prefs!.setString(_selectedDhikrKey, _selectedDhikrId!);
    }
  }

  Future<void> _removeDhikr(TasbihDhikr dhikr) async {
    if (dhikr.isDefault) return;

    setState(() {
      _dhikrs.removeWhere((element) => element.id == dhikr.id);
      if (_selectedDhikrId == dhikr.id) {
        _selectedDhikrId = _dhikrs.isNotEmpty ? _dhikrs.first.id : null;
      }
    });

    await _saveDhikrs();
    if (_prefs != null && _selectedDhikrId != null) {
      await _prefs!.setString(_selectedDhikrKey, _selectedDhikrId!);
    }
  }

  Future<void> _logPhysicalCount() async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fiziksel Tesbih Sayısı'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Eklenilecek sayı',
              hintText: 'Örn: 33',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                Navigator.of(context).pop(value);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );

    if (result == null || result <= 0) return;
    await _incrementCounter(amount: result, fromPhysical: true);

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(loc.translate('tasbih_physical_added_message',
              params: {'count': result.toString()}))),
    );
  }

  void _triggerFeedback() {
    if (_camiiModeEnabled) {
      return;
    }

    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    if (_vibrationEnabled) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 35, amplitude: 128);
        }
      });
    }
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String();
  }

  String _formatLastReset(DateTime? date, AppLocalizations loc) {
    if (date == null) return loc.translate('tasbih_last_reset_never');

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return loc.translate('tasbih_last_reset_days',
          params: {'count': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return loc.translate('tasbih_last_reset_hours',
          params: {'count': difference.inHours.toString()});
    } else if (difference.inMinutes > 0) {
      return loc.translate('tasbih_last_reset_minutes',
          params: {'count': difference.inMinutes.toString()});
    } else {
      return loc.translate('tasbih_last_reset_just_now');
    }
  }

  List<BarChartGroupData> _buildChartData() {
    final now = DateTime.now();
    final groups = <BarChartGroupData>[];

    for (int i = 6; i >= 0; i--) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = _dateKey(day);
      final value = (_dailyCounts[key] ?? 0).toDouble();
      final x = 6 - i;

      groups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: value,
              width: 12,
              borderRadius: BorderRadius.circular(4),
              color: AppTheme.primaryYellow,
            ),
          ],
        ),
      );
    }

    return groups;
  }

  Widget _buildBarTitles(double value, TitleMeta meta) {
    final now = DateTime.now();
    final index = value.toInt();
    if (index < 0 || index > 6) {
      return const SizedBox();
    }

    final date = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6 - index));
    final label = '${date.day}.${date.month}';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget _buildCounterTab() {
    final loc = AppLocalizations.of(context);
    final selected = _selectedDhikr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bugün',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _todayZikirCount().toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Toplam',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _totalZikirCount().toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_modeService.isSpecialDay) ...[
            _buildSpecialDayCard(loc),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selected?.id,
                  decoration: InputDecoration(
                    labelText: loc.translate('tasbih_select_label'),
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(loc.translate('tasbih_select_hint')),
                  items: _dhikrs
                      .map(
                        (dhikr) => DropdownMenuItem<String>(
                          value: dhikr.id,
                          child: Text('${dhikr.name} (${dhikr.target})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectDhikr(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text(loc.translate('camii_mode_title')),
                  subtitle: Text(loc.translate('camii_mode_description')),
                  value: _camiiModeEnabled,
                  onChanged: (value) => _toggleCamiiMode(value, loc),
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  title: Text(loc.translate('notifications_mute_title')),
                  subtitle:
                      Text(loc.translate('notifications_mute_description')),
                  value: _notificationsMuted,
                  onChanged: (value) => _toggleNotificationsMute(value, loc),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppTheme.primaryYellow.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    selected?.name ?? loc.translate('tasbih_no_selection'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selected != null
                        ? '${loc.translate('tasbih_goal_label')}: ${selected.target} • ${loc.translate('tasbih_total_label')}: ${selected.totalCount}'
                        : '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: selected == null || selected.target == 0
                        ? 0
                        : (selected.currentCount / selected.target)
                            .clamp(0.0, 1.0),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.primaryYellow,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selected != null
                        ? '${selected.currentCount} / ${selected.target}'
                        : '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatLastReset(selected?.lastReset, loc),
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selected != null)
            Column(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: AppTheme.primaryYellow,
                        foregroundColor: Colors.black,
                        elevation: 6,
                      ),
                      onPressed: _incrementCounter,
                      child: const Text(
                        '+1',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _incrementCounter(amount: 10),
                      icon: const Icon(Icons.exposure_plus_1),
                      label: Text(loc.translate('tasbih_plus_ten')),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetCurrentDhikr,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.translate('tasbih_reset')),
                    ),
                    OutlinedButton.icon(
                      onPressed: _logPhysicalCount,
                      icon: const Icon(Icons.developer_board),
                      label: Text(loc.translate('tasbih_physical_add')),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 24),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text(loc.translate('tasbih_feedback_sound_title')),
                  subtitle:
                      Text(loc.translate('tasbih_feedback_sound_subtitle')),
                  value: _soundEnabled,
                  onChanged:
                      _camiiModeEnabled ? null : (value) => _toggleSound(value),
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  title: Text(loc.translate('tasbih_feedback_vibration_title')),
                  subtitle:
                      Text(loc.translate('tasbih_feedback_vibration_subtitle')),
                  value: _vibrationEnabled,
                  onChanged: _camiiModeEnabled
                      ? null
                      : (value) => _toggleVibration(value),
                ),
                if (_camiiModeEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.translate('tasbih_feedback_disabled_camii'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrListTab() {
    final loc = AppLocalizations.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _dhikrs.length + 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              loc.translate('tasbih_tab_dhikrs'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }

        final adjustedIndex = index - 1;
        if (adjustedIndex == _dhikrs.length) {
          return OutlinedButton.icon(
            onPressed: () => _addOrEditDhikr(),
            icon: const Icon(Icons.add),
            label: Text(loc.translate('tasbih_add_custom')),
          );
        }

        final dhikr = _dhikrs[adjustedIndex];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: Colors.black,
              child: Text(
                dhikr.target.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(dhikr.name),
            subtitle: Text(
                '${loc.translate('tasbih_stats_current')}: ${dhikr.currentCount}  •  ${loc.translate('tasbih_stats_total')}: ${dhikr.totalCount}\n${_formatLastReset(dhikr.lastReset, loc)}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedDhikrId == dhikr.id)
                  const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'select':
                        _selectDhikr(dhikr.id);
                        break;
                      case 'edit':
                        _addOrEditDhikr(existing: dhikr);
                        break;
                      case 'delete':
                        _removeDhikr(dhikr);
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'select',
                        child: Text(loc.translate('tasbih_list_select')),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(loc.translate('tasbih_list_edit')),
                      ),
                      if (!dhikr.isDefault)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(loc.translate('tasbih_list_delete')),
                        ),
                    ];
                  },
                ),
              ],
            ),
            onTap: () => _selectDhikr(dhikr.id),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final loc = AppLocalizations.of(context);
    final barGroups = _buildChartData();
    final selected = _selectedDhikr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: barGroups.isEmpty
                    ? Center(child: Text(loc.translate('tasbih_stats_empty')))
                    : BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(enabled: true),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: 10,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: _buildBarTitles),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: barGroups,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selected != null)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${loc.translate('tasbih_stats_current')}: ${selected.currentCount}'),
                    Text(
                        '${loc.translate('tasbih_stats_total')}: ${selected.totalCount}'),
                    Text(_formatLastReset(selected.lastReset, loc)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dhikrs
                .map(
                  (dhikr) => Chip(
                    label: Text('${dhikr.name}: ${dhikr.totalCount}'),
                    backgroundColor: dhikr.id == _selectedDhikrId
                        ? AppTheme.primaryYellow.withOpacity(0.3)
                        : Colors.grey.shade200,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('tasbih_title')),
          bottom: TabBar(
            tabs: [
              Tab(
                  icon: const Icon(Icons.touch_app),
                  text: loc.translate('tasbih_tab_counter')),
              Tab(
                  icon: const Icon(Icons.menu_book),
                  text: loc.translate('tasbih_tab_dhikrs')),
              Tab(
                  icon: const Icon(Icons.bar_chart),
                  text: loc.translate('tasbih_tab_stats')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCounterTab(),
            _buildDhikrListTab(),
            _buildStatsTab(),
          ],
        ),
      ),
    );
  }
}
