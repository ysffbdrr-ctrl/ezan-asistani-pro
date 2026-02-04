# Bağış Akışı ve Para Yönetimi

## Paranın Akışı

```
Kullanıcı
   ↓
   Bağış Tutar Seçer (2, 5, 10, 20, 50, 100 TL veya Özel)
   ↓
   "Ödeme Yap" Butonuna Tıklar
   ↓
   Google Play Store / Apple App Store
   ↓
   Ödeme İşlemi Gerçekleştirilir
   ↓
   Platform Komisyonu Kesilir (%30)
   ↓
   Kalan Tutar → Ezan Asistanı Pro Geliştirme Hesabına
   ↓
   Bağış Tutarı Uygulamada Kaydedilir
```

## Detaylı Açıklama

### 1. Kullanıcı Bağış Yapar

Kullanıcı sadaka/bağış bölümünde aşağıdaki seçeneklerden birini seçer:
- **Hızlı Bağış**: 2, 5, 10, 20, 50, 100 TL
- **Özel Tutar**: Kullanıcı tarafından belirlenen tutar
- **Kayıt Et**: Ödeme yapmadan sadece kayıt (opsiyonel)

### 2. Ödeme Platformu

Tüm ödemeler resmi platformlar aracılığıyla yapılır:

**Android:**
- Google Play Billing Library
- Google Play Store hesabı
- Google tarafından işlenir

**iOS:**
- Apple In-App Purchase
- Apple ID hesabı
- Apple tarafından işlenir

### 3. Platform Komisyonu

Her ödemenin %30'u platform tarafından alınır:

**Örnek:**
```
Kullanıcı Bağışı: 100 TL
Platform Komisyonu: 30 TL (Google veya Apple)
Ezan Asistanı Pro Alacağı: 70 TL
```

### 4. Bağış Tutarının Kullanımı

Kalan tutar (platform komisyonu kesilmiş) aşağıdaki amaçlar için kullanılır:

#### A. Uygulama Geliştirme
- Yeni özellikler
- Hata düzeltmeleri
- Performans iyileştirmeleri
- UI/UX geliştirmeleri

#### B. Sunucu ve Altyapı
- Sunucu maliyetleri
- Veri tabanı hizmetleri
- CDN ve dağıtım ağları
- Güvenlik sertifikaları

#### C. Teknik Destek
- Geliştirici ücretleri
- Teknik destek personeli
- Hata raporlama ve çözüm
- Kullanıcı desteği

#### D. İslami İçerik
- Namaz vakitleri veritabanı güncellemeleri
- Dua ve Kuran içeriği
- Dini bilgiler doğruluğu kontrolü
- Çeviriler ve lokalizasyon

#### E. Güvenlik ve Gizlilik
- Güvenlik denetimi
- Veri koruma
- Gizlilik politikası uyumu
- Sertifikasyon ve lisanslar

### 5. Bağış Kaydı

Ödeme başarılı olduktan sonra:
- Bağış tutarı uygulamada kaydedilir
- Satın alma geçmişine eklenir
- Gamification puanları (+5 puan) kazanılır
- Kullanıcıya teşekkür mesajı gösterilir

## Önemli Notlar

### ⚠️ Bu Bağış Sadaka DEĞİLDİR

```
❌ Bu bağış İslami anlamda sadaka/zekât DEĞİLDİR
❌ Bu bağış hayır kurumlarına gitmez
❌ Bu bağış dini yükümlülüğü yerine getirmez

✅ Bu bağış uygulama geliştirme için kullanılır
✅ Bu bağış tamamen gönüllülüktür
✅ Bu bağış isteğe bağlıdır
```

### Gerçek Sadaka ve Zekât

Eğer gerçek sadaka ve zekât vermek istiyorsanız, lütfen aşağıdaki resmi kurumlardan birine başvurunuz:

- **Kızılay**: https://www.kizilay.org.tr
- **Diyanet Vakfı**: https://www.diyanet.gov.tr
- **Gıda Bankası**: https://www.gidabankasi.org.tr
- **Çocuk Esirgeme Kurumu**: https://www.cecek.org.tr
- **Eğitim Gönüllüleri Vakfı**: https://www.tegv.org
- **Hayvan Hakları Federasyonu**: https://www.hayvanhaklari.net

## Şeffaflık

Ezan Asistanı Pro, bağış tutarlarının nasıl kullanıldığı hakkında şeffaf olmaya çalışır:

- Bağış tutarları uygulamada kaydedilir
- Satın alma geçmişi görüntülenebilir
- Tüm koşullar kullanım şartlarında belirtilmiştir
- Gizlilik politikası açıkça tanımlanmıştır

## Geri Ödeme

Geri ödeme talepleri:
- Google Play Store veya Apple App Store aracılığıyla yapılmalıdır
- Uygulama tarafından doğrudan geri ödeme yapılamaz
- Platform politikasına göre işlenir
- Genellikle 30 gün içinde tamamlanır

## İletişim

Bağış ve ödeme ile ilgili sorularınız için:
- Email: xnxgamesdev@gmail.com
- Lütfen detaylı açıklama ile iletişime geçiniz

## Vergi Bilgileri

- Tüm satın almalar ilgili platform tarafından faturalandırılır
- Vergi bilgileri platform tarafından yönetilir
- Fatura ve makbuzlar platform hesabınızdan görüntülenebilir
- Vergi danışmanınıza danışmanız önerilir
