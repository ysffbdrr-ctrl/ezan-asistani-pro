import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class NamazRehberi extends StatefulWidget {
  const NamazRehberi({Key? key}) : super(key: key);

  @override
  State<NamazRehberi> createState() => _NamazRehberiState();
}

class _NamazRehberiState extends State<NamazRehberi> {
  final List<Map<String, dynamic>> _namazAdimlari = [
    {
      'baslik': '1. Niyet ve Tekbir',
      'aciklama': 'Kıbleye dönerek, namazı hangi vakit için kılacağınızı niyet edersiniz. Ellerinizi kulak hizasına kaldırarak "Allahu Ekber" dersiniz.',
      'icon': Icons.pan_tool,
    },
    {
      'baslik': '2. Sübhaneke Duası',
      'aciklama': 'Ellerinizi göbek altında kavuşturup Sübhaneke duasını okursunuz.\n\n"Sübhaneke Allahumme ve bi-hamdike ve tebareke-smüke ve teala ceddüke ve la ilahe gayruk."',
      'icon': Icons.menu_book,
    },
    {
      'baslik': '3. Euzü-Besmele ve Fatiha',
      'aciklama': 'Euzü Besmele çekerek Fatiha Suresini okursunuz. Sonra bir sure daha okursunuz (Sabah namazının ilk rekatında, öğle ve ikindi namazlarının ilk iki rekatında).',
      'icon': Icons.bookmark,
    },
    {
      'baslik': '4. Rüku',
      'aciklama': r'Ellerinizi dizlerinize koyup eğilerek rükuya varırsınız. En az 3 defa "Sübhane Rabbiye-l-Azim" dersiniz.',
      'icon': Icons.accessibility_new,
    },
    {
      'baslik': '5. Kıyam (Rükudan Kalkma)',
      'aciklama': r'Rükudan doğrulup "Semi Allahu limen hamideh, Rabbena leke-l-hamd" dersiniz.',
      'icon': Icons.person,
    },
    {
      'baslik': '6. Secde',
      'aciklama': r'Önce dizleriniz, sonra elleriniz, en son alnınız ve burnunuz yere değecek şekilde secdeye gidersiniz. En az 3 defa "Sübhane Rabbiye-l-Ala" dersiniz.',
      'icon': Icons.self_improvement,
    },
    {
      'baslik': '7. Celse (Secdeler Arası Oturuş)',
      'aciklama': 'İki secde arasında kısa bir süre otururken "Allahu Ekber" dersiniz. Sonra ikinci secdeye gidersiniz.',
      'icon': Icons.airline_seat_recline_normal,
    },
    {
      'baslik': '8. İkinci Rekat',
      'aciklama': 'İkinci rekat için ayağa kalkar, Fatiha ve sure okuyup rüku ve secdelerinizi yaparsınız.',
      'icon': Icons.repeat,
    },
    {
      'baslik': '9. Kaade (Oturuş)',
      'aciklama': r'İkinci rekatın secdelerinden sonra Ettehiyyatu duasını okursunuz.'
          '\n\n'
          r'"Ettehiyyatu lillahi ve-s-salavatu ve-t-tayyibat. Es-selamu aleyke eyyuhe-n-nebiyyu ve rahmetullahi ve berekatuh..."',
      'icon': Icons.event_seat,
    },
    {
      'baslik': '10. Selam Verme',
      'aciklama': r'Son oturuşta Allahumme Salli, Allahumme Barik ve Rabbena dualarını okuduktan sonra, sağa ve sola "Es-selamu aleyküm ve rahmetullah" diyerek selam verirsiniz.',
      'icon': Icons.waving_hand,
    },
  ];

  final List<Map<String, dynamic>> _namazSureleri = [
    {
      'isim': 'Fatiha Suresi',
      'arapca': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'turkce': 'Rahman ve Rahim olan Allah\'ın adıyla.\nHamd, alemlerin Rabbi Allah\'a mahsustur.',
    },
    {
      'isim': 'İhlas Suresi',
      'arapca': 'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      'turkce': 'De ki: O, Allah\'tır, bir tektir. Allah Samed\'dir. O, doğmamıştır ve doğrulmamıştır. Hiçbir şey O\'na denk değildir.',
    },
    {
      'isim': 'Felak Suresi',
      'arapca': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nمِن شَرِّ مَا خَلَقَ',
      'turkce': 'De ki: Sabahın Rabbine sığınırım, yarattıklarının şerrinden.',
    },
    {
      'isim': 'Nas Suresi',
      'arapca': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ\nإِلَٰهِ النَّاسِ',
      'turkce': 'De ki: İnsanların Rabbine, insanların Malikine, insanların İlahına sığınırım.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Nasıl Kılınır?'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Giriş kartı
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
                    'Namaz İslam\'ın Beş Şartından Biridir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Günde 5 vakit farz olan namaz, Allah\'a kulluk etmenin en güzel yoludur. Aşağıda namaz kılmanın adımlarını bulabilirsiniz.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Namaz Adımları
          const Text(
            'Namaz Adımları',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...List.generate(_namazAdimlari.length, (index) {
            final adim = _namazAdimlari[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryYellow,
                  child: Icon(
                    adim['icon'],
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  adim['baslik'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      adim['aciklama'],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Namaz Sureleri
          const Text(
            'Önemli Sureler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...List.generate(_namazSureleri.length, (index) {
            final sure = _namazSureleri[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryYellow,
                  child: Icon(
                    Icons.auto_stories,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  sure['isim'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          sure['arapca'],
                          style: const TextStyle(
                            fontSize: 20,
                            height: 2,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const Divider(height: 24),
                        Text(
                          sure['turkce'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Bilgi kartı
          Card(
            color: AppTheme.lightYellow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.darkYellow,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Önemli Not',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Namaz kılmayı öğrenmek için bir hoca veya din görevlisinden yardım almanız önerilir. Bu rehber genel bilgilendirme amaçlıdır.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
