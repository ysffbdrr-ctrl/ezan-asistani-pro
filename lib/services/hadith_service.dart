import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ezan_asistani/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hadith {
  final String id;
  final String text;
  final String source; // Sahih Bukhari, Sahih Muslim, vb.
  final String narrator; // Ravi
  final String? explanation; // Açıklama

  Hadith({
    required this.id,
    required this.text,
    required this.source,
    required this.narrator,
    this.explanation,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id']?.toString() ?? '',
      text: json['hadith_ar'] ?? json['text'] ?? '',
      source: json['source'] ?? 'Bilinmiyor',
      narrator: json['narrator'] ?? json['chain']?['narrator'] ?? 'Bilinmiyor',
      explanation: json['explanation'] ?? json['hadith_en'],
    );
  }
}

class HadithService {
  static const String _alternativeUrl = 'https://hadith-api.vercel.app/api';
  static final HadithService _instance = HadithService._internal();

  factory HadithService() => _instance;
  HadithService._internal();

  // Rastgele hadis getir
  Future<Hadith?> getRandomHadith() async {
    try {
      AppLogger.info('Rastgele hadis alınıyor');

      // Yerel hadis veritabanından al
      final hadith = _getLocalHadith();
      if (hadith != null) {
        AppLogger.success('Hadis bulundu');
        return hadith;
      }

      // API'den dene
      return await _fetchFromApi();
    } catch (e) {
      AppLogger.error('Hadis alınamadı', error: e);
      return null;
    }
  }

