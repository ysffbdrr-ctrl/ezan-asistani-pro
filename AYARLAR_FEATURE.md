# ⚙️ Ayarlar ve Kişiselleştirme Sistemi

## 🎯 Özellikler

### 1. **Bildirim Ayarları** 🔔
- ✅ Bildirimleri Aç/Kapa
- ✅ Sesli Uyarı
- ✅ Titreşim
- ✅ Bildirim Süresi (5, 10, 15, 20, 30 dakika)

### 2. **Görünüm Ayarları** 🎨
- ✅ Tema Rengi Seçimi (Sarı, Yeşil, Mavi, Mor, Turuncu)
- ✅ Karanlık Mod (Yakında)
- ✅ Büyük Yazı Modu

### 3. **Konum Ayarları** 📍
- ✅ Otomatik Konum
- ✅ Manuel Şehir Seçimi (Yakında)

### 4. **Hakkında** ℹ️
- ✅ Uygulama Sürümü
- ✅ Gizlilik Politikası
- ✅ Kullanım Koşulları
- ✅ Lisanslar

### 5. **Veri Yönetimi** ⚠️
- ✅ Ayarları Sıfırla
- ✅ Tüm Verileri Sil

---

## 📱 Ekran Görünümü

```
┌──────────────────────────┐
│   ⚙️ Ayarlar         🔄  │
├──────────────────────────┤
│                          │
│ 🔔 Bildirim Ayarları     │
│ ┌──────────────────────┐ │
│ │ ✓ Bildirimler        │ │
│ │ ✓ Sesli Uyarı        │ │
│ │ ✓ Titreşim           │ │
│ │ Bildirim Süresi: 10dk│ │
│ └──────────────────────┘ │
│                          │
│ 🎨 Görünüm              │
│ ┌──────────────────────┐ │
│ │ Tema: Sarı 🌟       │ │
│ │ ☐ Karanlık Mod       │ │
│ │ ☐ Büyük Yazı         │ │
│ └──────────────────────┘ │
│                          │
│ 📍 Konum                │
│ ┌──────────────────────┐ │
│ │ ✓ Otomatik Konum     │ │
│ └──────────────────────┘ │
│                          │
│ ℹ️ Hakkında              │
│ ⚠️ Tehlikeli Bölge       │
│                          │
└──────────────────────────┘
```

---

## 🔧 Teknik Detaylar

### Dosyalar:
1. **lib/screens/ayarlar.dart** - Ayarlar ekranı
2. **lib/services/ayarlar_service.dart** - Ayarlar servisi

### Kullanılan Teknolojiler:
- SharedPreferences (veri saklama)
- StatefulWidget (dinamik UI)
- AlertDialog (onay mesajları)

### Veri Saklama:
```dart
// Ayarlar SharedPreferences'ta saklanır
'bildirimler_aktif': bool
'sesli_uyari': bool
'titresim': bool
'bildirim_suresi': int (5, 10, 15, 20, 30)
'secilen_tema': String ('Sarı', 'Yeşil', 'Mavi', vb.)
'karanlik_mod': bool
'buyuk_yazi': bool
'otomatik_konum': bool
```

---

## 🎨 Tema Sistemi

### Mevcut Temalar:
1. **Sarı** 🌟 (Varsayılan)
   - Ana Renk: #FFC107
   - Emoji: 🌟

2. **Yeşil** 🌿
   - Ana Renk: Green
   - Emoji: 🌿

3. **Mavi** 🌊
   - Ana Renk: Blue
   - Emoji: 🌊

4. **Mor** 💜
   - Ana Renk: Purple
   - Emoji: 💜

5. **Turuncu** 🔥
   - Ana Renk: Orange
   - Emoji: 🔥

**Not**: Tema değişikliği yakında aktif olacak!

---

## 🔔 Bildirim Ayarları

### Bildirim Süresi:
Namaz vaktinden kaç dakika önce bildirim alacağınızı seçin:
- 5 dakika
- 10 dakika (Varsayılan)
- 15 dakika
- 20 dakika
- 30 dakika

### Sesli Uyarı:
- ✅ Aktif: Bildirim geldiğinde ses çalar
- ❌ Pasif: Sessiz bildirim

