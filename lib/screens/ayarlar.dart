import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/data/sehirler.dart';
import 'package:ezan_asistani/services/ayarlar_service.dart';
import 'package:ezan_asistani/services/hadith_service.dart';
import 'package:ezan_asistani/services/notification_service.dart';
import 'package:ezan_asistani/services/alarm_service.dart';
import 'package:ezan_asistani/screens/gizlilik_politikasi.dart';
import 'package:ezan_asistani/screens/kullanim_kosullari.dart';
import 'package:ezan_asistani/l10n/app_localizations.dart';
import 'package:ezan_asistani/services/theme_service.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({super.key});

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  // Ayarlar
  bool _bildirimlerAktif = true;
  bool _sesliUyari = true;
  bool _titresim = true;
  int _bildirimSuresi = 10; // dakika
  String _secilenTema = 'Sarı'; // Sarı, Yeşil, Mavi
  bool _karanlikMod = false;
  bool _buyukYazi = false;
  bool _kolayKullanim = false;
  bool _otomatikKonum = true;
  bool _use12HourFormat = false;
  String? _manuelSehir;
  String _secilenDil = 'tr';

  // Hadis ayarları
  bool _gunlukHadisNotificationEnabled = false;
  int _hadisNotificationSaat = 8;
  int _hadisNotificationDakika = 0;

  final _ayarlarService = AyarlarService();

  @override
  void initState() {
    super.initState();
    _yukleAyarlar();
  }

  void _showDilSecimi(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.translate('settings_language_dialog')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDilOption('tr', loc.translate('language_tr'), '🇹🇷', loc),
              _buildDilOption('en', loc.translate('language_en'), '🇬🇧', loc),
              _buildDilOption('ar', loc.translate('language_ar'), '🇸🇦', loc),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('settings_language_close')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDilOption(
      String code, String label, String emoji, AppLocalizations loc) {
    final isSelected = _secilenDil == code;
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () async {
        setState(() {
          _secilenDil = code;
        });
        await _kaydetAyar('selected_language', code);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.translate('settings_language_set_to', params: {
                'language': label,
              })),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Future<void> _yukleAyarlar() async {
    final prefs = await SharedPreferences.getInstance();
    final manuelSehir = await _ayarlarService.manuelSehir;
    final hadithService = HadithService();

    final (hadisHour, hadisDakika) =
        await hadithService.getDailyHadithNotificationTime();

    setState(() {
      _bildirimlerAktif = prefs.getBool('bildirimler_aktif') ?? true;
      _sesliUyari = prefs.getBool('sesli_uyari') ?? true;
      _titresim = prefs.getBool('titresim') ?? true;
      _bildirimSuresi = prefs.getInt('bildirim_suresi') ?? 10;
      _secilenTema = prefs.getString('secilen_tema') ?? 'Sarı';
      _karanlikMod = prefs.getBool('isDarkMode') ?? (prefs.getBool('karanlik_mod') ?? false);
      _buyukYazi = prefs.getBool('buyuk_yazi') ?? false;
      _kolayKullanim = prefs.getBool('easy_mode') ?? false;
      _otomatikKonum = prefs.getBool('otomatik_konum') ?? true;
      _use12HourFormat = prefs.getBool('time_format_12h') ?? false;
      _manuelSehir = manuelSehir;
      _secilenDil = prefs.getString('selected_language') ?? 'tr';
      _gunlukHadisNotificationEnabled =
          prefs.getBool('daily_hadith_notification_enabled') ?? false;
      _hadisNotificationSaat = hadisHour;
      _hadisNotificationDakika = hadisDakika;
    });
  }

  Future<void> _kaydetAyar(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _ayarlariSifirla() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('settings_reset_title')),
        content: Text(AppLocalizations.of(context).translate('settings_reset_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('settings_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              setState(() {
                _bildirimlerAktif = true;
                _sesliUyari = true;
                _titresim = true;
                _bildirimSuresi = 10;
                _secilenTema = 'Sarı';
                _karanlikMod = false;
                _buyukYazi = false;
                _otomatikKonum = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).translate('settings_reset_done')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).translate('settings_reset_confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('drawer_settings')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _ayarlariSifirla,
            tooltip: loc.translate('settings_reset_tooltip'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bildirim Ayarları
          _buildSectionTitle(loc.translate('settings_title_notifications')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(loc.translate('settings_notifications_title')),
                  subtitle: Text(loc.translate('settings_notifications_subtitle')),
                  value: _bildirimlerAktif,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _bildirimlerAktif = value);
                    await _kaydetAyar('bildirimler_aktif', value);

                    if (!value) {
                      final alarmService = AlarmService();
                      await alarmService.cancelAllAlarms();

                      final notificationService = NotificationService();
                      for (int id = 1; id <= 6; id++) {
                        await notificationService.cancelNotification(id + 100);
                      }
                      await notificationService.stopOngoingCountdownNotification();
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.translate('settings_sound_title')),
                  subtitle: Text(loc.translate('settings_sound_subtitle')),
                  value: _sesliUyari,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: _bildirimlerAktif
                      ? (value) {
                          setState(() => _sesliUyari = value);
                          _kaydetAyar('sesli_uyari', value);
                        }
                      : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.translate('settings_vibration_title')),
                  subtitle: Text(loc.translate('settings_vibration_subtitle')),
                  value: _titresim,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: _bildirimlerAktif
                      ? (value) {
                          setState(() => _titresim = value);
                          _kaydetAyar('titresim', value);
                        }
                      : null,
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(loc.translate('settings_notification_lead_time_title')),
                  subtitle: Text(loc.translate(
                    'settings_notification_lead_time_subtitle',
                    params: {
                      'minutes': _bildirimSuresi.toString(),
                    },
                  )),
                  trailing: DropdownButton<int>(
                    value: _bildirimSuresi,
                    items: [5, 10, 15, 20, 30].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(loc.translate('settings_minutes_short', params: {'minutes': value.toString()})),
                      );
                    }).toList(),
                    onChanged: _bildirimlerAktif
                        ? (value) {
                            if (value != null) {
                              setState(() => _bildirimSuresi = value);
                              _kaydetAyar('bildirim_suresi', value);
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Günlük Hadis Bildirimi Ayarları
          _buildSectionTitle(loc.translate('settings_title_daily_hadith')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(loc.translate('settings_daily_hadith_title')),
                  subtitle: Text(loc.translate('settings_daily_hadith_subtitle')),
                  value: _gunlukHadisNotificationEnabled,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _gunlukHadisNotificationEnabled = value);
                    await HadithService()
                        .setDailyHadithNotificationEnabled(value);

                    if (value) {
                      // Aktif yapıyorsa, ilk hadis bildirimini planla
                      final hadithService = HadithService();
                      final todayHadith = await hadithService.getTodayHadith();

                      if (todayHadith != null) {
                        final notificationService = NotificationService();
                        await notificationService
                            .scheduleDailyHadithNotification(
                          hadithText: todayHadith.text,
                          hadithSource: todayHadith.source,
                          hour: _hadisNotificationSaat,
                          minute: _hadisNotificationDakika,
                        );
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              loc.translate(
                                'settings_daily_hadith_scheduled_snackbar',
                                params: {
                                  'time': '${_hadisNotificationSaat.toString().padLeft(2, '0')}:${_hadisNotificationDakika.toString().padLeft(2, '0')}',
                                },
                              ),
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } else {
                      // Kapatıyorsa bildirimi iptal et
                      final notificationService = NotificationService();
                      await notificationService.cancelDailyHadithNotification();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.translate('settings_daily_hadith_disabled_snackbar')),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
                if (_gunlukHadisNotificationEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: Text(loc.translate('settings_daily_hadith_pick_time_title')),
                    subtitle: Text(
                        '${_hadisNotificationSaat.toString().padLeft(2, '0')}:${_hadisNotificationDakika.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: _hadisNotificationSaat,
                            minute: _hadisNotificationDakika),
                      );

                      if (picked != null) {
                        setState(() {
                          _hadisNotificationSaat = picked.hour;
                          _hadisNotificationDakika = picked.minute;
                        });

                        // Yeni zamanı kaydet
                        await HadithService().setDailyHadithNotificationTime(
                            picked.hour, picked.minute);

                        // Bildirimi yeniden planla
                        final hadithService = HadithService();
                        final todayHadith =
                            await hadithService.getTodayHadith();

                        if (todayHadith != null) {
                          final notificationService = NotificationService();
                          await notificationService
                              .scheduleDailyHadithNotification(
                            hadithText: todayHadith.text,
                            hadithSource: todayHadith.source,
                            hour: picked.hour,
                            minute: picked.minute,
                          );
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.translate(
                                  'settings_daily_hadith_time_updated_snackbar',
                                  params: {
                                    'time': '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                                  },
                                ),
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Görünüm Ayarları
          _buildSectionTitle(loc.translate('settings_title_appearance')),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(loc.translate('settings_theme_color')),
                  subtitle: Text(loc.translate('settings_theme_selected', params: {'theme': _secilenTema})),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTemaSecimi(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.translate('settings_dark_mode_title')),
                  subtitle: Text(loc.translate('settings_dark_mode_subtitle')),
                  value: _karanlikMod,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _karanlikMod = value);
                    await ThemeService.instance.setDarkMode(value);
                    await _kaydetAyar('karanlik_mod', value);
                    await _kaydetAyar('isDarkMode', value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.translate('settings_large_text_title')),
                  subtitle: Text(_buyukYazi
                      ? loc.translate('settings_large_text_enabled')
                      : loc.translate('settings_large_text_disabled')),
                  value: _buyukYazi,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _buyukYazi = value);
                    await _kaydetAyar('buyuk_yazi', value);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? loc.translate('settings_large_text_snackbar_on')
                              : loc.translate(
                                  'settings_large_text_snackbar_off')),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // Drawer'ı kapat ve ana ekrana dön
                      Navigator.pop(context);
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.translate('settings_easy_mode_title')),
                  subtitle: Text(loc.translate('settings_easy_mode_subtitle')),
                  value: _kolayKullanim,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _kolayKullanim = value);
                    await _kaydetAyar('easy_mode', value);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? loc.translate('settings_easy_mode_on_snackbar')
                                : loc.translate('settings_easy_mode_off_snackbar'),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.translate('settings_time_format_title')),
                  subtitle: Text(
                    _use12HourFormat
                        ? loc.translate('settings_time_format_12h')
                        : loc.translate('settings_time_format_24h'),
                  ),
                  value: _use12HourFormat,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _use12HourFormat = value);
                    await _kaydetAyar('time_format_12h', value);
                    await _ayarlarService.setUse12HourFormat(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(loc.translate('settings_language')),
                  subtitle: Text(_dilEtiketi(_secilenDil, loc)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDilSecimi(loc),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Konum Ayarları
          _buildSectionTitle(loc.translate('settings_title_location')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(loc.translate('settings_auto_location_title')),
                  subtitle:
                      Text(loc.translate('settings_auto_location_subtitle')),
                  value: _otomatikKonum,
                  activeThumbColor: AppTheme.primaryYellow,
                  onChanged: (value) async {
                    setState(() => _otomatikKonum = value);
                    await _kaydetAyar('otomatik_konum', value);

                    // Otomatik konum açılırsa manuel konumu temizle
                    if (value) {
                      await _ayarlarService.clearManuelKonum();
                      setState(() => _manuelSehir = null);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                loc.translate('settings_auto_location_feedback')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(loc.translate('settings_city_title')),
                  subtitle: Text(
                      _manuelSehir ?? loc.translate('settings_city_subtitle')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  enabled: !_otomatikKonum,
                  onTap: !_otomatikKonum ? _showSehirSecimi : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Hakkında
          _buildSectionTitle(loc.translate('settings_title_about')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(loc.translate('settings_app_version')),
                  subtitle: const Text('v1.0.0'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BETA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.code, color: AppTheme.primaryYellow),
                  title: Text(loc.translate('settings_developer_title')),
                  subtitle: const Text('XNX'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '💻 Developer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: Text(loc.translate('settings_privacy_policy')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GizlilikPolitikasi(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(loc.translate('settings_terms_of_use')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KullanimKosullari(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(loc.translate('settings_licenses')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showLicensePage(context: context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tehlikeli Bölge
          _buildSectionTitle(loc.translate('settings_title_danger_zone'), color: Colors.red),
          Card(
            color: Colors.red[50],
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    loc.translate('settings_delete_all_title'),
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(loc.translate('settings_delete_all_subtitle')),
                  onTap: _tumVerileriSil,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _dilEtiketi(String code, AppLocalizations loc) {
    switch (code) {
      case 'en':
        return loc.translate('language_en');
      case 'ar':
        return loc.translate('language_ar');
      case 'tr':
      default:
        return loc.translate('language_tr');
    }
  }

  void _showSehirSecimi() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_city, color: AppTheme.primaryYellow),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).translate('settings_city_select_title')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: turkiyeSehirleri.length + suudiArabistanSehirleri.length,
            itemBuilder: (context, index) {
              final sehir = index < turkiyeSehirleri.length
                  ? turkiyeSehirleri[index]
                  : suudiArabistanSehirleri[index - turkiyeSehirleri.length];
              final isSelected = _manuelSehir == sehir.ad;

              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: isSelected ? AppTheme.primaryYellow : Colors.grey,
                ),
                title: Text(
                  sehir.ad,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryYellow : Colors.black,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: AppTheme.primaryYellow)
                    : null,
                onTap: () async {
                  await _ayarlarService.setManuelKonum(
                    sehir.ad,
                    sehir.lat,
                    sehir.lon,
                  );
                  setState(() => _manuelSehir = sehir.ad);
                  Navigator.pop(context);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate(
                          'settings_city_selected_snackbar',
                          params: {'city': sehir.ad},
                        )),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('settings_close')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.grey[700],
        ),
      ),
    );
  }

  void _showTemaSecimi() async {
    await ThemeService.instance.initialize();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.palette, color: AppTheme.primaryYellow),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).translate('settings_theme_select_title')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.yellow),
                title: Text(AppLocalizations.of(context).translate('settings_theme_light')),
                trailing: _karanlikMod
                    ? null
                    : const Icon(Icons.check_circle, color: Colors.green),
                onTap: () async {
                  try {
                    setState(() {
                      _karanlikMod = false;
                      _secilenTema = AppLocalizations.of(context).translate('settings_theme_light');
                    });
                    await _kaydetAyar('secilen_tema', AppLocalizations.of(context).translate('settings_theme_light'));
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).translate(
                            'settings_theme_changed_snackbar',
                            params: {
                              'theme': AppLocalizations.of(context).translate('settings_theme_light'),
                            },
                          )),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).translate(
                            'settings_theme_change_error',
                            params: {'error': e.toString()},
                          )),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.grey),
                title: Text(AppLocalizations.of(context).translate('settings_theme_dark')),
                trailing: _karanlikMod
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () async {
                  try {
                    setState(() {
                      _karanlikMod = true;
                      _secilenTema = AppLocalizations.of(context).translate('settings_theme_dark');
                    });
                    await _kaydetAyar('secilen_tema', AppLocalizations.of(context).translate('settings_theme_dark'));
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).translate(
                            'settings_theme_changed_snackbar',
                            params: {
                              'theme': AppLocalizations.of(context).translate('settings_theme_dark'),
                            },
                          )),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).translate(
                            'settings_theme_change_error',
                            params: {'error': e.toString()},
                          )),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('settings_close')),
          ),
        ],
      ),
    );
  }

  void _tumVerileriSil() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).translate('settings_delete_warning_title')),
          ],
        ),
        content: Text(AppLocalizations.of(context).translate('settings_delete_warning_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('settings_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).translate('settings_delete_done')),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Uygulamayı yeniden başlat
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).translate('settings_delete_confirm')),
          ),
        ],
      ),
    );
  }
}