  // API'den hadis getir
  Future<Hadith?> _fetchFromApi() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_alternativeUrl/hadiths?limit=1&random=true'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['hadiths'] != null && (data['hadiths'] as List).isNotEmpty) {
          return Hadith.fromJson(data['hadiths'][0]);
        }
      }
      return null;
    } catch (e) {
      AppLogger.warning('API hadis alınamadı', error: e);
      return null;
    }
  }

  // Yerel hadis veritabanı
  Hadith? _getLocalHadith() {
    final hadiths = _getLocalHadiths();
    if (hadiths.isEmpty) return null;
    hadiths.shuffle();
    return hadiths.first;
  }

  // Yerel hadisler listesi
  List<Hadith> _getLocalHadiths() {
    return [
      Hadith(
        id: '1',
        text:
            'Resulullah (s.a.v.) buyurdu: "Sizden en hayırlısı, Kur\'an\'ı öğrenen ve öğretenidir."',
        source: 'Sahih Buhari',
        narrator: 'Osman ibn Affan',
        explanation:
            'Kur\'an öğrenmenin ve öğretmenin en yüce amallardan olduğunu gösterir.',
      ),
      Hadith(
        id: '2',
        text:
            'Resulullah (s.a.v.) buyurdu: "Müslüman, müslümanın kardeşidir. Onu aldatmaz, ona yalan söylemez ve ona yardım etmekten geri durmaz."',
        source: 'Sahih Muslim',
        narrator: 'Abdullah ibn Ömer',
        explanation:
            'Müslümanlar arasında kardeşlik ve dayanışmanın önemini vurgular.',
      ),
      Hadith(
        id: '3',
        text:
            'Resulullah (s.a.v.) buyurdu: "Annene, babanına iyilik yap. Eğer onlardan biri veya her ikisi yaşlılık çağına ulaşırsa, onlara \'öf\' bile deme."',
        source: 'Sahih Buhari',
        narrator: 'Abdullah ibn Mas\'ud',
        explanation:
            'Ebeveynlere karşı görevlerimiz ve onlara gösterilmesi gereken saygı anlatılır.',
      ),
      Hadith(
        id: '4',
        text: 'Resulullah (s.a.v.) buyurdu: "Temizlik, imanın yarısıdır."',
        source: 'Sahih Muslim',
        narrator: 'Ebu Malik el-Eş\'ari',
        explanation:
            'Bedensel ve ruhsal temizliğin İslam\'da ne kadar önemli olduğunu gösterir.',
      ),
      Hadith(
        id: '5',
        text: 'Resulullah (s.a.v.) buyurdu: "Dua, ibadetin özüdür."',
        source: 'Sunen Tirmizi',
        narrator: 'Ebu Hüreyre',
        explanation:
            'Duanın ibadetlerin en önemli kısmı olduğunu ve Allah\'a yaklaşmanın en etkili yolunun dua olduğunu belirtir.',
      ),
      Hadith(
        id: '6',
        text: 'Resulullah (s.a.v.) buyurdu: "Sabır, imanın yarısıdır."',
        source: 'Sunen İbn Mace',
        narrator: 'Ebu Hüreyre',
        explanation:
            'Sabrın İslam\'da ne kadar önemli bir erdem olduğunu gösterir.',
      ),
      Hadith(
        id: '7',
        text:
            'Resulullah (s.a.v.) buyurdu: "Kimse mümin olmaz, ta ki kendi için sevdiğini kardeşi için de sevsin."',
        source: 'Sahih Buhari',
        narrator: 'Enes ibn Malik',
        explanation:
            'Müslümanlar arasında eşitlik ve kardeşlik duygusunun temelini oluşturan bu hadis önemlidir.',
      ),
      Hadith(
        id: '8',
        text: 'Resulullah (s.a.v.) buyurdu: "Affetmek güçlü olanın işidir."',
        source: 'Sunen İbn Mace',
        narrator: 'Ebu Hüreyre',
        explanation:
            'Affetme ve merhamet göstermenin gerçek gücü temsil ettiğini anlatır.',
      ),
      Hadith(
        id: '9',
        text: 'Resulullah (s.a.v.) buyurdu: "Müslüman, müslümanın aynasıdır."',
        source: 'Sunen Ebu Davud',
        narrator: 'Ebu Hüreyre',
        explanation:
            'Müslümanların birbirlerini uyarması ve hatalarını göstermesinin önemini anlatır.',
      ),
      Hadith(
        id: '10',
        text:
            'Resulullah (s.a.v.) buyurdu: "Komşu hakkını iyice bilin; çünkü Cebrail bana komşu hakkını çok tavsiye etti."',
        source: 'Sahih Buhari',
        narrator: 'Abdullah ibn Ömer',
        explanation:
            'Komşuluk hakkının İslam\'da ne kadar önemli olduğunu gösterir.',
      ),
      Hadith(
        id: '11',
        text:
            'Resulullah (s.a.v.) buyurdu: "Dil bir kaç kişiyi cehenneme sokar."',
        source: 'Sunen Tirmizi',
        narrator: 'Muaz ibn Cebel',
        explanation:
            'Dili kontrol etmenin ve sözlerimize dikkat etmenin önemini vurgular.',
      ),
      Hadith(
        id: '12',
        text:
            'Resulullah (s.a.v.) buyurdu: "En iyi sadaka, hastalık zamanında yapılan sadakadır."',
        source: 'Sunen Tirmizi',
        narrator: 'Ebu Hüreyre',
        explanation:
            'Hastalık ve zorluk zamanında yapılan sadakanın özel bir değeri olduğunu belirtir.',
      ),
    ];
  }

  // Belirli bir hadis getir
  Future<Hadith?> getHadithById(String id) async {
    try {
      final hadiths = _getLocalHadiths();
      return hadiths.firstWhere(
        (h) => h.id == id,
        orElse: () => Hadith(
          id: '',
          text: 'Hadis bulunamadı',
          source: '',
          narrator: '',
        ),
      );
    } catch (e) {
      AppLogger.error('Hadis getirme hatası', error: e);
      return null;
    }
  }

  // Tüm hadisleri getir
  List<Hadith> getAllHadiths() {
    return _getLocalHadiths();
  }

  // Bugünün hadisini getir (aynı hadis günlük gelmesi için)
  Future<Hadith?> getTodayHadith() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = 'hadith_date_${today.year}_${today.month}_${today.day}';
      final cachedHadithId = prefs.getString(todayKey);

      final hadiths = _getLocalHadiths();
      if (hadiths.isEmpty) return null;

      if (cachedHadithId != null) {
        // Bugünün hadisini döndür
        final hadith = hadiths.firstWhere(
          (h) => h.id == cachedHadithId,
          orElse: () => hadiths.first,
        );
        AppLogger.info('Bugünün hadisi: ${hadith.id}');
        return hadith;
      }

      // Yeni hadis seç ve kaydet
      hadiths.shuffle();
      final selectedHadith = hadiths.first;
      await prefs.setString(todayKey, selectedHadith.id);
      AppLogger.info('Yeni hadis seçildi: ${selectedHadith.id}');
      return selectedHadith;
    } catch (e) {
      AppLogger.error('Bugünün hadisi alınamadı', error: e);
      return null;
    }
  }

  // Daily hadis bildirimini etkinleştir/devre dışı bırak
  Future<void> setDailyHadithNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('daily_hadith_notification_enabled', enabled);
      AppLogger.info('Günlük hadis bildirimi: ${enabled ? 'Açık' : 'Kapalı'}');
    } catch (e) {
      AppLogger.error('Hadis bildirimi durumu kaydedilemedi', error: e);
    }
  }

  // Daily hadis bildiriminin durumunu kontrol et
  Future<bool> isDailyHadithNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('daily_hadith_notification_enabled') ?? false;
    } catch (e) {
      AppLogger.error('Hadis bildirimi durumu kontrol edilemedi', error: e);
      return false;
    }
  }

  // Günlük hadis bildirimi zamanını ayarla
  Future<void> setDailyHadithNotificationTime(int hour, int minute) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hadith_notification_hour', hour);
      await prefs.setInt('hadith_notification_minute', minute);
      AppLogger.info(
          'Hadis bildirimi saati ayarlandı: $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      AppLogger.error('Hadis bildirimi saati kaydedilemedi', error: e);
    }
  }

  // Günlük hadis bildirimi zamanını al
  Future<(int, int)> getDailyHadithNotificationTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('hadith_notification_hour') ?? 8;
      final minute = prefs.getInt('hadith_notification_minute') ?? 0;
      return (hour, minute);
    } catch (e) {
      AppLogger.error('Hadis bildirimi saati alınamadı', error: e);
      return (8, 0);
    }
  }
}
