import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'dart:math';

class BilgiKartlari extends StatefulWidget {
  const BilgiKartlari({Key? key}) : super(key: key);

  @override
  State<BilgiKartlari> createState() => _BilgiKartlariState();
}

class _BilgiKartlariState extends State<BilgiKartlari> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Bilgi Kartları'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'KISSALAR'),
            Tab(text: 'SAHABE'),
            Tab(text: 'FIKIH'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKissalarTab(),
          _buildSahabeTab(),
          _buildFikihTab(),
        ],
      ),
    );
  }

  Widget _buildKissalarTab() {
    return KnowledgeCardList(cards: _peygamberKissalari);
  }

  Widget _buildSahabeTab() {
    return KnowledgeCardList(cards: _sahabeHayati);
  }

  Widget _buildFikihTab() {
    return KnowledgeCardList(cards: _fikihBilgileri);
  }

  final List<Map<String, String>> _peygamberKissalari = [
    {
      'baslik': 'Hz. Adem (a.s.)',
      'ozet': 'İlk insan ve ilk peygamber',
      'icerik': 'Hz. Adem, Allah\'ın yarattığı ilk insan ve ilk peygamberdir. Allah, Hz. Adem\'i topraktan yarattı ve ona ruhundan üfledi. Meleklere Hz. Adem\'e secde etmelerini emretti. İblis hariç tüm melekler secde etti.'
          '\n\nHz. Adem\'e bütün isimleri öğretti. Cennette yaşarken yasak ağacın meyvesinden yemesi üzerine dünyaya indirildi. Ancak tövbe etti ve Allah tövbesini kabul etti.'
          '\n\nÖğüt: Hata yapmak insanidir, önemli olan tövbe etmek ve Allah\'a dönmektir.',
    },
    {
      'baslik': 'Hz. Nuh (a.s.)',
      'ozet': 'Tufan ve gemi',
      'icerik': 'Hz. Nuh, kavmine 950 yıl boyunca tevhid davetinde bulundu. Ancak çok az kişi ona iman etti. Kavmi ona eziyet etti ve inançlarından vazgeçmedi.'
          '\n\nAllah\'ın emriyle bir gemi yaptı. Tufan geldiğinde müminler ve hayvan çiftleri gemiye bindi. Tufan 40 gün 40 gece sürdü.'
          '\n\nÖğüt: Sabır ve sebat, davanın temel direğidir. Hz. Nuh gibi asla pes etmemeliyiz.',
    },
    {
      'baslik': 'Hz. İbrahim (a.s.)',
      'ozet': 'Halilullah - Allah\'ın dostu',
      'icerik': 'Hz. İbrahim, putperest bir toplumda doğdu. Babası Azer, put yapıp satıyordu. Hz. İbrahim, putların ilah olamayacağını kavmine anlattı.'
          '\n\nNemrud ateşe atmak istedi. Ateş ona serin ve selamet oldu. Oğlu İsmail\'i kurban etmekle imtihan edildi. Allah, onun yerine bir koç gönderdi.'
          '\n\nKabe\'yi oğlu İsmail ile birlikte yeniden inşa etti.'
          '\n\nÖğüt: Tevhid inancında kararlı olmak ve Allah\'a tam teslimiyet göstermek.',
    },
    {
      'baslik': 'Hz. Yusuf (a.s.)',
      'ozet': 'Kuyudan saraya',
      'icerik': 'Hz. Yusuf, Hz. Yakup\'un en sevdiği oğluydu. Kardeşleri kıskanarak onu kuyuya attılar. Bir kervan onu buldu ve Mısır\'a götürdü.'
          '\n\nZülihâ\'nın tuzağına düşmedi ve zindana atıldı. Rüya tabir etme yeteneği sayesinde firavunun rüyasını yorumladı.'
          '\n\nMısır\'ın hazinelerinden sorumlu kişi oldu. Kardeşleri kıtlık yüzünden ona geldiğinde onları affetti.'
          '\n\nÖğüt: İffetli olmak, sabırlı olmak ve affedici olmak gerçek erdemlerdir.',
    },
    {
      'baslik': 'Hz. Musa (a.s.)',
      'ozet': 'Firavun ile mücadele',
      'icerik': 'Hz. Musa, Firavun\'un İsrailoğullarına yaptığı zulümden dolayı korkuyla doğdu. Annesi onu bir sandığa koyup Nil nehrine bıraktı.'
          '\n\nFiravun\'un sarayında büyüdü. Yanlışlıkla bir adam öldürdükten sonra Medyen\'e kaçtı. Tur dağında Allah ile konuştu ve peygamberlik aldı.'
          '\n\nMiraclar göstererek Firavun\'a karşı mücadele etti. İsrailoğullarını Mısır\'dan çıkardı. Allah ona Tevrat\'ı indirdi.'
          '\n\nÖğüt: Zulme karşı durmak ve adalet için mücadele etmek.',
    },
  ];

  final List<Map<String, String>> _sahabeHayati = [
    {
      'baslik': 'Hz. Ebubekir (r.a.)',
      'ozet': 'Es-Sıddık - Doğrulayan',
      'icerik': 'Hz. Ebubekir, Peygamberimizin en yakın arkadaşıydı. İslam\'a daveti duyar duymaz tereddütsüz iman etti. Bu yüzden "Sıddık" (çok doğrulayan) lakabını aldı.'
          '\n\nMiraç olayında Peygamberimizi savundu. Hicret\'te onunla birlikte Sevr mağarasına saklandı.'
          '\n\nPeygamberimizin vefatından sonra ilk halife oldu. İrtidad olaylarıyla mücadele etti. Kur\'an\'ın bir mushaf halinde toplanmasını sağladı.'
          '\n\nÖğüt: Dostlukta sadakat ve imanda kararlılık.',
    },
    {
      'baslik': 'Hz. Ömer (r.a.)',
      'ozet': 'El-Faruk - Hak ile batılı ayıran',
      'icerik': 'Hz. Ömer, başlangıçta İslam\'a düşmandı. Kız kardeşini dövmeye giderken Kur\'an okumasını duydu ve Müslüman oldu.'
          '\n\nMüslümanların Kabe\'de açıkça namaz kılmasını sağladı. İkinci halife olarak İslam devletini büyük ölçüde genişletti.'
          '\n\nAdaletiyle ünlüydü. "Ömer\'in adaleti" söz oldu. Hristiyan bir kölenin şikayetini dinledi ve haklısını verdi.'
          '\n\nÖğüt: Adalet her şeyin temelidir. Güçlü olsak da adaletten ayrılmamalıyız.',
    },
    {
      'baslik': 'Hz. Osman (r.a.)',
      'ozet': 'Zün-Nureyn - İki nurlu',
      'icerik': 'Hz. Osman, Peygamberimizin iki kızıyla evlendi. Bu yüzden "Zün-Nureyn" (iki nurlu) lakabını aldı.'
          '\n\nMalını İslam davasında cömertçe harcadı. Tebük seferi için tüm orduyu donattı.'
          '\n\nÜçüncü halife olarak Kur\'an\'ı standart mushaf haline getirdi. İslam topraklarını daha da genişletti.'
          '\n\nEvinde kuşatma altındayken Kur\'an okurken şehit edildi.'
          '\n\nÖğüt: Cömertlik ve infakta bulunmak Allah\'a yakınlaştırır.',
    },
    {
      'baslik': 'Hz. Ali (r.a.)',
      'ozet': 'Esedullah - Allah\'ın arslanı',
      'icerik': 'Hz. Ali, Peygamberimizin amcasının oğlu ve damadıydı. Çocukken Müslüman oldu. Peygamberimizin yatağında yatarak hicret etmesini sağladı.'
          '\n\nCesaretiyle ünlüydü. Hayber kalesini tek başına fethetti. Bilgisiyle de biliniyordu.'
          '\n\nDördüncü halife oldu. Hz. Fatıma ile evlendi. Hz. Hasan ve Hz. Hüseyin onun oğullarıdır.'
          '\n\nKufe\'de namazda şehit edildi.'
          '\n\nÖğüt: Cesaret ve ilim bir arada olmalıdır.',
    },
    {
      'baslik': 'Hz. Bilal (r.a.)',
      'ozet': 'İlk Müezzin',
      'icerik': 'Hz. Bilal Habeşistanlı bir köleydi. İslam\'ı seçtiği için efendisi Ümeyye bin Halef tarafından işkence gördü.'
          '\n\nKızgın kumların üzerine yatırılıp göğsüne taş konuldu. "Ehad, Ehad" (Allah tektir) diyerek sabretti.'
          '\n\nHz. Ebubekir onu satın alarak özgür bıraktı. Peygamberimizin ilk müezzini oldu. Güzel sesiyle ezan okurdu.'
          '\n\nÖğüt: İman uğruna çekilen sıkıntılara sabretmek ve prensiplerden vazgeçmemek.',
    },
  ];

  final List<Map<String, String>> _fikihBilgileri = [
    {
      'baslik': 'Abdest Nasıl Alınır?',
      'ozet': 'Abdest şartları ve adımları',
      'icerik': 'Abdest, namaz için gerekli temizliktir.\n\nFarzları:\n1. Yüzü yıkamak\n2. Dirseklerle birlikte kolları yıkamak\n3. Başın dörtte birini mesh etmek\n4. Topuklarla birlikte ayakları yıkamak'
          '\n\nSünnetleri:\n• Niyet etmek\n• Besmele çekmek\n• Misvak kullanmak\n• Elleri yıkamak\n• Ağzı çalkalamak\n• Burnu temizlemek'
          '\n\nAbdest alan kişi temiz su kullanmalı ve her organı üç kez yıkamalıdır.',
    },
    {
      'baslik': 'Gusül Abdesti',
      'ozet': 'Boy abdesti nasıl alınır?',
      'icerik': 'Gusül, tüm vücudun yıkanmasıyla alınan abdest türüdür.'
          '\n\nFarzları:\n1. Ağza su vermek\n2. Burna su çekmek\n3. Tüm vücudu yıkamak'
          '\n\nGusül gerektiren haller:\n• Cünüplük\n• Hayız\n• Nifas\n• Ölüm (ölüye gusül)'
          '\n\nGusül alırken önce eller, sonra avret mahalli, ardından abdest alınır. En son tüm vücut yıkanır.',
    },
    {
      'baslik': 'Namazda Okunacaklar',
      'ozet': 'Namaz okumaları sırası',
      'icerik': 'Namaz kılarken okunması gerekenler:\n\n1. İftitah Tekbiri: Allahu Ekber\n2. Sübhaneke Duası\n3. Euzü Besmele\n4. Fatiha Suresi\n5. Zamm-ı sure (ek sure)\n6. Rükuda: Sübhane Rabbiye-l Azim\n7. Secdede: Sübhane Rabbiye-l Ala\n8. Kaidede: Ettehiyyatü, Allahumme Salli, Allahumme Barik'
          '\n\nİlk iki rekatta sure okunur, son rekatlar sadece Fatiha ile kılınır.',
    },
    {
      'baslik': 'Zekat Kimlere Verilir?',
      'ozet': 'Zekat\'ın 8 hak sahibi',
      'icerik': 'Zekat, Kur\'an\'da belirtilen 8 sınıfa verilir:\n\n1. Fakirler\n2. Miskinler\n3. Zekat toplayanlar\n4. Kalpleri İslam\'a ısındırılacak olanlar\n5. Köleler (özgürlüğe kavuşturulacaklar)\n6. Borçlular\n7. Allah yolunda olanlar\n8. Yolda kalanlar'
          '\n\nZekat, ana-baba, eş, çocuk ve torunlara verilemez. Malın nisaba ulaşması ve bir yıl geçmesi gerekir.',
    },
    {
      'baslik': 'Oruç Tutma Adabı',
      'ozet': 'Oruç nasıl tutulur?',
      'icerik': 'Oruç, imsak vaktinden akşama kadar yemek, içmek ve cinsel ilişkiden uzak kalmaktır.'
          '\n\nSahur:\n• Sahur yemek sünnettir\n• İmsak vaktine kadar yenilebilir'
          '\n\nOrucu Bozan Şeyler:\n• Kasıtlı yemek-içmek\n• Cinsel ilişki\n• Kusma (kasıtlı)\n• Hayz ve nifas'
          '\n\nOrucu Bozm ayanlar:\n• Unutarak yemek-içmek\n• Zorla yedirilmek\n• Rüyada ihlal'
          '\n\nİftar vaktinde "Allah\'ım! Senin için oruç tuttum, sana iman ettim" duası okunur.',
    },
  ];
}

class KnowledgeCardList extends StatelessWidget {
  final List<Map<String, String>> cards;

  const KnowledgeCardList({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showCardDetail(context, card),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppTheme.darkYellow,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['baslik']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card['ozet']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCardDetail(BuildContext context, Map<String, String> card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['baslik']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              card['ozet']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    card['icerik']!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
