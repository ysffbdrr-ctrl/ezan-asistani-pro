import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class UmreHacRehberi extends StatefulWidget {
  const UmreHacRehberi({Key? key}) : super(key: key);

  @override
  State<UmreHacRehberi> createState() => _UmreHacRehberiState();
}

class _UmreHacRehberiState extends State<UmreHacRehberi> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _umreAdimlari = [
    {
      'numara': 1,
      'baslik': 'İhram',
      'aciklama': 'Mikat yerinden veya evinizden ihrama girersiniz. İhram niyeti edip telbiye getirirsiniz.',
      'detay': 'İhram niyeti: "Allah\'ım! Ben umre için ihrama giriyorum, onu benim için kolaylaştır ve benden kabul et."'
          '\n\nTelbiye: "Lebbeyk Allahumme lebbeyk, lebbeyk la şerike leke lebbeyk"'
          '\n\nİhram yasakları:\n• Parfüm ve kokulu şeyler kullanmak\n• Tırnak kesmek ve saç almak\n• Başı örtmek (erkekler için)\n• Dikişli elbise giymek (erkekler için)\n• Avlanmak\n• Evlilik akdi yapmak',
      'icon': Icons.checkroom,
    },
    {
      'numara': 2,
      'baslik': 'Kabe\'yi Tavaf',
      'aciklama': 'Mescid-i Haram\'a vardığınızda Kabe\'yi 7 kez tavaf edersiniz. Hacer-i Esved\'den başlayıp yine orada bitersiniz.',
      'detay': r'Tavaf nasıl yapılır:' '\n• Hacer-i Esved hizasından başlayın\n• Kabe' r"'yi sol tarafınızda tutarak saat yönünün tersine 7 tur dönün" '\n• Her turda Hacer-i Esved' r"'i selamlayın veya işaret edin" '\n• İlk 3 turda hızlı yürüyün (Remel)\n• Son 4 turda normal yürüyün'
          '\n\nTavaf sırasında okunacak dualar:\n• Her turun sonunda: "Rabbena atina fid-dunya haseneten ve fil-ahirati haseneten ve kina azaben-nar"'
          '\n\n• Hacer-i Esved' r"'de: " '"Bismillahi Allahu Ekber"',
      'icon': Icons.threed_rotation,
    },
    {
      'numara': 3,
      'baslik': 'Makam-ı İbrahim\'de Namaz',
      'aciklama': 'Tavaftan sonra Makam-ı İbrahim arkasında 2 rekat namaz kılarsınız.',
      'detay': 'İki rekat tavaf namazı:\n• Birinci rekatta Fatiha\'dan sonra Kafirun suresini okuyun\n• İkinci rekatta Fatiha\'dan sonra İhlas suresini okuyun'
          '\n\nEğer kalabalıktan dolayı Makam-ı İbrahim\'in arkasında yer bulamazsanız, Mescid-i Haram\'ın herhangi bir yerinde kılabilirsiniz.',
      'icon': Icons.mosque,
    },
    {
      'numara': 4,
      'baslik': 'Zemzem İçme',
      'aciklama': 'Makam-ı İbrahim\'deki namazdan sonra zemzem içersiniz ve dua edersiniz.',
      'detay': 'Zemzem içerken:\n• Kıbleye dönerek için\n• Besmele çekerek başlayın\n• Üç nefeste için\n• Doyasıya için\n• Dua edin'
          '\n\nZemzem duası:\n"Allah\'ım! Senden faydalı ilim, bol rızık ve her türlü hastalıktan şifa istiyorum."',
      'icon': Icons.water_drop,
    },
    {
      'numara': 5,
      'baslik': 'Safa ve Merve Arası Say',
      'aciklama': 'Safa tepesinden başlayarak Merve tepesine 7 kez say yaparsınız.',
      'detay': 'Say nasıl yapılır:\n• Safa tepesinden başlayın\n• Kabe\'yi görebiliyorsanız ona doğru dönün ve tekbir getirin\n• Merve tepesine doğru yürüyün (1. say)\n• Merve\'den Safa\'ya dönün (2. say)\n• Böylece 7 sayı tamamlayın\n• 7. say Merve tepesinde biter'
          '\n\nYeşil işaretler arasında:\n• Erkekler hızlı koşar\n• Kadınlar normal yürür'
          '\n\nSay sırasında dua edin, zikir çekin ve Kur\'an okuyabilirsiniz.',
      'icon': Icons.directions_walk,
    },
    {
      'numara': 6,
      'baslik': 'Tıraş veya Saç Kesimi',
      'aciklama': 'Say\'ı tamamladıktan sonra erkekler traş olur veya saçlarını kısaltır, kadınlar saçlarının uçlarından alırlar.',
      'detay': 'Saç kesimi:\n• Erkekler: Traş olmak veya saçı kısaltmak (traş olmak daha faziletli)\n• Kadınlar: Saçın ucundan bir parmak ucu kadar kesmek yeterli'
          '\n\nBundan sonra ihramdan çıkmış olursunuz ve umreniz tamamlanır.',
      'icon': Icons.content_cut,
    },
  ];

  final List<Map<String, dynamic>> _hacAdimlari = [
    {
      'numara': 1,
      'baslik': 'İhrama Girme (8 Zilhicce)',
      'aciklama': 'Zilhiccenin 8. günü Mekke\'den ihrama girersiniz ve Mina\'ya gidersiniz.',
      'detay': 'Hac için ihram:\n• Gusül abdesti alın\n• İhram elbiselerini giyin\n• İhram niyeti yapın: "Allah\'ım! Ben hac için ihrama giriyorum"'
          '\n• Telbiye getirin\n• Mina\'ya gidin ve orada geceyi geçirin',
      'icon': Icons.checkroom,
    },
    {
      'numara': 2,
      'baslik': 'Arafat\'ta Vakfe (9 Zilhicce)',
      'aciklama': 'Zilhiccenin 9. günü Arafat\'a gidersiniz ve öğleden güneş batana kadar orada kalırsınız.',
      'detay': 'Arafat Vakfesi:\n• Öğle vaktinden önce Arafat\'a varın\n• Öğle ve ikindi namazlarını birleştirilmiş olarak öğle vaktinde kılın\n• Güneş batana kadar Arafat\'ta kalın\n• Bol bol dua edin, istiğfar edin'
          '\n\nArafat\'ta okunacak dua:\n"La ilahe illallahu vahdehü la şerike leh, lehül-mülkü ve lehül-hamdü ve hüve ala külli şey\'in kadir"',
      'icon': Icons.landscape,
    },
    {
      'numara': 3,
      'baslik': 'Müzdelife (9-10 Zilhicce Gecesi)',
      'aciklama': 'Güneş battıktan sonra Müzdelife\'ye gidersiniz ve orada geceyi geçirirsiniz.',
      'detay': 'Müzdelife\'de yapılacaklar:\n• Akşam ve yatsı namazlarını yatsı vaktinde birleştirerek kılın\n• Sabah namazını erkence kılın\n• Şeytan taşlamak için 49-70 arası çakıl taşı toplayın\n• Sabah namazından sonra Meş\'ar-i Haram\'da dua edin\n• Güneş doğmadan Mina\'ya hareket edin',
      'icon': Icons.nights_stay,
    },
    {
      'numara': 4,
      'baslik': 'Şeytan Taşlama - Akabe (10 Zilhicce)',
      'aciklama': 'Kurban Bayramı günü büyük şeytan sütununa (Cemret-ül Akabe) 7 taş atarsınız.',
      'detay': 'İlk taşlama:\n• Sadece büyük şeytana (Cemret-ül Akabe) 7 taş atın\n• Her taş atışında "Bismillahi Allahu Ekber" deyin\n• Kuşluk vaktinden gece yarısına kadar yapılabilir',
      'icon': Icons.gps_fixed,
    },
    {
      'numara': 5,
      'baslik': 'Kurban Kesme (10 Zilhicce)',
      'aciklama': 'Taşlama sonrası kurbanınızı kesersiniz veya kestirirsiniz.',
      'detay': 'Kurban:\n• Koyun, keçi, deve veya sığır kesilir\n• Kurban kesmek farz değil, vaciptir\n• Kurban kesildikten sonra etinden yiyebilir ve dağıtabilirsiniz',
      'icon': Icons.pets,
    },
    {
      'numara': 6,
      'baslik': 'Tıraş veya Saç Kesimi (10 Zilhicce)',
      'aciklama': 'Kurban kestikten sonra traş olursunuz veya saçınızı kısaltırsınız.',
      'detay': 'Saç kesimi:\n• Erkekler: Traş olmak veya saçı kısaltmak (traş olmak daha faziletli)\n• Kadınlar: Saçın ucundan bir parmak ucu kadar kesmek\n\nBundan sonra ihramın yasaklarının çoğu kalkar (eş ilişkisi hariç).',
      'icon': Icons.content_cut,
    },
    {
      'numara': 7,
      'baslik': 'İfaza Tavafı (10-12 Zilhicce)',
      'aciklama': 'Kabe\'yi 7 kez tavaf edersiniz. Bu haccın farklarındandır.',
      'detay': 'İfaza Tavafı:\n• Mekke\'ye gidip Kabe\'yi 7 kez tavaf edin\n• Tavaftan sonra 2 rekat namaz kılın\n• Safa-Merve arasında say yapın (7 kez)\n\nBu tavaftan sonra ihramdan tamamen çıkmış olursunuz.',
      'icon': Icons.threed_rotation,
    },
    {
      'numara': 8,
      'baslik': 'Şeytan Taşlama - Teşrik Günleri (11-13 Zilhicce)',
      'aciklama': 'Mina\'da kalan günlerde her gün 3 şeytan sütununa toplam 21 taş atarsınız.',
      'detay': 'Teşrik günlerinde taşlama:\n• Küçük şeytana 7 taş\n• Orta şeytana 7 taş\n• Büyük şeytana 7 taş\n\nSırasıyla taşlama yapılır. Her taşlamadan sonra dua edilir (büyük şeytan hariç).\n\n11 ve 12. günlerde taşlayıp 12. gün güneş batmadan ayrılabilirsiniz, veya 13. günü de taşlayabilirsiniz.',
      'icon': Icons.gps_fixed,
    },
    {
      'numara': 9,
      'baslik': 'Veda Tavafı',
      'aciklama': 'Mekke\'den ayrılmadan önce son kez Kabe\'yi tavaf edersiniz.',
      'detay': 'Veda Tavafı:\n• Mekke\'den ayrılmadan önce yapılması gereken son ibadet\n• 7 kez tavaf yapılır\n• Bu tavaftan sonra Mekke\'den doğrudan ayrılmalısınız\n• Kadınlar hayızlı veya nifaslı ise veda tavafından muaftır',
      'icon': Icons.waves,
    },
  ];

  final List<Map<String, String>> _hacZiyaretYerleri = [
    {
      'yer': 'Mescid-i Nebevi',
      'konum': 'Medine',
      'aciklama': 'Hz. Muhammed\'in (s.a.v.) kabri ve mescidi. Ziyaret etmek müstehaptır.',
    },
    {
      'yer': 'Uhud Dağı',
      'konum': 'Medine',
      'aciklama': 'Uhud Savaşı\'nın yapıldığı yer. Şehitler mezarlığı.',
    },
    {
      'yer': 'Kuba Mescidi',
      'konum': 'Medine',
      'aciklama': 'Hz. Peygamber\'in (s.a.v.) Medine\'de yaptırdığı ilk mescit.',
    },
    {
      'yer': 'Hira Mağarası',
      'konum': 'Mekke',
      'aciklama': 'Hz. Peygamber\'e (s.a.v.) ilk vahyin geldiği mağara.',
    },
    {
      'yer': 'Sevr Mağarası',
      'konum': 'Mekke',
      'aciklama': 'Hicret sırasında Hz. Peygamber ile Hz. Ebubekir\'in saklandığı mağara.',
    },
  ];

  final List<Map<String, String>> _onemliDualar = [
    {
      'yer': 'Kabe Kapısı',
      'dua': 'Allah\'ım! Bu evin Rabbi ve sahibi sensin. Ben kulunun, kulun oğluyum. Senden bağışlama, rahmet, güzellik ve afiyet diliyorum.',
    },
    {
      'yer': 'Hacer-i Esved',
      'dua': 'Bismillahi Allahu Ekber, Allah\'ım sana, kitabına, peygamberine iman ettim. Senin ahdine vefa gösterdim.',
    },
    {
      'yer': 'Rükn-ü Yemani',
      'dua': 'Rabbenâ âtinâ fid-dünyâ haseneten ve fil-âhirati haseneten ve kınâ azâben-nâr',
    },
    {
      'yer': 'Safa Tepesi',
      'dua': 'Allah\'tan başka ilah yoktur. O tektir, ortağı yoktur. Mülk O\'nundur, hamd O\'na mahsustur.',
    },
    {
      'yer': 'Arafat',
      'dua': 'La ilahe illallahu vahdehü la şerike leh, lehül-mülkü ve lehül-hamdü ve hüve ala külli şey\'in kadir',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umre & Hac Rehberi'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'UMRE'),
            Tab(text: 'HAC'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUmreTab(),
          _buildHacTab(),
        ],
      ),
    );
  }

  Widget _buildUmreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Giriş Kartı
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.mosque,
                  size: 64,
                  color: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Umre İbadeti',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Umre, Müslümanların Mekke\'de Kabe\'yi ziyaret ederek yaptıkları bir ibadettir. Yıl boyunca yapılabilir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Umre Adımları',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...List.generate(_umreAdimlari.length, (index) {
          final adim = _umreAdimlari[index];
          return _buildStepCard(adim);
        }),

        const SizedBox(height: 24),
        _buildImportantPlacesSection(),
        const SizedBox(height: 24),
        _buildPrayersSection(),
      ],
    );
  }

  Widget _buildHacTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Giriş Kartı
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.mosque,
                  size: 64,
                  color: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hac İbadeti',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hac, İslam\'ın beş şartından biridir ve Zilhicce ayının belirli günlerinde yapılır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Hac Adımları',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...List.generate(_hacAdimlari.length, (index) {
          final adim = _hacAdimlari[index];
          return _buildStepCard(adim);
        }),

        const SizedBox(height: 24),
        _buildImportantPlacesSection(),
        const SizedBox(height: 24),
        _buildPrayersSection(),
      ],
    );
  }

  Widget _buildStepCard(Map<String, dynamic> adim) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${adim['numara']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          adim['baslik'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          adim['aciklama'],
          style: const TextStyle(fontSize: 13),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      adim['icon'],
                      color: AppTheme.primaryYellow,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Detaylı Bilgi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  adim['detay'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ziyaret Yerleri',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _hacZiyaretYerleri.map((yer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.place,
                        color: AppTheme.primaryYellow,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              yer['yer']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              yer['konum']!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              yer['aciklama']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Önemli Dualar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._onemliDualar.map((dua) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: AppTheme.primaryYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dua['yer']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.darkYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dua['dua']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
