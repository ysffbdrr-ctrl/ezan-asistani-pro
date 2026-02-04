import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ezan_asistani/widgets/dua_card.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/gamification_service.dart' as gamification_service;

class Dualar extends StatefulWidget {
  const Dualar({Key? key}) : super(key: key);

  @override
  State<Dualar> createState() => _DualarState();
}

class _DualarState extends State<Dualar> {
  late Box<Map> duaBox;
  bool isLoading = true;

  // Varsayılan dualar
  final List<Map<String, String>> defaultDuas = [
    {
      'title': 'Fâtiha Suresi',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'pronunciation': 'Bismillâhirrahmânirrahîm. Elhamdülillâhi rabbil âlemîn... (Fâtiha)',
      'turkish': 'Rahmân ve Rahîm olan Allah’ın adıyla. Hamd âlemlerin Rabbi Allah’a mahsustur... (Fâtiha Meali)',
    },
    {
      'title': 'İhlâs Suresi (Kulhüvallahü)',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      'pronunciation': 'Kul hüvallâhu ehad. Allâhüssamed. Lem yelid ve lem yûled. Ve lem yekün lehû küfüven ehad.',
      'turkish': 'De ki: O Allah birdir. Allah Samed’dir. Doğurmamış ve doğurulmamıştır. O’na hiçbir denk yoktur.',
    },
    {
      'title': 'Felâk Suresi',
      'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nمِنْ شَرِّ مَا خَلَقَ\nوَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ\nوَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ\nوَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      'pronunciation': 'Kul eûzü birabbil felak... (Felâk)',
      'turkish': 'De ki: Yarattıklarının şerrinden, karanlığın çöktüğü zaman gecenin şerrinden... (Felâk Meali)',
    },
    {
      'title': 'Nâs Suresi',
      'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ\nإِلَٰهِ النَّاسِ\nمِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ\nالَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ\nمِنَ الْجِنَّةِ وَالنَّاسِ',
      'pronunciation': 'Kul eûzü birabbin nâs... (Nâs)',
      'turkish': 'De ki: İnsanların Rabbine, insanların Melik’ine, insanların İlâh’ına... (Nâs Meali)',
    },
    {
      'title': 'Âyet’el Kürsî',
      'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      'pronunciation': 'Allâhu lâ ilâhe illâ hüvel hayyül kayyûm... (Âyet’el Kürsî)',
      'turkish': 'Allah, O’ndan başka ilâh yoktur. Diridir, kayyûmdur... (Bakara 255 Meali)',
    },
    {
      'title': 'Sabah Duası',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'pronunciation': 'Asbahnâ ve asbahal mulku lillâh, velhamdulillâh.',
      'turkish': 'Sabahladık, mülk Allah\'ındır, hamd Allah\'a mahsustur.',
    },
    {
      'title': 'Akşam Duası',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'pronunciation': 'Emseynâ ve emsel mulku lillâh, velhamdulillâh.',
      'turkish': 'Akşamladık, mülk Allah\'ındır, hamd Allah\'a mahsustur.',
    },
    {
      'title': 'Yemek Duası (Başlarken)',
      'arabic': 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ',
      'pronunciation': 'Bismillâhi ve alâ beraketillâh.',
      'turkish': 'Allah\'ın adıyla ve Allah\'ın bereketi üzerine (başlarım).',
    },
    {
      'title': 'Yemek Duası (Bitince)',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      'pronunciation': 'Elhamdulillâhillezî et\'amenâ ve sekânâ ve cealenâ muslimîn.',
      'turkish': 'Bizi yedirip içiren ve bizi Müslümanlardan kılan Allah\'a hamdolsun.',
    },
    {
      'title': 'Yatarken Okunacak Dua',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'pronunciation': 'Bismike Allâhümme emûtu ve ahyâ.',
      'turkish': 'Allah\'ım! Senin isminle ölür (uyur) ve senin isminle dirilir (uyanırım).',
    },
    {
      'title': 'Uyanınca Okunacak Dua',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'pronunciation': 'Elhamdulillâhillezî ahyânâ ba\'de mâ emâtenâ ve ileyhin-nuşûr.',
      'turkish': 'Bizi öldürdükten sonra dirilten Allah\'a hamdolsun. Yeniden dirilip toplanmak O\'nadır.',
    },
    {
      'title': 'Evden Çıkarken',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'pronunciation': 'Bismillâhi, tevekkeltu alâllâh, lâ havle ve lâ kuvvete illâ billâh.',
      'turkish': 'Allah\'ın adıyla (çıkarım). Allah\'a tevekkül ettim. Güç ve kuvvet ancak Allah\'ın yardımıyladır.',
    },
    {
      'title': 'Eve Girerken',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
      'pronunciation': 'Allâhümme innî es\'eluke hayral-mevlici ve hayral-mahraci.',
      'turkish': 'Allah\'ım! Senden içeri girerken de dışarı çıkarken de hayırlısını istiyorum.',
    },
    {
      'title': 'Tuvalete Girerken',
      'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      'pronunciation': 'Allahümme innî eûzü bike minel hubusi vel habâis.',
      'turkish': 'Allah\'ım! Pislikten ve pis olan şeylerden (erkek ve dişi şeytanlardan) sana sığınırım.',
    },
    {
      'title': 'Tuvaletten Çıkarken',
      'arabic': 'غُفْرَانَكَ',
      'pronunciation': 'Gufrâneke.',
      'turkish': '(Allah\'ım!) Senden bağışlanma dilerim.',
    },
    {
      'title': 'Elbise Giyerken',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      'pronunciation': 'Elhamdulillâhillezî kesânî hâzâ ve razakanîhi min gayri havlin minnî ve lâ kuvveh.',
      'turkish': 'Bana bu elbiseyi giydiren ve tarafımdan hiçbir güç ve kuvvet olmadan bunu bana rızık olarak veren Allah\'a hamdolsun.',
    },
    {
      'title': 'Nazar Duası',
      'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      'pronunciation': 'Eûzü bi kelimâtillâhit-tâmmeti min külli şeytânin ve hâmmetin ve min külli aynin lâmmeh.',
      'turkish': 'Her türlü şeytandan, zararlı şeylerden ve kem gözlerden Allah’ın tam kelimelerine sığınırım.',
    },
    {
      'title': 'Seyyidül İstiğfar',
      'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      'pronunciation': 'Allahümme ente Rabbî lâ ilahe illâ ente halaktenî ve ene abdüke ve ene alâ ahdike ve va\'dike mesteta\'tü.',
      'turkish': 'Allah\'ım! Sen benim Rabbimsin. Senden başka ilah yoktur. Beni sen yarattın ve ben senin kulunum. Gücüm yettiğince sana verdiğim sözümde ve vaadimde duruyorum.',
    },
    {
      'title': 'Hz. Yunus Duası (Sıkıntı Anında)',
      'arabic': 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'pronunciation': 'Lâ ilâhe illâ ente subhâneke innî küntü minez-zâlimîn.',
      'turkish': 'Senden başka ilah yoktur. Sen her türlü noksanlıktan münezzehsin. Şüphesiz ben zalimlerden oldum.',
    },
    {
      'title': 'Bereket Duası',
      'arabic': 'اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَأَطْعِمْنَا خَيْرًا مِنْهُ',
      'pronunciation': 'Allahümme bârik lenâ fîhi ve et\'imnâ hayran minhu.',
      'turkish': 'Allah\'ım! Bunu bizim için bereketli kıl ve bize bundan daha hayırlısını yedir.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();
      duaBox = await Hive.openBox<Map>('duas');

      // Eğer box boşsa, varsayılan duaları ekle
      if (duaBox.isEmpty) {
        for (var i = 0; i < defaultDuas.length; i++) {
          await duaBox.put('default_$i', defaultDuas[i]);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Hive başlatma hatası: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showAddDuaDialog() async {
    final titleController = TextEditingController();
    final arabicController = TextEditingController();
    final pronunciationController = TextEditingController();
    final turkishController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Dua Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Dua Başlığı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: arabicController,
                  decoration: const InputDecoration(
                    labelText: 'Arapça Metin',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pronunciationController,
                  decoration: const InputDecoration(
                    labelText: 'Türkçe Okunuşu',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: turkishController,
                  decoration: const InputDecoration(
                    labelText: 'Türkçe Anlamı',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    arabicController.text.isNotEmpty &&
                    turkishController.text.isNotEmpty) {
                  final newDua = {
                    'title': titleController.text,
                    'arabic': arabicController.text,
                    'pronunciation': pronunciationController.text,
                    'turkish': turkishController.text,
                  };

                  await duaBox.put('custom_${DateTime.now().millisecondsSinceEpoch}', newDua);
                  setState(() {});
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dua başarıyla eklendi'),
                      backgroundColor: AppTheme.primaryYellow,
                    ),
                  );
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDuaDetail(String title, String arabic, String? pronunciation, String turkish, String key) async {
    try {
      await gamification_service.GamificationService.addPoints(
        'dua',
        gamification_service.GamificationService.pointsPerDua,
      );

      final current =
          await gamification_service.GamificationService.getAchievement('dua_read');
      final next = current + 1;
      await gamification_service.GamificationService.recordAchievement(
        'dua_read',
        next,
      );

      if (next >= 50) {
        await gamification_service.GamificationService.addBadge('dua_lover');
      }
    } catch (_) {
      // ignore
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Arapça:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  arabic,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 2,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                if (pronunciation != null && pronunciation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Okunuşu:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pronunciation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Türkçe:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  turkish,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (key.startsWith('custom_'))
              TextButton(
                onPressed: () async {
                  await duaBox.delete(key);
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dua silindi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text(
                  'Sil',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainScaffold = Scaffold.maybeOf(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dualar'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            mainScaffold?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDuaDialog,
            tooltip: 'Dua Ekle',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryYellow,
              ),
            )
          : ValueListenableBuilder(
              valueListenable: duaBox.listenable(),
              builder: (context, Box<Map> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 64,
                          color: AppTheme.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz dua eklenmemiş',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddDuaDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Dua Ekle'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final key = box.keyAt(index) as String;
                    final dua = box.getAt(index) as Map;

                    return DuaCard(
                      title: dua['title'] ?? '',
                      arabicText: dua['arabic'] ?? '',
                      turkishText: dua['turkish'] ?? '',
                      onTap: () => _showDuaDetail(
                        dua['title']!,
                        dua['arabic']!,
                        dua['pronunciation'],
                        dua['turkish']!,
                        key,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    duaBox.close();
    super.dispose();
  }
}
