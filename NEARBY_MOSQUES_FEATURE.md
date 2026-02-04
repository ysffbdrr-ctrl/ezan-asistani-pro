# Eve Yakın Camiler Özelliği

## Özet
Bu özellik, kullanıcının mevcut konumuna yakın camileri bulmak ve göstermek için tasarlanmıştır.

## Eklenen Dosyalar

### 1. `lib/services/mosque_finder_service.dart`
- **Amaç**: Yakındaki camileri bulmak için API çağrıları yapar
- **Sınıflar**:
  - `Mosque`: Cami bilgilerini temsil eden model
  - `MosqueFinderService`: Cami arama işlevselliğini sağlayan servis
- **Metodlar**:
  - `findNearbyMosques()`: Overpass API kullanarak camileri bulur
  - `findMosquesByNominatim()`: Nominatim API kullanarak alternatif arama yapar
- **Özellikler**:
  - Mesafeye göre otomatik sıralama
  - Harita koordinatları hesaplama
  - Cami adı, adresi, telefon numarası gibi bilgileri içerir

### 2. `lib/screens/nearby_mosques.dart`
- **Amaç**: Yakındaki camileri görüntülemek için UI sağlar
- **Özellikler**:
  - Konum tabanlı cami arama
  - Arama mesafesi slider'ı (1-25 km)
  - Cami kartları (ad, mesafe, adres, telefon)
  - Harita uygulamasında açma
  - Telefon numarasını ara
  - Koordinatları kopyala
  - Yenileme butonu

### 3. Güncellemeler
- **pubspec.yaml**: `url_launcher: ^6.2.0` bağımlılığı eklendi
- **lib/main.dart**: 
  - `nearby_mosques.dart` import'u eklendi
  - Menüye "Eve Yakın Camiler" öğesi eklendi

## Kullanılan API'ler

### 1. Overpass API
- **URL**: `https://overpass-api.de/api/interpreter`
- **Amaç**: OpenStreetMap verilerinden camileri sorgulamak
- **Sorgu**: İslami ibadethaneler ve camiler için etiketler

### 2. Nominatim API (Yedek)
- **URL**: `https://nominatim.openstreetmap.org`
- **Amaç**: Cami adlarını aramak (Overpass başarısız olursa)

### 3. Google Maps
- **Amaç**: Cami konumunu haritada göstermek

## Gerekli İzinler

Uygulamanın aşağıdaki izinlere ihtiyacı vardır:
- **Konum İzni**: Kullanıcının mevcut konumunu almak için
- **İnternet İzni**: API çağrıları yapmak için

## Özellikler

### Temel Özellikler
- ✅ Kullanıcı konumuna yakın camileri bul
- ✅ Camileri mesafeye göre sırala
- ✅ Cami bilgilerini (ad, adres, telefon) göster
- ✅ Arama mesafesini ayarlanabilir yap (1-25 km)

### Etkileşim Özellikleri
- ✅ Haritada aç (Google Maps)
- ✅ Telefon numarasını ara
- ✅ Koordinatları kopyala
- ✅ Yenileme butonu
- ✅ Hata yönetimi ve kullanıcı geri bildirimi

## Test Adımları

1. **Uygulamayı Çalıştır**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Menüyü Aç**
   - Sol taraftaki drawer'ı aç
   - "Eve Yakın Camiler" öğesine tıkla

3. **Konum İzni Ver**
   - Konum izni istediğinde "İzin Ver" seçeneğini seç

4. **Camileri Gözlemle**
   - Yakındaki camilerin listesi gösterilecek
   - Her cami için mesafe, adres, telefon bilgileri görülecek

5. **Mesafe Slider'ını Ayarla**
   - Slider'ı hareket ettir
   - Arama mesafesini 1-25 km arasında değiştir
   - Sonuçlar otomatik olarak güncellenecek

6. **Haritada Aç**
   - "Haritada Aç" butonuna tıkla
   - Google Maps uygulaması açılacak

7. **Telefon Numarasını Ara**
   - Telefon numarasına tıkla
   - Telefon uygulaması açılacak

## Hata Yönetimi

- Konum alınamadığında: Kullanıcıya bildirim gösterilir
- API başarısız olduğunda: Alternatif API denenir
- Sonuç bulunamadığında: Mesaj gösterilir

## Performans Notları

- Overpass API sorgusu ~5-15 saniye sürebilir
- Nominatim API daha hızlıdır ancak daha az ayrıntılı
- Sonuçlar mesafeye göre otomatik sıralanır

## Gelecek İyileştirmeler

- Camilerin açılış/kapanış saatleri gösterme
- Cami türü filtreleme (Cuma Camii, Mescit vb.)
- Favorilere ekleme
- Rota planlama
- Cami yorumları ve puanları