### Titreşim:
- ✅ Aktif: Bildirimde titreşir
- ❌ Pasif: Titreşim yok

---

## 📍 Konum Ayarları

### Otomatik Konum:
- ✅ **Aktif**: GPS ile otomatik konum algılama
- ❌ **Pasif**: Manuel şehir seçimi (Yakında)

---

## 💾 Veri Yönetimi

### Ayarları Sıfırla:
```
Tüm ayarlar varsayılan değerlere döner:
• Bildirimler: Açık
• Sesli Uyarı: Açık
• Titreşim: Açık
• Bildirim Süresi: 10 dakika
• Tema: Sarı
• Karanlık Mod: Kapalı
• Büyük Yazı: Kapalı
• Otomatik Konum: Açık
```

### Tüm Verileri Sil (⚠️ Tehlikeli):
```
Silinecek veriler:
✗ Ayarlar
✗ Puan ve rozetler
✗ İstatistikler
✗ Kişisel veriler

⚠️ Bu işlem geri alınamaz!
```

---

## 🚀 Kullanım

### 1. Ayarlara Gitmek:
```
Ana Menü → ☰ → Ayarlar
```

### 2. Ayar Değiştirmek:
```dart
// Switch ile aktif/pasif
Bildirimler: [  ✓  ] Açık

// Dropdown ile seçim
Bildirim Süresi: [ 10 dk ▼ ]

// Dialog ile seçim
Tema: Sarı → Tıkla → Tema seç
```

### 3. Ayarları Sıfırlamak:
```
Sağ üst → 🔄 → Onay → Sıfırla
```

---

## 📊 Ayar Davranışları

### Bildirimler Kapalıysa:
- Sesli Uyarı → Pasif (değiştirilemez)
- Titreşim → Pasif (değiştirilemez)
- Bildirim Süresi → Pasif (değiştirilemez)

### Otomatik Konum Kapalıysa:
- Şehir Seçimi → Aktif olur

### Büyük Yazı Aktifse:
- Uygulama yeniden başlatılmalı
- Değişikliklerin uygulanması için

---

## 🎯 Özellik Durumları

| Özellik | Durum | Notlar |
|---------|-------|--------|
| Bildirim Aç/Kapa | ✅ Aktif | Çalışıyor |
| Sesli Uyarı | ✅ Aktif | Çalışıyor |
| Titreşim | ✅ Aktif | Çalışıyor |
| Bildirim Süresi | ✅ Aktif | 5-30 dk arası |
| Tema Seçimi | 🔄 Hazır | Yakında aktif |
| Karanlık Mod | 🔜 Yakında | Geliştirme aşamasında |
| Büyük Yazı | ✅ Aktif | Yeniden başlatma gerekli |
| Otomatik Konum | ✅ Aktif | GPS kullanır |
| Manuel Şehir | 🔜 Yakında | Geliştirme aşamasında |

---

## 💡 İpuçları

### 1. Bildirim Gelmiyorsa:
```
Ayarlar → Bildirimler → Kontrol et
✓ Bildirimler Açık mı?
✓ Bildirim Süresi Uygun mu?
```

### 2. Batarya Tasarrufu:
```
• Bildirimleri Kapat (kullanmıyorsanız)
• Sesli Uyarıyı Kapat
• Titreşimi Kapat
```

### 3. Gece Modu:
```
• Karanlık Mod (Yakında aktif olacak)
• Geçici: Telefonun karanlık modunu kullanın
```

---

## 🔐 Gizlilik

### Saklanan Veriler:
```
Tüm ayarlar sadece cihazınızda saklanır:
✓ Yerel depolama (SharedPreferences)
✗ Sunucuya gönderilmez
✗ İnternete yüklenmez
✗ Üçüncü taraflarla paylaşılmaz
```

### Veri Silme:
```
Ayarlar → Tehlikeli Bölge → Tüm Verileri Sil
veya
Telefon Ayarları → Uygulamalar → Ezan Asistanı → Veriyi Temizle
```

---

## 🎨 UI/UX

### Renk Kodları:
```
Ayarlar Kartları: Beyaz
Başlıklar: Gri (#757575)
Switch Aktif: Sarı (#FFC107)
Tehlikeli Bölge: Kırmızı (#F44336)
Başarı Mesajı: Yeşil
```

