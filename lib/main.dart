import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/smart_notification_service.dart';
import 'package:ezan_asistani/services/theme_service.dart';
import 'package:ezan_asistani/services/hadith_service.dart';
import 'package:ezan_asistani/services/notification_service.dart';
import 'package:ezan_asistani/screens/intro_screen.dart';
import 'package:ezan_asistani/screens/ezan_vakitleri.dart';
import 'package:ezan_asistani/screens/kible_yonu.dart';
import 'package:ezan_asistani/screens/takvim.dart';
import 'package:ezan_asistani/screens/dualar.dart';
import 'package:ezan_asistani/screens/zekatmatik.dart';
import 'package:ezan_asistani/screens/sosyal_ozellikler.dart';
import 'package:ezan_asistani/screens/zikirmatik.dart';
import 'package:ezan_asistani/screens/namaz_rehberi.dart';
import 'package:ezan_asistani/screens/kuran.dart';
import 'package:ezan_asistani/screens/bugun.dart';
import 'package:ezan_asistani/screens/kuran_ogrenme.dart';
import 'package:ezan_asistani/screens/kuran_radyo.dart';
import 'package:ezan_asistani/screens/namaz_takip.dart';
import 'package:ezan_asistani/screens/gunluk_dua.dart';
import 'package:ezan_asistani/screens/umre_hac_rehberi.dart';
import 'package:ezan_asistani/screens/profil_istatistik.dart';
import 'package:ezan_asistani/screens/islam_quiz.dart';
import 'package:ezan_asistani/screens/bilgi_kartlari.dart';
import 'package:ezan_asistani/screens/gunluk_soru.dart';
import 'package:ezan_asistani/screens/sadaka_yardim.dart';
import 'package:ezan_asistani/screens/ayarlar.dart';
import 'package:ezan_asistani/screens/nearby_mosques.dart';
import 'package:ezan_asistani/screens/hikayeler.dart';
import 'package:ezan_asistani/screens/hadiths.dart';
import 'package:ezan_asistani/screens/ramazan_modu.dart';
import 'package:ezan_asistani/screens/onay_ekrani.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ezan_asistani/l10n/app_localizations.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ezan_asistani/services/tasbih_mode_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ezan_asistani/services/interstitial_ad_service.dart';
import 'package:ezan_asistani/services/rewarded_ad_service.dart';
import 'package:ezan_asistani/services/gamification_service.dart';
import 'package:ezan_asistani/services/ads_removal_service.dart';
import 'package:ezan_asistani/services/payment_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data (for Turkish)
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('ar', null);

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize Alarm Manager
  await AndroidAlarmManager.initialize();

  await MobileAds.instance.initialize();
  InterstitialAdService.instance.preload();
  RewardedAdService.instance.preload();

  await AdsRemovalService.initialize();

  // Prepare tasbih-related shared state
  // Note: TasbihModeService removed due to Firebase dependency

  // Widget izinini kontrol et
  await _checkWidgetPermission();

  // Arka plan izinini kontrol et
  await _checkBackgroundPermission();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable edge-to-edge mode for a modern UI
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set transparent system UI for a seamless look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const EzanAsistaniApp());
}

// Widget izni kontrolü
Future<void> _checkWidgetPermission() async {
  final prefs = await SharedPreferences.getInstance();
  final widgetPermissionAsked =
      prefs.getBool('widget_permission_asked') ?? false;

  if (!widgetPermissionAsked) {
    // İlk açılışta widget izni sorulacak
    await prefs.setBool('widget_permission_asked', true);
  }
}

// Arka plan izni kontrolü
Future<void> _checkBackgroundPermission() async {
  final prefs = await SharedPreferences.getInstance();
  final backgroundPermissionAsked =
      prefs.getBool('background_permission_asked') ?? false;

  if (!backgroundPermissionAsked) {
    // İlk açılışta arka plan izni iste
    await prefs.setBool('background_permission_asked', true);

    // Android için arka plan konum izni kontrolü
    if (await Permission.locationAlways.isDenied) {
      await Permission.locationAlways.request();
    }

    // iOS için arka plan yenileme izni
    if (await Permission.backgroundRefresh.isDenied) {
      await Permission.backgroundRefresh.request();
    }
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.screen,
  });

  final String title;
  final IconData icon;
  final Widget screen;
}

