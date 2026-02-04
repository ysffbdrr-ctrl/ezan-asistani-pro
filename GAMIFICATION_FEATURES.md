# Ezan Asistanı - Gamification & Eğitim Özellikleri

## 🎮 Eklenen Gamification ve Eğitim Sistemi

### ✨ Yeni Özellikler Özeti

1. **🏆 Profil & İstatistikler** - Puan, seviye, rozet sistemi
2. **❓ Günün Sorusu** - Her gün yeni bir İslami bilgi sorusu
3. **🎯 İslam Quiz** - 20+ soruluk interaktif quiz sistemi
4. **📚 Bilgi Kartları** - Peygamber kıssaları, sahabe hayatı, fıkıh bilgileri

---

## 1️⃣ Profil & İstatistikler Sistemi

**Dosya**: `lib/screens/profil_istatistik.dart`
**Service**: `lib/services/gamification_service.dart`

### Özellikler:
- ✅ **Puan Sistemi**: Her eylem için puan kazanma
- ✅ **Seviye Sistemi**: Puanla seviye atlama (her 100 puan = 1 seviye)
- ✅ **8 Farklı Rozet**: Başarıları temsil eden rozetler
- ✅ **Seri (Streak) Takibi**: Ardışık gün takibi
- ✅ **İlerleme Çubuğu**: Sonraki seviyeye ne kadar kaldığı
- ✅ **Seviye Emojileri**: Her seviye için özel emoji (✨🌟⭐🏆💎👑)

### Puan Kazanma Sistemi:

| Eylem | Puan |
|-------|------|
| Namaz Kıl | +10 puan |
| Kur'an Oku | +20 puan |
| Dua Et | +5 puan |
| Quiz Çöz | +15 puan |
| Günlük Soru | +10 puan |
| Seri Bonus | +25 puan |

### Rozet Sistemi:

| Rozet | Açıklama | Gerekli |
|-------|----------|---------|
| 🕌 İlk Namaz | İlk namazını takip ettin | 1 namaz |
| ⭐ Namaz Ustası | 100 namaz kıldın | 100 namaz |
| 📖 Kur'an Okuyucusu | 10 sure okudun | 10 sure |
| 🎓 İlim Arayan | 50 quiz sorusu doğru | 50 soru |
| 🔥 7 Gün Serisi | 7 gün üst üste namaz | 7 gün |
| 💎 30 Gün Serisi | 30 gün üst üste namaz | 30 gün |
| 🏆 Seviye 10 | 10. seviyeye ulaştın | Seviye 10 |
| 🤲 Dua Seven | 50 dua okudun | 50 dua |

### Koddan Örnek:
```dart
// Puan ekleme
await GamificationService.addPoints('prayer', 10);

// Rozet ekleme
await GamificationService.addBadge('first_prayer');

// Seviye hesaplama
int level = GamificationService.calculateLevel(points);
```

---

## 2️⃣ Günün Sorusu

**Dosya**: `lib/screens/gunluk_soru.dart`

### Özellikler:
- ✅ **Günlük Yeni Soru**: Her gün farklı bir soru
- ✅ **4 Seçenekli**: Çoktan seçmeli format
- ✅ **Anında Geri Bildirim**: Doğru/yanlış gösterimi
- ✅ **Detaylı Açıklama**: Her sorunun açıklaması
- ✅ **Streak Sistemi**: Ardışık doğru cevap takibi
- ✅ **Puan Kazanma**: Doğru cevap başına +10 puan
- ✅ **10+ Soru Veritabanı**: Sürekli dönen sorular

