# Lisans Sözleşmesi Güncellemesi - Gerçek Satın Alma

**Güncelleme Tarihi:** 21 Kasım 2025

## Özet

Ezan Asistanı Pro uygulamasında gerçek satın alma (in-app purchase) özelliği eklenmesine bağlı olarak, lisans sözleşmesi ve gizlilik politikası güncellenmiştir.

## Güncellenen Dosyalar

### 1. `lib/screens/kullanim_kosullari.dart` (Kullanım Koşulları)

**Yapılan Değişiklikler:**

#### Bölüm 6: Sadaka/Bağış Sistemi - Gerçek Satın Alma
- **Eski:** Demo mod, gerçek para transferi yapılmaz
- **Yeni:** Gerçek parayla satın alma desteklemektedir
  - Mevcut satın alma seçenekleri: 2, 5, 10, 20, 50, 100 TL ve özel tutar
  - Google Play Store (Android) ve Apple App Store (iOS) aracılığıyla ödeme
  - Ödeme işlemleri bu platformların politikasına tabidir
  - "Kayıt Et" seçeneği ile ödeme yapmadan kayıt yapılabilir

#### Yeni Bölüm 7: Ödeme Koşulları
- Ödeme işlemleri anında gerçekleştirilir
- Ödeme başarılı olduktan sonra bağış tutarı uygulamada kaydedilir
- Ödeme iptal edilemez ve geri ödeme yapılamaz (platform politikasına göre)
- Geri ödeme talepleri Google Play Store veya Apple App Store aracılığıyla yapılmalıdır
- Tüm satın almalar ilgili platform tarafından faturalandırılır
- Vergi bilgileri ilgili platform tarafından yönetilir

#### Bölüm Numaralandırması
- Fikri Mülkiyet: 7 → 8
- Güncellemeler: 8 → 9
- Hesap Sonlandırma: 9 → 10
- Yasal Uyuşmazlıklar: 10 → 11

### 2. `lib/screens/gizlilik_politikasi.dart` (Gizlilik Politikası)

**Yapılan Değişiklikler:**

#### Yeni Bölüm 6: Satın Alma Verileri
- Satın alma işlemleri Google Play Store veya Apple App Store aracılığıyla yapılır
- Ödeme bilgileri bu platformlara iletilir (uygulama sunucularına değil)
- Satın alma tutarı ve tarihi cihazda yerel olarak kaydedilir
- Satın alma geçmişi Ayarlar > Tehlikeli Bölge > Tüm Verileri Sil ile silinebilir
- Geri ödeme talepleri ilgili platform aracılığıyla yapılmalıdır

#### Bölüm Numaralandırması
- Güncellemeler: 6 → 7
- İletişim: 7 → 8

## Yasal Uyum

### Türkiye Yasaları
- Tüm koşullar Türkiye Cumhuriyeti yasalarına tabidir
- Uyuşmazlıklar Türkiye mahkemelerinde çözülür

### Google Play Store
- Ödeme işlemleri Google Play Billing Library'ye uygun
- Geri ödeme politikası Google Play Store'un politikasına tabidir

### Apple App Store
- Ödeme işlemleri Apple In-App Purchase'a uygun
- Geri ödeme politikası Apple'ın politikasına tabidir

## Kullanıcı Hakları

### Ödeme Yapanlar
- Ödeme başarılı olduktan sonra bağış tutarı uygulamada kaydedilir
- Satın alma geçmişi görüntülenebilir
- Geri ödeme talepleri ilgili platform aracılığıyla yapılabilir

### Ödeme Yapmayan Kullanıcılar
- "Kayıt Et" seçeneği ile ödeme yapmadan bağış tutarını kaydedebilir
- Hiçbir ödeme yükümlülüğü yoktur
- Tamamen isteğe bağlıdır

## Veri Güvenliği

### Ödeme Bilgileri
- Ödeme bilgileri Google Play Store veya Apple App Store tarafından yönetilir
- Uygulama sunucularında saklanmaz
- Uygulama tarafından hiçbir ödeme bilgisi işlenmez

### Satın Alma Geçmişi
- Cihazda yerel olarak saklanır
- Üçüncü taraflarla paylaşılmaz
- Uygulamayı kaldırdığınızda silinir

## Uyum Kontrol Listesi

- ✅ Kullanım koşulları güncellenmiştir
- ✅ Gizlilik politikası güncellenmiştir
- ✅ Ödeme koşulları açıkça belirtilmiştir
- ✅ Veri gizliliği açıklanmıştır
- ✅ Geri ödeme politikası açıklanmıştır
- ✅ Platform politikaları referans gösterilmiştir

## Sonraki Adımlar

1. Google Play Console'da ürünleri oluşturun
2. Apple App Store Connect'te ürünleri oluşturun
3. Uygulamayı test edin
4. Uygulamayı yayınlayın

## İletişim

Lisans sözleşmesi ile ilgili sorularınız için:
- Email: xnxgamesdev@gmail.com