### İkonlar:
```
🔔 Bildirimler
🎨 Görünüm
📍 Konum
ℹ️ Hakkında
⚠️ Tehlikeli
🔄 Sıfırla
⚙️ Ayarlar
```

---

## 📱 Ekran Akışı

```
Ana Menü
   │
   ├─→ ☰ Menü
   │      │
   │      └─→ ⚙️ Ayarlar
   │             │
   │             ├─→ 🔔 Bildirim Ayarları
   │             ├─→ 🎨 Görünüm
   │             ├─→ 📍 Konum
   │             ├─→ ℹ️ Hakkında
   │             └─→ ⚠️ Tehlikeli Bölge
   │
   └─→ Geri
```

---

## 🧪 Test Senaryoları

### 1. Bildirim Ayarları:
```
1. Bildirimleri Kapat
2. Test bildirimi gönder → Gelmemeli
3. Bildirimleri Aç
4. Test bildirimi gönder → Gelmeli ✅
```

### 2. Bildirim Süresi:
```
1. Bildirim Süresini 5 dk yap
2. Ezan vakitlerini yenile
3. 5 dk önce bildirim gelmeli ✅
```

### 3. Tema Seçimi:
```
1. Tema seç → Yeşil
2. Mesaj görünür: "Yakında aktif olacak"
3. Ayarlar kaydedilir ✅
```

### 4. Ayarları Sıfırla:
```
1. Ayarları değiştir
2. Sağ üst → 🔄
3. Onay ver
4. Tüm ayarlar varsayılana döner ✅
```

---

## 🚀 Gelecek Geliştirmeler

### Yakında:
- [ ] Karanlık Mod aktif olacak
- [ ] Manuel şehir seçimi
- [ ] Tema değişiklikleri uygulanacak
- [ ] Yedekleme/Geri Yükleme
- [ ] Dil seçimi (Türkçe, İngilizce, Arapça)

### İleri Dönem:
- [ ] Bulut senkronizasyonu
- [ ] Özel tema oluşturma
- [ ] Widget özelleştirme
- [ ] Sesli ezan seçimi
- [ ] Bildirim tonları

---

## 📋 Kod Örnekleri

### Ayar Okuma:
```dart
final ayarlarService = AyarlarService();
final bildirimlerAktif = await ayarlarService.bildirimlerAktif;
final bildirimSuresi = await ayarlarService.bildirimSuresi;
```

### Ayar Yazma:
```dart
await ayarlarService.setBildirimlerAktif(true);
await ayarlarService.setBildirimSuresi(15);
```

### Tüm Ayarları Al:
```dart
final tumAyarlar = await ayarlarService.getAllSettings();
print(tumAyarlar);
// {
//   'bildirimlerAktif': true,
//   'sesliUyari': true,
//   'bildirimSuresi': 10,
//   ...
// }
```

---

## ✅ Kontrol Listesi

Ayarlar menüsü kurulumu:
- [x] Ayarlar ekranı oluşturuldu
- [x] Ayarlar servisi eklendi
- [x] Main drawer'a eklendi
- [x] SharedPreferences entegrasyonu
- [x] Bildirim ayarları
- [x] Görünüm ayarları
- [x] Konum ayarları
- [x] Hakkında bölümü
- [x] Veri yönetimi
- [x] Onay dialogları
- [x] Geri bildirim mesajları

---

## 🎉 Sonuç

**Ayarlar ve Kişiselleştirme Sistemi Hazır!**

### Özellikler:
- ✅ 8 farklı ayar kategorisi
- ✅ Kullanıcı dostu arayüz
- ✅ Yerel veri saklama
- ✅ Güvenli veri yönetimi
- ✅ Onay mekanizmaları

### Kullanıcı Faydaları:
- 🎨 Kişiselleştirme
- 🔔 Bildirim kontrolü
- 📱 Daha iyi deneyim
- ⚡ Performans optimizasyonu

---

**⚙️ Ayarlar menüsüne hoş geldiniz!**

**🎨 Uygulamanızı kendinize göre özelleştirin!**
