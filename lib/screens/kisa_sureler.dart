import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KisaSureler extends StatefulWidget {
  const KisaSureler({Key? key}) : super(key: key);

  @override
  State<KisaSureler> createState() => _KisaSurelerState();
}

class _KisaSurelerState extends State<KisaSureler> {
  Set<String> _ogrenilenSureler = {};
  
  final List<Map<String, dynamic>> sureler = [
    {
      'isim': 'Fatiha Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ
الرَّحْمَٰنِ الرَّحِيمِ
مَالِكِ يَوْمِ الدِّينِ
إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ
اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ
صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Elhamdülillâhi rabbil'âlemîn
Errahmânirrahîm
Mâliki yevmiddîn
İyyâke na'büdü ve iyyâke neste'în
İhdinessırâtel-müstekîm
Sırâtellezîne en'amte aleyhim ğayril mağdûbi aleyhim veleddâllîn''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
Hamd, âlemlerin Rabbi Allah'a mahsustur
O, Rahman'dır, Rahim'dir
Din gününün sahibidir
Ancak Sana ibadet eder ve ancak Senden yardım dileriz
Bizi doğru yola ilet
Kendilerine nimet verdiğin kimselerin yoluna; gazaba uğrayanların ve sapkınların yoluna değil''',
      'onemi': 'Namazın rüknüdür, her rekatta okunur',
    },
    {
      'isim': 'İhlas Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
قُلْ هُوَ اللَّهُ أَحَدٌ
اللَّهُ الصَّمَدُ
لَمْ يَلِدْ وَلَمْ يُولَدْ
وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Kul hüvallâhü ehad
Allâhüssamed
Lem yelid ve lem yûled
Ve lem yekün lehû küfüven ehad''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
De ki: "O, Allah'tır, bir tektir"
Allah Samed'dir (Her şey O'na muhtaç, O hiçbir şeye muhtaç değildir)
O doğurmamıştır ve doğurulmamıştır
Hiçbir şey O'na denk değildir''',
      'onemi': 'Kur\'an\'ın üçte birine denktir',
    },
    {
      'isim': 'Felak Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ
مِن شَرِّ مَا خَلَقَ
وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ
وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ
وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Kul eûzü birabbil-felak
Min şerri mâ halak
Ve min şerri ğâsikın izâ vekab
Ve min şerrin-neffâsâti fil-ukad
Ve min şerri hâsidin izâ hased''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
De ki: "Sabahın Rabbine sığınırım"
Yarattığı şeylerin şerrinden
Karanlığı çöktüğü zaman gecenin şerrinden
Düğümlere üfürenlerin şerrinden
Haset ettiği zaman hasetçinin şerrinden''',
      'onemi': 'Korunma suresidir (Muavvizeteyn)',
    },
    {
      'isim': 'Nas Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
قُلْ أَعُوذُ بِرَبِّ النَّاسِ
مَلِكِ النَّاسِ
إِلَٰهِ النَّاسِ
مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ
الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ
مِنَ الْجِنَّةِ وَالنَّاسِ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Kul eûzü birabbin-nâs
Melikin-nâs
İlâhin-nâs
Min şerril-vesvâsil-hannâs
Ellezî yüvesvisü fî sudûrin-nâs
Minel-cinneti ven-nâs''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
De ki: "İnsanların Rabbine sığınırım"
İnsanların Melik'ine
İnsanların İlah'ına
Sinsi vesvesecinin şerrinden
O ki insanların göğüslerine vesvese verir
Gerek cinlerden, gerek insanlardan''',
      'onemi': 'Korunma suresidir (Muavvizeteyn)',
    },
    {
      'isim': 'Kevser Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ
فَصَلِّ لِرَبِّكَ وَانْحَرْ
إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
İnnâ a'taynâkel-kevser
Fesalli lirabbike venhar
İnne şâni'eke hüvel-ebter''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
Şüphesiz biz sana Kevser'i verdik
O halde Rabbin için namaz kıl ve kurban kes
Asıl soyu kesik olan, sana kin duyandır''',
      'onemi': 'Kur\'an\'ın en kısa suresidir',
    },
    {
      'isim': 'Fil Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ
أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ
وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ
تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ
فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Elem tera keyfe fe'ale rabbüke bi-ashâbil-fîl
Elem yec'al keydehüm fî tadlîl
Ve ersele aleyhim tayran ebâbîl
Termîhim bihicâratin min siccîl
Fece'alehüm ke'asfin me'kûl''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
Rabbinin fil sahiplerine ne yaptığını görmedin mi?
Onların tuzaklarını boşa çıkarmadı mı?
Onların üzerine sürü sürü kuşlar gönderdi
Onlara balçıktan pişirilmiş taşlar atıyorlardı
Böylece onları yenilmiş ekin yaprağı gibi yaptı''',
      'onemi': 'Kabe\'nin korunması mucizesini anlatır',
    },
    {
      'isim': 'Kureyş Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
لِإِيلَافِ قُرَيْشٍ
إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ
فَلْيَعْبُدُوا رَبَّ هَٰذَا الْبَيْتِ
الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Li-îlâfi kureyş
Îlâfihim rihleteş-şitâ'i vessayf
Felya'budû rabbe hâzel-beyt
Ellezî et'amehüm min cû'in ve âmenehüm min havf''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
Kureyş'in alışması için
Onların kış ve yaz yolculuklarına alışmaları için
O halde bu evin (Kabe'nin) Rabbine kulluk etsinler
O ki onları açlıktan doyurdu ve korkudan emin kıldı''',
      'onemi': 'Kureyş kabilesinin nimetlerini hatırlatır',
    },
    {
      'isim': 'Maun Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ
فَذَٰلِكَ الَّذِي يَدُعُّ الْيَتِيمَ
وَلَا يَحُضُّ عَلَىٰ طَعَامِ الْمِسْكِينِ
فَوَيْلٌ لِّلْمُصَلِّينَ
الَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ
الَّذِينَ هُمْ يُرَاءُونَ
وَيَمْنَعُونَ الْمَاعُونَ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Era'eytellezî yükezzibü biddîn
Fezâlikellezî yedu'ul-yetîm
Ve lâ yehuddu alâ ta'âmil-miskîn
Feveylün lil-musallîn
Ellezîne hüm an salâtihim sâhûn
Ellezîne hüm yürâ'ûn
Ve yemne'ûnel-mâ'ûn''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
Dini yalanlayanı gördün mü?
İşte o, yetimi itip kakan
Yoksulu doyurmaya teşvik etmeyen kimsedir
Yazıklar olsun o namaz kılanlara ki
Onlar namazlarında yanılgıdadırlar
Onlar gösteriş yaparlar
Ve ufak yardımları da esirgerler''',
      'onemi': 'İbadet ve sosyal sorumluluğu vurgular',
    },
    {
      'isim': 'Kafirun Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
قُلْ يَا أَيُّهَا الْكَافِرُونَ
لَا أَعْبُدُ مَا تَعْبُدُونَ
وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ
وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ
وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ
لَكُمْ دِينُكُمْ وَلِيَ دِينِ''',
      'okunusu': '''Bismillâhirrahmânirrahîm
Kul yâ eyyühel-kâfirûn
Lâ a'büdü mâ ta'büdûn
Ve lâ entüm âbidûne mâ a'büd
Ve lâ ene âbidün mâ abedtüm
Ve lâ entüm âbidûne mâ a'büd
Leküm dînüküm veliye dîn''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
De ki: "Ey kafirler!"
Ben sizin taptıklarınıza tapmam
Siz de benim taptığıma tapıcı değilsiniz
Ben sizin taptıklarınıza tapıcı değilim
Siz de benim taptığıma tapıcı değilsiniz
Sizin dininiz size, benim dinim banadır''',
      'onemi': 'Tevhid inancını net bir şekilde ifade eder',
    },
    {
      'isim': 'Nasr Suresi',
      'arapca': '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ
وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا
فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا''',
      'okunusu': '''Bismillâhirrahmânirrahîm
İzâ câ'e nasrullâhi vel-feth
Ve ra'eyten-nâse yedhulûne fî dînillâhi efvâcâ
Fesebbih bihamdi rabbike vestağfirh, innehû kâne tevvâbâ''',
      'anlami': '''Rahman ve Rahim olan Allah'ın adıyla
Allah'ın yardımı ve fetih geldiğinde
Ve insanların Allah'ın dinine bölük bölük girdiklerini gördüğünde
Rabbini hamd ile tesbih et ve O'ndan mağfiret dile. Şüphesiz O, tövbeleri çok kabul edendir''',
      'onemi': 'Mekke\'nin fethini müjdeler',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOgrenilenSureler();
  }

  Future<void> _loadOgrenilenSureler() async {
    final prefs = await SharedPreferences.getInstance();
    final ogrenilen = prefs.getStringList('ogrenilen_sureler') ?? [];
    setState(() {
      _ogrenilenSureler = ogrenilen.toSet();
    });
  }

  Future<void> _toggleOgrenilen(String sure) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_ogrenilenSureler.contains(sure)) {
        _ogrenilenSureler.remove(sure);
      } else {
        _ogrenilenSureler.add(sure);
      }
    });
    await prefs.setStringList('ogrenilen_sureler', _ogrenilenSureler.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kısa Sureler'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Başlık kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.green.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Namazda Okunan Sureler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Öğrenilen: ${_ogrenilenSureler.length} / ${sureler.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // İlerleme çubuğu
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _ogrenilenSureler.length / sureler.length,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sureler listesi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sureler.length,
              itemBuilder: (context, index) {
                final sure = sureler[index];
                final isOgrenilen = _ogrenilenSureler.contains(sure['isim']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(16),
                      childrenPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isOgrenilen
                              ? Colors.green.withOpacity(0.2)
                              : AppTheme.primaryYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isOgrenilen ? Colors.green : AppTheme.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        sure['isim'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        sure['onemi'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isOgrenilen ? Icons.check_circle : Icons.circle_outlined,
                          color: isOgrenilen ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => _toggleOgrenilen(sure['isim']),
                      ),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Arapça metin
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.lightYellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sure['arapca'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Okunuşu
                            const Text(
                              'Okunuşu:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                sure['okunusu'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Anlamı
                            const Text(
                              'Anlamı:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                sure['anlami'],
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Öğrendim butonu
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _toggleOgrenilen(sure['isim']),
                                icon: Icon(
                                  isOgrenilen ? Icons.check : Icons.school,
                                ),
                                label: Text(
                                  isOgrenilen ? 'Öğrenildi' : 'Öğrendim olarak işaretle',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOgrenilen ? Colors.green : AppTheme.primaryYellow,
                                  foregroundColor: isOgrenilen ? Colors.white : Colors.black,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