### Soru Kategorileri:
- Peygamberler
- Kur'an
- İbadet
- Siyer (Hz. Muhammed'in hayatı)
- Tarih
- Sahabe

### Özellikler:
- Soru her gün otomatik değişir
- Bir kez cevaplanabİlir
- Doğru cevap: +10 puan + Streak devam
- Yanlış cevap: Streak sıfırlanır
- Streak bonusu: 🔥 işareti gösterilir

### Örnek Sorular:
```
1. Hangi peygambere "Halilullah" denir? 
   → Hz. İbrahim ✅

2. Kur'an-ı Kerim'in ilk inen ayeti hangisidir?
   → Alak ✅

3. İslam'da namazların ilki hangisidir?
   → Öğle ✅
```

---

## 3️⃣ İslam Quiz

**Dosya**: `lib/screens/islam_quiz.dart`

### Özellikler:
- ✅ **20+ Soru Veritabanı**: Geniş soru havuzu
- ✅ **10 Soruluk Quiz**: Rastgele seçilen sorular
- ✅ **Kategoriler**: Temel Bilgiler, Kur'an, Siyer, İbadet, Tarih, Sahabe
- ✅ **İlerleme Takibi**: Soru sayacı ve ilerleme çubuğu
- ✅ **Anında Feedback**: Yeşil (doğru) / Kırmızı (yanlış)
- ✅ **Puan Sistemi**: Her doğru cevap başına puan
- ✅ **Sonuç Ekranı**: Skor, emoji ve motivasyon mesajı
- ✅ **Tekrar Oynama**: Sınırsız oynanabilir

### Sonuç Değerlendirmesi:
| Skor | Emoji | Mesaj |
|------|-------|-------|
| 100% | 🏆 | Mükemmel! Tüm soruları doğru cevapladınız! |
| 80%+ | 🌟 | Harika! Çok başarılısınız! |
| 60%+ | 👍 | İyi! Güzel bir performans! |
| 40%+ | 💪 | Fena değil! Biraz daha çalışmalısınız. |
| <40% | 📚 | Daha fazla çalışmalısınız. Pes etmeyin! |

### Örnek Sorular:
```
1. İslam'ın kaç şartı vardır?
   A) 3  B) 4  C) 5 ✅  D) 6

2. Kur'an-ı Kerim kaç surede nazil olmuştur?
   A) 30  B) 60  C) 114 ✅  D) 120

3. İlk vahiy hangi mağarada inmiştir?
   A) Sevr  B) Hira ✅  C) Uhud  D) Bedr
```

---

## 4️⃣ Bilgi Kartları

**Dosya**: `lib/screens/bilgi_kartlari.dart`

### 3 Kategori:

#### 📖 Peygamber Kıssaları (5 Kıssa)
1. **Hz. Adem (a.s.)** - İlk insan ve ilk peygamber
2. **Hz. Nuh (a.s.)** - Tufan ve gemi
3. **Hz. İbrahim (a.s.)** - Halilullah - Allah'ın dostu
4. **Hz. Yusuf (a.s.)** - Kuyudan saraya
5. **Hz. Musa (a.s.)** - Firavun ile mücadele

#### 👥 Sahabe Hayatı (5 Sahabi)
1. **Hz. Ebubekir (r.a.)** - Es-Sıddık - Doğrulayan
2. **Hz. Ömer (r.a.)** - El-Faruk - Hak ile batılı ayıran
3. **Hz. Osman (r.a.)** - Zün-Nureyn - İki nurlu
4. **Hz. Ali (r.a.)** - Esedullah - Allah'ın arslanı
5. **Hz. Bilal (r.a.)** - İlk Müezzin

#### 📚 Fıkıh Bilgileri (5 Konu)
1. **Abdest Nasıl Alınır?** - Abdest şartları ve adımları
2. **Gusül Abdesti** - Boy abdesti nasıl alınır?
3. **Namazda Okunacaklar** - Namaz okumaları sırası
4. **Zekat Kimlere Verilir?** - Zekat'ın 8 hak sahibi
5. **Oruç Tutma Adabı** - Oruç nasıl tutulur?

### Özellikler:
- ✅ **Tab Yapısı**: 3 kategori arasında geçiş
- ✅ **Kart Listesi**: Her kategoride 5 bilgi kartı
- ✅ **Modal Detay**: Tıklayınca tam ekran açıklama
- ✅ **Özet + Detay**: Kısa özet ve uzun içerik
- ✅ **Öğüt Bölümü**: Her kıssadan alınacak ders

---

## 🎨 UI/UX Tasarımı

### Profil & İstatistikler:
```
┌─────────────────────────────┐
│ Seviye 5 ⭐                  │ (Sarı Kart)
│ 450 Puan                     │
│ ▓▓▓▓▓▓▓▓▓░░ 90%             │ (İlerleme Çubuğu)
│ Sonraki: 50 puan            │
├─────────────────────────────┤
│ Günlük Seri: 7 🔥           │
├─────────────────────────────┤
│ ROZETLER (3/8)              │
│ 🕌 ⭐ 📖 🎓 🔥 💎 🏆 🤲    │
│ (Kazanılanlar sarı)          │
└─────────────────────────────┘
```

### Günün Sorusu:
```
┌─────────────────────────────┐
│ Bugünün Sorusu  🔥 7        │ (Streak)
│ 10 Kasım 2025               │
├─────────────────────────────┤
│ [Peygamberler]              │ (Kategori Chip)
│                             │
│ Hangi peygambere            │ (Soru Kartı)
│ "Halilullah" denir?         │
│                             │
│ [ Hz. Musa        ]         │ (Seçenekler)
│ [ Hz. İbrahim  ✅ ]         │
│ [ Hz. Muhammed    ]         │
│ [ Hz. İsa         ]         │
└─────────────────────────────┘
```

### İslam Quiz:
```
┌─────────────────────────────┐
│ Soru 5/10 ⭐ Skor: 4        │ (İlerleme)
│ ▓▓▓▓▓░░░░░ 50%             │
├─────────────────────────────┤
│ [Kur'an]                    │
│                             │
│ Kur'an-ı Kerim'in en        │
│ uzun suresi hangisidir?     │
│                             │
│ [ Bakara     ✅ ]           │ (Yeşil)
│ [ Al-i İmran    ]           │
│ [ Nisa          ]           │
│ [ Maide         ]           │
└─────────────────────────────┘
```

---

## 📊 Veri Saklama

### SharedPreferences Anahtarları:

**Gamification Service:**
```
- total_points          → Toplam puan
- user_level           → Kullanıcı seviyesi
- earned_badges        → Kazanılan rozetler (Liste)
- prayer_streak        → Namaz serisi
- achievement_[id]     → Başarı değerleri
```

**Günlük Soru:**
```
- last_daily_question_date → Son cevap tarihi
- daily_question_streak    → Doğru cevap serisi
```

---

## 🎯 Motivasyon Sistemi

### Seviye Emojileri:
- Seviye 1-9: ✨ (Yıldız)
- Seviye 10-19: 🌟 (Parlak Yıldız)
- Seviye 20-29: ⭐ (Büyük Yıldız)
- Seviye 30-39: 🏆 (Kupa)
- Seviye 40-49: 💎 (Elmas)
- Seviye 50+: 👑 (Taç)

### Streak Göstergeleri:
- 0 gün: ⭐ (Normal)
- 7+ gün: 🔥 (Ateş - Turuncu arka plan)
- 30+ gün: 💎 (Rozet kazanma)

### Motivasyon Mesajları:
```
5/5 namaz: "Mükemmel! Bugün tüm namazlarını kıldın!"
4/5 namaz: "Harika gidiyorsun! Sadece 1 namaz kaldı!"
3/5 namaz: "Güzel! Devam et! Yarıyı geçtin!"
2/5 namaz: "İyi başlangıç! Güne güzel başladın!"
1/5 namaz: "Bir adım bile değerli! Bir adım bile çok değerli!"
0/5 namaz: "Başla şimdi! Her an başlamak için iyi bir an!"
```

---

## 📱 Menü Yapısı (Güncellenmiş)

### Drawer Menu:
1. 👤 **Profilim & İstatistikler** ⭐ YENİ
2. ❓ **Günün Sorusu** ⭐ YENİ
3. 🎯 **İslam Quiz** ⭐ YENİ
4. 📚 **Bilgi Kartları** ⭐ YENİ
5. 📖 Kur'an-ı Kerim
6. ✅ Namaz Takip
7. 🕌 Namaz Nasıl Kılınır?
8. 🔔 Günlük Dua Bildirimi
9. ✈️ Umre & Hac Rehberi
10. 💰 Zekat Hesaplama
11. 📿 Zikirmatik

**Toplam: 11 Özellik!**

---

## 🔧 Teknik Detaylar

### Yeni Dosyalar:
```
lib/services/
└── gamification_service.dart  (Puan, seviye, rozet yönetimi)

lib/screens/
├── profil_istatistik.dart    (Profil & İstatistikler)
├── gunluk_soru.dart           (Günün Sorusu)
├── islam_quiz.dart            (İslam Quiz)
└── bilgi_kartlari.dart        (Bilgi Kartları)
```

### Sınıflar:
```dart
// Gamification Service
- GamificationService       → Puan, seviye, rozet yönetimi
- Badge                     → Rozet modeli
- BadgeDefinitions          → Tüm rozetlerin tanımları

// Screens
- ProfilIstatistik          → Profil ekranı
- GunlukSoru               → Günlük soru ekranı
- IslamQuiz                → Quiz ekranı
- BilgiKartlari            → Bilgi kartları ekranı
- KnowledgeCardList        → Kart liste widget'ı
```

---

## 📊 Analiz Sonucu

```bash
flutter analyze
```

**Sonuç**: ✅ Sadece 75 info seviye uyarı (styling önerileri)
- ❌ 0 ERROR
- ⚠️ 1 WARNING (unused field - kritik değil)
- ℹ️ 75 INFO

---

## 🚀 Kullanım Senaryoları

### Senaryo 1: Yeni Kullanıcı
1. Uygulamayı açar
2. "Profilim" → Seviye 1, 0 puan görür
3. "Günün Sorusu" → İlk soruyu cevaaplar (+10 puan)
4. "İslam Quiz" → Quiz çözer (+150 puan)
5. Seviye 2'ye yükselir 🌟

### Senaryo 2: Namaz Takibi
1. Sabah namazını kılar ve işaretler (+10 puan)
2. Öğle namazını kılar (+10 puan)
3. İkindi namazını kılar (+10 puan)
4. Akşam namazını kılar (+10 puan)
5. Yatsı namazını kılar (+10 puan)
6. Günlük hedef tamamlanır, streak +1

### Senaryo 3: Bilgi Öğrenme
1. "Bilgi Kartları" → Peygamber Kıssaları
2. Hz. İbrahim kıssasını okur
3. "İslam Quiz" → Öğrendiklerini test eder
4. "Günün Sorusu" → İlgili soru gelirse doğru cevaplayabilir

---

## 🎊 Gamification Özellikleri Özeti

### Kazanç Mekanikleri:
- ✅ Puan sistemi (6 farklı eylem)
- ✅ Seviye atlama (100 puan = 1 seviye)
- ✅ Rozet kazanma (8 farklı rozet)
- ✅ Streak takibi (ardışık gün bonusu)
- ✅ Başarı kayıtları (achievement tracking)

### Görselleştirme:
- ✅ İlerleme çubukları
- ✅ Seviye emojileri
- ✅ Rozet ikonları
- ✅ Streak ateşleri
- ✅ Renk kodları (yeşil/kırmızı/sarı)

### Eğitim İçeriği:
- ✅ 20+ quiz sorusu
- ✅ 10+ günlük soru
- ✅ 5 peygamber kıssası
- ✅ 5 sahabe hikayesi
- ✅ 5 fıkıh konusu

**Toplam: 45+ Eğitim İçeriği!**

---

## 💡 Gelecek Geliştirmeler (Opsiyonel)

### Gamification:
- [ ] Leaderboard (Sıralama tablosu)
- [ ] Arkadaşlarla karşılaştırma
- [ ] Günlük/haftalık/aylık hedefler
- [ ] Özel rozetler (bayram, ramazan)
- [ ] Avatar sistemi

### Eğitim:
- [ ] Daha fazla quiz sorusu (100+)
- [ ] Video içerikler
- [ ] Sesli anlatım
- [ ] Notlar alma özelliği
- [ ] Favori kartlar

### Bildirimler:
- [ ] Gerçek push notification
- [ ] Güneş doğarken motivasyon
- [ ] Günbatımında hatırlatma
- [ ] "Bugün dua ettin mi?" mesajı

---

## ✅ Test Edildi

- ✅ Puan kazanma sistemi çalışıyor
- ✅ Seviye atlama fonksiyonel
- ✅ Rozetler doğru gösteriliyor
- ✅ Quiz puanlama doğru
- ✅ Günlük soru değişiyor
- ✅ Streak takibi çalışıyor
- ✅ Bilgi kartları okunuyor
- ✅ Tüm UI sorunsuz

---

## 🎉 Özet

**4 Yeni Gamification Özelliği Başarıyla Eklendi!**

1. ✅ **Profil & İstatistikler** - Puan, seviye, rozet sistemi
2. ✅ **Günün Sorusu** - Her gün yeni soru ve streak
3. ✅ **İslam Quiz** - 20+ soruluk quiz oyunu
4. ✅ **Bilgi Kartları** - 15 kart ile eğitim içeriği

### Etkileyici İstatistikler:
- **11 Ana Özellik** (4 yeni + 7 eski)
- **8 Rozet Türü**
- **45+ Eğitim İçeriği**
- **6 Puan Kazanma Yolu**
- **Sınırsız Seviye**
- **3 Kategori Bilgi Kartı**

**Tam kapsamlı bir İslami gamification ve eğitim sistemi!** 🚀

---

**Not**: Bu özellikler eğitim, motivasyon ve bilgilenme amaçlıdır. Dini konularda mutlaka uzman görüşü alınmalıdır.
