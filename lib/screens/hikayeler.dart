import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class Hikayeler extends StatelessWidget {
  const Hikayeler({super.key});

  static const _stories = <_Story>[
    _Story(
      title: 'Doğruluk (Hz. Muhammed’in Güvenilirliği)',
      ageRange: '6-10',
      body:
          'Bir gün Mekke’de insanlar önemli eşyalarını kime emanet edeceklerini konuşuyordu. '
          'Çarşıda, sokakta, evlerde hep aynı soru vardı: “Bunu kime bıraksak içimiz rahat eder?”\n\n'
          'Herkes aynı kişiyi söylüyordu: Hz. Muhammed (s.a.v.). Çünkü o hiç yalan söylemez, '
          'kimseyi kandırmazdı. Söz verdi mi tutar, bir şey emanet edildi mi gözünden sakınırdı. '
          'Bu yüzden ona “El-Emin” yani güvenilir derlerdi.\n\n'
          'Bir gün küçük bir çocuk da babasının yanında bu konuşmaları duydu. Çocuk merak etti: '
          '“Baba, insanlar neden onu bu kadar seviyor?” diye sordu. Babası gülümsedi ve dedi ki: '
          '“Çünkü o doğru ve dürüst. Dürüst insanın sözü terazidir; eğilmez, bükülmez.”\n\n'
          'Çocuk o gün okulda bir hata yaptı. Öğretmeni “Kim yaptı?” diye sorunca çocuk önce korktu. '
          'Ama sonra doğruluğun ne kadar değerli olduğunu hatırladı ve “Ben yaptım, özür dilerim” dedi. '
          'Öğretmeni kızmak yerine, “Doğruyu söylemen çok güzel, gel birlikte düzeltelim” dedi.\n\n'
          'Çocuk eve dönerken şunu düşündü: “Doğru olmak bazen zor ama içimi hafifletiyor.”\n\n'
          'Bugün sen de bir şey söylemeden önce şunu düşünebilirsin: “Bu söz doğru mu? Doğruysa söyleyeyim, '
          'değilse susayım ya da düzeltmek için çalışayım.”',
      takeaway: 'Doğru söylemek güveni büyütür.',
    ),
    _Story(
      title: 'Paylaşmanın Bereketi',
      ageRange: '5-9',
      body:
          'Bir çocuk okulda öğle vakti çantasını açtı. Sandviçi vardı ama yanında oturan arkadaşı '
          'cüzdanını evde unuttuğu için hiçbir şey alamamıştı. Arkadaşının yüzü biraz üzgündü.\n\n'
          'Çocuk önce sandviçine baktı, sonra arkadaşına. İçinden “Acıkırım” diye geçti. Ama kalbinde '
          'başka bir ses daha vardı: “Paylaşırsan ikiniz de mutlu olursunuz.”\n\n'
          'Sandviçini ikiye böldü ve “İster misin?” dedi. Arkadaşı şaşırdı, sonra çok sevindi. '
          'Beraber yediler, sohbet ettiler. O gün sınıfta hava daha güzeldi.\n\n'
          'Ders bitince öğretmenleri bunu fark etmiş olmalı ki şöyle dedi: “Paylaşmak berekettir. '
          'Paylaşınca azalmış gibi görünür ama kalplerde çoğalır.”\n\n'
          'Çocuk eve gidince annesine anlattı. Annesi onu sarıldı ve şöyle söyledi: “İyilik yaptığında '
          'kalbin de büyür. Allah da iyiliği sever.”\n\n'
          'Ertesi gün arkadaşının annesi teşekkür etti. Çocuk anladı ki bazen küçük bir ikram, büyük bir sevinç olur. '
          'O günden sonra elindekini paylaşmayı alışkanlık yaptı.',
      takeaway: 'Paylaşınca azalmaz, bereketlenir.',
    ),
    _Story(
      title: 'Sabır Çiçeği',
      ageRange: '6-11',
      body:
          'Bir çocuk küçük bir saksıya tohum ekti. Üstünü toprakla kapattı, suyunu verdi. '
          'Sonra her sabah koşup saksıya baktı: “Hadi büyü!” diyordu.\n\n'
          'Bir gün geçti, hiçbir şey yok. İki gün geçti, yine yok. Çocuk üzülmeye başladı: '
          '“Ben yanlış mı yaptım?” dedi.\n\n'
          'Dedesi geldi, saksıya baktı ve çocuğun omzuna dokundu: “Sabır, tohumun toprağın altında '
          'güçlenmesini beklemektir. Toprağın altında görünmeyen bir çalışma olur. Sen görmezsin ama tohum çalışır.”\n\n'
          'Çocuk her gün sulamaya devam etti. Bir yandan da sabretmeyi denedi: oyun oynadı, dersini yaptı, '
          'akşam olunca yine saksıya baktı.\n\n'
          'Günler sonra minicik yeşil bir filiz çıktı. Çocuk sevinçten zıpladı. Dedesi gülerek şöyle dedi: '
          '“Gördün mü? Sabır çiçeği böyle açar.”\n\n'
          'Çocuk o an anladı: Güzel şeyler zaman ister. Sabreden insan, sonunda sevindiği bir sonuç görür.',
      takeaway: 'Sabır, güzel sonuçların anahtarıdır.',
    ),
    _Story(
      title: 'Temizlik İmandandır',
      ageRange: '5-10',
      body:
          'Bir çocuk oyun oynayıp eve geldi. Elleri toz olmuştu ama acıkmıştı. Hemen sofraya oturmak istedi. '
          'Babası ona gülümseyerek “Önce ellerimizi yıkayalım” dedi.\n\n'
          'Çocuk “Ama çok acıktım” diye söylendi. Babası da ona şu sözü hatırlattı: “Temizlik imandandır.”\n\n'
          'Çocuk lavaboya gitti, ellerini köpürterek yıkadı. Sonra yüzünü yıkadı. Dişlerini fırçaladı. '
          'Aynaya bakınca kendini daha iyi hissetti.\n\n'
          'Sofraya döndüğünde yemek daha güzel kokuyordu sanki. Babası dedi ki: “Temiz olunca hem sağlıklı oluruz '
          'hem de ibadete daha güzel hazırlanırız. Abdest de bunun bir parçasıdır.”\n\n'
          'Çocuk o gün şunu fark etti: Temizlik sadece dışımızı değil, içimizi de ferahlatır. '
          'Sonra gülerek dedi ki: “Temiz olunca sanki içim de ferahlıyor.”',
      takeaway: 'Temiz olmak hem sağlıktır hem de güzel bir alışkanlıktır.',
    ),
    _Story(
      title: 'Selam Vermek',
      ageRange: '5-9',
      body:
          'Bir çocuk apartmanda komşularını görünce utandı ve selam vermeden geçti. '
          'Annesi ona dedi ki: “Selam, kalpleri ısıtır.”\n\n'
          'Ertesi gün çocuk kapıda komşusunu görünce “Selamün aleyküm” dedi. Komşusu gülümsedi. '
          'Çocuk şunu fark etti: Selam vermek küçük ama çok güzel bir iyiliktir.',
      takeaway: 'Selam, sevgiyi ve güveni artırır.',
    ),
    _Story(
      title: 'Emanete Sahip Çıkmak',
      ageRange: '7-12',
      body:
          'Bir çocuk arkadaşından ödünç bir kitap aldı. Kitabı okurken dikkatli davrandı. '
          'Çünkü biliyordu: Emanet, başkasının hakkıdır.\n\n'
          'Kitabı tertemiz geri verdiğinde arkadaşı çok sevindi. Çocuk da içinden şöyle dedi: '
          '“Emanete sahip çıkan insan güvenilir olur.”',
      takeaway: 'Emanet, sorumluluktur.',
    ),
    _Story(
      title: 'Şükür Defteri',
      ageRange: '6-11',
      body:
          'Bir çocuk her gün akşam bir deftere o gün sevindiği 3 şeyi yazmaya başladı: '
          '“Sağlığım, ailem, arkadaşım…”\n\n'
          'Günler geçtikçe daha mutlu olduğunu fark etti. Çünkü şükreden insan, elindekinin '
          'kıymetini daha iyi anlar.',
      takeaway: 'Şükür mutluluğu çoğaltır.',
    ),
    _Story(
      title: 'Kırıcı Söz Yerine Güzel Söz',
      ageRange: '7-12',
      body:
          'Bir çocuk oyunda sinirlenince arkadaşına kırıcı bir söz söyleyecekti. '
          'Ama durdu ve düşündü: “Bu söz onu üzer mi?”\n\n'
          'Sonra “Hadi tekrar deneyelim” dedi. Oyun da dostluk da devam etti. '
          'Bazen güzel bir söz, büyük bir kavganın önüne geçer.',
      takeaway: 'Güzel söz sadakadır.',
    ),
    _Story(
      title: 'Vaktinde Namaz',
      ageRange: '8-13',
      body:
          'Bir çocuk oyun oynarken ezanı duydu. Önce “Biraz sonra kılarım” dedi. '
          'Sonra babası ona hatırlattı: “Vaktinde yapılan iş daha bereketlidir.”\n\n'
          'Çocuk abdest aldı, namazını kıldı ve sonra oyuna devam etti. '
          'İçinde bir huzur olduğunu hissetti.',
      takeaway: 'İbadeti ertelememek huzur verir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hikayeler'),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Card(
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryYellow,
                child: Icon(Icons.auto_stories, color: Colors.black),
              ),
              title: Text(
                story.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Yaş: ${story.ageRange}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _StoryDetail(story: story),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StoryDetail extends StatelessWidget {
  const _StoryDetail({required this.story});

  final _Story story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(story.title),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.child_friendly, color: Colors.black),
                  const SizedBox(width: 8),
                  Text('Önerilen yaş: ${story.ageRange}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  story.body,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      story.takeaway,
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

class _Story {
  const _Story({
    required this.title,
    required this.ageRange,
    required this.body,
    required this.takeaway,
  });

  final String title;
  final String ageRange;
  final String body;
  final String takeaway;
}
