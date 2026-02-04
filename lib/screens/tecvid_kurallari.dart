import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class TecvidKurallari extends StatefulWidget {
  const TecvidKurallari({Key? key}) : super(key: key);

  @override
  State<TecvidKurallari> createState() => _TecvidKurallariState();
}

class _TecvidKurallariState extends State<TecvidKurallari> {
  int _expandedIndex = -1;

  final List<Map<String, dynamic>> tecvidKurallari = [
    {
      'baslik': 'Nun Sakin ve Tenvin',
      'icon': Icons.circle_outlined,
      'renk': Colors.blue,
      'altKurallar': [
        {
          'isim': 'İzhar',
          'aciklama': 'Nun sakin veya tenvinden sonra boğaz harfleri (ء ه ع ح غ خ) gelirse açık okunur.',
          'ornek': 'مِنْ عَمَلٍ',
        },
        {
          'isim': 'İdgam',
          'aciklama': 'Nun sakin veya tenvinden sonra يرملون harfleri gelirse birleşik okunur.',
          'ornek': 'مِنْ يَشَاءُ',
        },
        {
          'isim': 'İklab',
          'aciklama': 'Nun sakin veya tenvinden sonra ب harfi gelirse nun, mim\'e çevrilir.',
          'ornek': 'مِنْ بَعْدِ',
        },
        {
          'isim': 'İhfa',
          'aciklama': 'Nun sakin veya tenvinden sonra 15 harf gelirse gizli okunur.',
          'ornek': 'مِنْ ذَهَبٍ',
        },
      ],
    },
    {
      'baslik': 'Mim Sakin',
      'icon': Icons.circle,
      'renk': Colors.green,
      'altKurallar': [
        {
          'isim': 'İhfa-i Şefevi',
          'aciklama': 'Mim sakinden sonra ب harfi gelirse mim gizli okunur.',
          'ornek': 'تَرْمِيهِمْ بِحِجَارَةٍ',
        },
        {
          'isim': 'İdgam-ı Misleyn',
          'aciklama': 'Mim sakinden sonra mim gelirse birleşik okunur.',
          'ornek': 'لَهُمْ مَا',
        },
        {
          'isim': 'İzhar-ı Şefevi',
          'aciklama': 'Mim sakinden sonra ب ve م dışındaki harfler gelirse açık okunur.',
          'ornek': 'عَلَيْهِمْ وَلَا',
        },
      ],
    },
    {
      'baslik': 'Medler',
      'icon': Icons.timeline,
      'renk': Colors.orange,
      'altKurallar': [
        {
          'isim': 'Med-i Tabii',
          'aciklama': 'Elif, vav ve ye harfleri 2 hareke (1 elif miktarı) uzatılır.',
          'ornek': 'قَالَ - يَقُولُ - قِيلَ',
        },
        {
          'isim': 'Med-i Muttasıl',
          'aciklama': 'Med harfinden sonra hemze gelirse 4-5 hareke uzatılır.',
          'ornek': 'جَاءَ - سُوءٍ',
        },
        {
          'isim': 'Med-i Munfasıl',
          'aciklama': 'Med harfi ile hemze farklı kelimelerde ise 2-4 hareke uzatılır.',
          'ornek': 'يَا أَيُّهَا',
        },
        {
          'isim': 'Med-i Lazım',
          'aciklama': 'Med harfinden sonra şeddeli veya sakin harf gelirse 6 hareke uzatılır.',
          'ornek': 'الضَّالِّينَ',
        },
      ],
    },
    {
      'baslik': 'Kalkaleler',
      'icon': Icons.volume_up,
      'renk': Colors.purple,
      'altKurallar': [
        {
          'isim': 'Kalkale-i Sugra',
          'aciklama': 'قطب جد harfleri sakin olduğunda titretilerek okunur.',
          'ornek': 'يَقْتُلُونَ',
        },
        {
          'isim': 'Kalkale-i Kubra',
          'aciklama': 'قطب جد harfleri kelime sonunda sakin olduğunda daha belirgin titretilir.',
          'ornek': 'مُحِيطٌ',
        },
      ],
    },
    {
      'baslik': 'Ra Harfinin Okunuşu',
      'icon': Icons.record_voice_over,
      'renk': Colors.teal,
      'altKurallar': [
        {
          'isim': 'Ra\'nın Kalın Okunması',
          'aciklama': 'Ra üstün veya ötre ile harekelenmiş ise kalın okunur.',
          'ornek': 'رَحْمَةً - رُزِقْنَا',
        },
        {
          'isim': 'Ra\'nın İnce Okunması',
          'aciklama': 'Ra esre ile harekelenmiş ise ince okunur.',
          'ornek': 'رِزْقًا',
        },
        {
          'isim': 'Ra Sakin',
          'aciklama': 'Ra sakin ise önceki harfe bakılır. Üstün/ötre ise kalın, esre ise ince okunur.',
          'ornek': 'فِرْعَوْنَ (ince) - الْقُرْآنِ (kalın)',
        },
      ],
    },
    {
      'baslik': 'Lam-ı Tarifin Okunuşu',
      'icon': Icons.article,
      'renk': Colors.red,
      'altKurallar': [
        {
          'isim': 'Şemsiye Harfler',
          'aciklama': 'ال dan sonra شمسية harfleri gelirse lam okunmaz.',
          'ornek': 'الشَّمْسُ - التَّوَّابُ',
          'harfler': 'ت ث د ذ ر ز س ش ص ض ط ظ ل ن',
        },
        {
          'isim': 'Kameriye Harfler',
          'aciklama': 'ال dan sonra قمرية harfleri gelirse lam okunur.',
          'ornek': 'الْقَمَرُ - الْكِتَابُ',
          'harfler': 'ا ب غ ح ج ك و خ ف ع ق ي م ه',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tecvid Kuralları'),
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
                    AppTheme.primaryYellow,
                    AppTheme.primaryYellow.withOpacity(0.7),
                ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.rule,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tecvid Kuralları',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kur\'an-ı Kerim\'i doğru okuma kuralları',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Uyarı kartı
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tecvid kurallarını öğrenmek Kur\'an-ı Kerim\'i doğru okumak için önemlidir.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tecvid kuralları listesi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tecvidKurallari.length,
              itemBuilder: (context, index) {
                final kural = tecvidKurallari[index];
                final isExpanded = _expandedIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isExpanded ? 4 : 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? -1 : index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: kural['renk'].withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    kural['icon'],
                                    color: kural['renk'],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        kural['baslik'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${kural['altKurallar'].length} kural',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          const Divider(height: 1),
                          ...kural['altKurallar'].map<Widget>((altKural) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: kural['renk'],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        altKural['isim'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          altKural['aciklama'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                        if (altKural.containsKey('harfler')) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Harfler: ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    altKural['harfler'],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textDirection: TextDirection.rtl,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.lightYellow,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Örnek: ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                altKural['ornek'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textDirection: TextDirection.rtl,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (altKural != kural['altKurallar'].last)
                                    const Divider(height: 32),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            // Alt bilgi kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tips_and_updates, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Öğrenme İpuçları',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Her kuralı tek tek öğrenin ve pratik yapın'),
                  _buildTip('Örnekleri sesli okuyarak tekrar edin'),
                  _buildTip('Bir hocadan dinleyerek öğrenin'),
                  _buildTip('Sabırlı olun, tecvid öğrenmek zaman alır'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