class EzanAsistaniApp extends StatefulWidget {
  const EzanAsistaniApp({super.key});

  @override
  State<EzanAsistaniApp> createState() => _EzanAsistaniAppState();
}

class _EzanAsistaniAppState extends State<EzanAsistaniApp> {
  ThemeMode _themeMode = ThemeMode.light;
  double _textScaleFactor = 1.0;
  bool _easyMode = false;
  bool _yukleniyor = true;
  bool _introShown = false;
  bool _termsAccepted = false;
  Locale _locale = const Locale('tr');

  VoidCallback? _themeListener;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadTextScale();
    _loadEasyMode();
    _loadLocale();
    _checkFirstLaunch();
    _initializeDailyHadithNotification();
  }

  // Günlük hadis bildirimini başlat
  Future<void> _initializeDailyHadithNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDailyHadithEnabled =
          prefs.getBool('daily_hadith_notification_enabled') ?? false;

      if (isDailyHadithEnabled) {
        // Eğer enabled ise, ilk kez kullanıcının tercih ettiği saate göre planla
        final hadithService = HadithService();
        final todayHadith = await hadithService.getTodayHadith();

        if (todayHadith != null) {
          final (hour, minute) =
              await hadithService.getDailyHadithNotificationTime();
          final notificationService = NotificationService();
          await notificationService.scheduleDailyHadithNotification(
            hadithText: todayHadith.text,
            hadithSource: todayHadith.source,
            hour: hour,
            minute: minute,
          );
        }
      }
    } catch (e) {
      print('Hadis bildirimi başlatma hatası: $e');
    }
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final introShown = prefs.getBool('intro_shown') ?? false;
    final termsAccepted = prefs.getBool('kosullar_kabul_edildi') ?? false;

    setState(() {
      _introShown = introShown;
      _termsAccepted = termsAccepted;
      _yukleniyor = false;
    });
  }

  Future<bool> _checkAuthState() async {
    // Auth service removed - always return false (no sign-in required)
    return false;
  }

  Future<void> _loadThemeMode() async {
    await ThemeService.instance.initialize();
    final notifier = ThemeService.instance.themeModeNotifier;

    _themeListener ??= () {
      if (!mounted) return;
      setState(() {
        _themeMode = notifier.value;
      });
    };

    notifier.removeListener(_themeListener!);
    notifier.addListener(_themeListener!);

    if (mounted) {
      setState(() {
        _themeMode = notifier.value;
      });
    }
  }

  Future<void> _loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    final buyukYazi = prefs.getBool('buyuk_yazi') ?? false;
    setState(() {
      _textScaleFactor = buyukYazi ? 1.2 : 1.0;
    });
  }

  Future<void> _loadEasyMode() async {
    final prefs = await SharedPreferences.getInstance();
    final easy = prefs.getBool('easy_mode') ?? false;
    if (!mounted) return;
    setState(() {
      _easyMode = easy;
    });
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final dilKodu = prefs.getString('selected_language') ?? 'tr';

    Locale yeniLocale;
    switch (dilKodu) {
      case 'en':
        yeniLocale = const Locale('en');
        break;
      case 'ar':
        yeniLocale = const Locale('ar');
        break;
      case 'tr':
      default:
        yeniLocale = const Locale('tr');
        break;
    }

    if (mounted) {
      setState(() {
        _locale = yeniLocale;
      });
    }
  }

  Future<void> _toggleTheme() async {
    await ThemeService.instance.toggleTheme();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'karanlik_mod',
      ThemeService.instance.themeModeNotifier.value == ThemeMode.dark,
    );
  }

  void _reloadSettings() {
    _loadTextScale();
    _loadEasyMode();
    _loadLocale();
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryYellow,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context).translate('app_title') ??
          'Ezan Asistanı Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return _locale;
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
      builder: (context, child) {
        final effectiveScale = _easyMode ? (_textScaleFactor * 1.15) : _textScaleFactor;
        final baseTheme = Theme.of(context);

        final ThemeData themed = _easyMode
            ? baseTheme.copyWith(
                visualDensity: VisualDensity.standard,
                listTileTheme: baseTheme.listTileTheme.copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              )
            : baseTheme;

        return Theme(
          data: themed,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(effectiveScale),
            ),
            child: child!,
          ),
        );
      },
      home: !_introShown
          ? IntroScreen(
              onCompleted: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('intro_shown', true);
                setState(() {
                  _introShown = true;
                });
              },
            )
          : !_termsAccepted
              ? OnayEkrani(
                  onAccepted: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('kosullar_kabul_edildi', true);
                    setState(() {
                      _termsAccepted = true;
                    });
                  },
                )
              : Builder(
                  builder: (context) {
                    // Önce oturum durumunu kontrol et
                    return FutureBuilder<bool>(
                      future: _checkAuthState(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryYellow,
                              ),
                            ),
                          );
                        }

                        if (snapshot.data == true) {
                          // Auth removed - go directly to main screen
                          return MainScreen(
                            onThemeToggle: _toggleTheme,
                            themeMode: _themeMode,
                            onSettingsChanged: _reloadSettings,
                          );
                        }

                        // Auth removed - go directly to main screen
                        return MainScreen(
                          onThemeToggle: _toggleTheme,
                          themeMode: _themeMode,
                          onSettingsChanged: _reloadSettings,
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final VoidCallback onSettingsChanged;

  const MainScreen({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
    required this.onSettingsChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final List<Widget> _screens = [
    const EzanVakitleri(),
    const KibleYonu(),
    const Takvim(),
    const Dualar(),
    const Bugun(),
  ];

  @override
  void initState() {
    super.initState();

    PaymentService.initialize().then((_) {
      _purchaseSubscription?.cancel();
      _purchaseSubscription = PaymentService.getPurchaseStream().listen(
        (purchases) async {
          for (final purchase in purchases) {
            if (purchase.productID != PaymentService.removeAdsProductId) continue;

            if (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) {
              await AdsRemovalService.setAdsRemoved(true);
            }

            if (purchase.pendingCompletePurchase) {
              await InAppPurchase.instance.completePurchase(purchase);
            }
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Google ile giriş sonrası ezan vakitleri ekranına yönlendir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToEzanVakitleri();
    });
  }

  void _navigateToEzanVakitleri() {
    setState(() {
      _currentIndex = 0; // Ezan Vakitleri index
    });
  }

  void _navigateToScreen(Widget screen) async {
    Navigator.pop(context); // Close the drawer

    await InterstitialAdService.instance.maybeShowThen(() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
      // Ayarlar ekranından dönüldüğünde yenile
      widget.onSettingsChanged();
    });
  }

  Widget _buildDrawer(AppLocalizations loc) {
    final drawerItems = [
      _DrawerItem(
        title: loc.translate('drawer_profile_stats'),
        icon: Icons.person,
        screen: const ProfilIstatistik(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_social_features'),
        icon: Icons.group,
        screen: const SosyalOzellikler(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_daily_question'),
        icon: Icons.question_answer,
        screen: const GunlukSoru(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_islam_quiz'),
        icon: Icons.quiz,
        screen: const IslamQuiz(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_info_cards'),
        icon: Icons.auto_stories,
        screen: const BilgiKartlari(),
      ),
      const _DrawerItem(
        title: 'Hz. Muhammed\'in Hadisleri',
        icon: Icons.book,
        screen: Hadiths(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_quran'),
        icon: Icons.menu_book,
        screen: const Kuran(),
      ),
      const _DrawerItem(
        title: 'Ramazan Modu',
        icon: Icons.nightlight_round,
        screen: RamazanModu(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_quran_learning'),
        icon: Icons.school,
        screen: const KuranOgrenme(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_quran_radio'),
        icon: Icons.radio,
        screen: const KuranRadyo(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_prayer_tracking'),
        icon: Icons.check_circle_outline,
        screen: const NamazTakip(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_prayer_guide'),
        icon: Icons.mosque,
        screen: const NamazRehberi(),
      ),
      const _DrawerItem(
        title: 'Eve Yakın Camiler',
        icon: Icons.location_on,
        screen: NearbyMosques(),
      ),
      _DrawerItem(
        title: 'Hikayeler',
        icon: Icons.auto_stories,
        screen: const Hikayeler(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_daily_prayer'),
        icon: Icons.notifications_active,
        screen: const GunlukDua(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_umrah_hajj'),
        icon: Icons.flight_takeoff,
        screen: const UmreHacRehberi(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_zakat'),
        icon: Icons.calculate,
        screen: const Zekatmatik(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_tasbih'),
        icon: Icons.timeline,
        screen: const Zikirmatik(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_charity'),
        icon: Icons.volunteer_activism,
        screen: const SadakaYardim(),
      ),
      _DrawerItem(
        title: loc.translate('drawer_settings'),
        icon: Icons.settings,
        screen: const Ayarlar(),
      ),
    ];

    return Drawer(
      child: ValueListenableBuilder<bool>(
        valueListenable: AdsRemovalService.adsRemoved,
        builder: (context, adsRemoved, _) => ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryYellow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  loc.translate('app_title'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('drawer_tagline'),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...drawerItems.map((item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () => _navigateToScreen(item.screen),
              )),
          const Divider(),
          ListTile(
            leading: Icon(adsRemoved ? Icons.check_circle : Icons.block),
            title: Text(adsRemoved ? 'Reklamlar Kaldırıldı' : 'Reklamları Kaldır'),
            subtitle: Text(adsRemoved ? 'Aktif' : 'Tek seferlik satın alma'),
            enabled: !adsRemoved,
            onTap: adsRemoved
                ? null
                : () async {
                    Navigator.pop(context);

                    final available = await PaymentService.initialize();
                    if (!mounted) return;
                    if (!available) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Satın alma şu an kullanılamıyor.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Reklamları Kaldır'),
                          content: const Text('Uygulamadaki reklamları kaldırmak ister misin?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await PaymentService.restorePurchases();
                              },
                              child: const Text('Geri Yükle'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Vazgeç'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final ok = await PaymentService.purchaseRemoveAds();
                                if (!mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ürün bulunamadı: reklamsiz'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Satın Al'),
                            ),
                          ],
                        );
                      },
                    );
                  },
          ),
          if (!adsRemoved) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Destek Ol (Reklam İzle)'),
              subtitle: const Text('+50 puan'),
              onTap: () async {
                Navigator.pop(context);

                final earned = await RewardedAdService.instance.show();
                if (!mounted) return;

                if (earned) {
                  await GamificationService.addPoints('support_ad', 50);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teşekkürler! +50 puan kazandın.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reklam şu an hazır değil. Lütfen biraz sonra tekrar dene.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ],
          const Divider(),
          // Pro Badge (Pro sürüm her zaman aktif)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryYellow,
                  AppTheme.darkYellow,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryYellow.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PRO Sürüm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            title: Text(
              widget.themeMode == ThemeMode.dark
                  ? loc.translate('drawer_theme_toggle_light')
                  : loc.translate('drawer_theme_toggle_dark'),
            ),
            onTap: () {
              widget.onThemeToggle();
              Navigator.pop(context);
            },
          ),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: loc.translate('app_title'),
            applicationVersion: '1.0.1',
            applicationIcon:
                const Icon(Icons.mosque, color: AppTheme.primaryYellow),
            aboutBoxChildren: [
              Text(loc.translate('drawer_tagline')),
            ],
            child: Text(loc.translate('drawer_about')),
          ),
        ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(loc),
      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: TasbihModeService.instance.camiiModeEnabled,
            builder: (context, enabled, _) {
              if (!enabled) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                color: AppTheme.primaryYellow.withOpacity(0.85),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mosque, size: 18, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      loc.translate('camii_mode_active_badge'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: loc.translate('bottom_nav_prayer_times'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: loc.translate('bottom_nav_qibla'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: loc.translate('bottom_nav_calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: loc.translate('bottom_nav_prayers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: loc.translate('bottom_nav_today'),
          ),
        ],
      ),
    );
  }
}

// ...
