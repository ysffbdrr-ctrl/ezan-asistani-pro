import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class KullanimKosullari extends StatelessWidget {
  const KullanimKosullari({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.description,
              title: 'Kullanım Koşulları',
              content: 'Ezan Asistanı Pro uygulamasını kullanarak aşağıdaki koşulları kabul etmiş olursunuz.',
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              icon: Icons.check_circle_outline,
              title: '1. Kabul ve Onay',
              content: '• Bu uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.\n'
                  '• Koşulları kabul etmiyorsanız uygulamayı kullanmayınız.\n'
                  '• Koşullar zaman zaman güncellenebilir.',
            ),
            
            _buildSection(
              icon: Icons.mosque,
              title: '2. Uygulama Amacı',
              content: '• Ezan Asistanı Pro, Müslümanlar için dini yardımcı bir uygulamadır.\n'
                  '• Namaz vakitlerini gösterir ve hatırlatır.\n'
                  '• İslami bilgiler ve eğitim içerikleri sunar.\n'
                  '• Kıble yönünü gösterir ve dua koleksiyonları içerir.',
            ),
            
            _buildSection(
              icon: Icons.warning_amber,
              title: '3. Sorumluluk Reddi',
              content: '• Namaz vakitleri tahmini olup, yerel müftülük saatlerine göre değişiklik gösterebilir.\n'
                  '• Kıble yönü cihazınızın pusula özelliğine bağlıdır ve yanılabilir.\n'
                  '• Dini bilgiler genel bilgilendirme amaçlıdır, şüpheli durumlarda alim görüşüne başvurunuz.\n'
                  '• Uygulama "olduğu gibi" sunulmaktadır.',
            ),
            
            _buildSection(
              icon: Icons.access_time,
              title: '4. Namaz Vakitleri',
              content: '• Vakitler Diyanet İşleri Başkanlığı metoduyla hesaplanır.\n'
                  '• İnternet bağlantısı gerektirir.\n'
                  '• Konum servisleri aktif olmalıdır (GPS veya manuel şehir seçimi).\n'
                  '• Yerel müftülük saatlerini kontrol etmeniz önerilir.',
            ),
            
            _buildSection(
              icon: Icons.verified_user,
              title: '5. Kullanıcı Sorumlulukları',
              content: '• Uygulamayı yasalara uygun şekilde kullanmalısınız.\n'
                  '• Uygulamayı tersine mühendislik veya kötüye kullanmamalısınız.\n'
                  '• Uygulamanın içeriğini izinsiz kopyalamamalısınız.',
            ),
            
            _buildSection(
              icon: Icons.attach_money,
              title: '6. Sadaka/Bağış Sistemi - Gerçek Satın Alma',
              content: '• Sadaka/Yardım özelliği gerçek parayla satın alma desteklemektedir.\n'
                  '• Mevcut satın alma seçenekleri: 2, 5, 10, 20, 50, 100 TL ve özel tutar.\n'
                  '• Tüm ödemeler Google Play Store (Android) veya Apple App Store (iOS) aracılığıyla yapılır.\n'
                  '• Ödeme işlemleri bu platformların ödeme politikasına tabidir.\n'
                  '• Bağışlar gönüllülük esasına dayalıdır ve tamamen isteğe bağlıdır.\n'
                  '• "Kayıt Et" seçeneği ile ödeme yapmadan bağış tutarını kaydedebilirsiniz.',
            ),
            
            _buildSection(
              icon: Icons.payment,
              title: '7. Ödeme Koşulları',
              content: '• Ödeme işlemleri anında gerçekleştirilir.\n'
                  '• Ödeme başarılı olduktan sonra bağış tutarı uygulamada kaydedilir.\n'
                  '• Ödeme iptal edilemez ve geri ödeme yapılamaz (platform politikasına göre).\n'
                  '• Geri ödeme talepleri Google Play Store veya Apple App Store aracılığıyla yapılmalıdır.\n'
                  '• Tüm satın almalar ilgili platform tarafından faturalandırılır.\n'
                  '• Vergi bilgileri ilgili platform tarafından yönetilir.',
            ),
            
            _buildSection(
              icon: Icons.volunteer_activism,
              title: '8. Bağışların Kullanımı ve Akışı',
              content: '• Bağış tutarı Google Play Store veya Apple App Store aracılığıyla alınır.\n'
                  '• Platform komisyonu (Google %30, Apple %30) kesilir.\n'
                  '• Kalan tutar Ezan Asistanı Pro geliştirme ve bakım için kullanılır.\n'
                  '• Bağışlar aşağıdaki amaçlar için kullanılabilir:\n'
                  '  - Uygulama geliştirme ve yeni özellikler\n'
                  '  - Sunucu ve altyapı maliyetleri\n'
                  '  - Teknik destek ve bakım\n'
                  '  - İslami içerik güncellemeleri\n'
                  '  - Uygulama güvenliği ve iyileştirmeleri\n'
                  '• Bağışlar tamamen gönüllülük esasına dayalıdır.\n'
                  '• Bağış tutarı hiçbir şekilde gerçek hayatta sadaka/zekât olarak kullanılmaz.\n'
                  '• Gerçek sadaka ve zekât için lütfen resmi hayır kurumlarına başvurunuz.',
            ),
            
            _buildSection(
              icon: Icons.copyright,
              title: '9. Fikri Mülkiyet',
              content: '• Uygulama içeriği telif hakkı ile korunmaktadır.\n'
                  '• İslami metinler ve dualar kaynaklarından alınmıştır.\n'
                  '• Uygulama tasarımı ve kodu Ezan Asistanı Pro ekibine aittir.',
            ),
            
            _buildSection(
              icon: Icons.update,
              title: '10. Güncellemeler',
              content: '• Uygulama düzenli olarak güncellenebilir.\n'
                  '• Güncellemeler yeni özellikler ve hata düzeltmeleri içerebilir.\n'
                  '• Kullanıcılar uygulamayı güncel tutmalıdır.',
            ),
            
            _buildSection(
              icon: Icons.cancel,
              title: '11. Hesap Sonlandırma',
              content: '• Uygulamayı istediğiniz zaman silebilirsiniz.\n'
                  '• Tüm verileriniz cihazınızdan silinecektir.\n'
                  '• Sunucularımızda veri saklanmadığı için geri getirilemez.',
            ),
            
            _buildSection(
              icon: Icons.gavel,
              title: '12. Yasal Uyuşmazlıklar',
              content: '• Bu koşullar Türkiye Cumhuriyeti yasalarına tabidir.\n'
                  '• Uyuşmazlıklar Türkiye mahkemelerinde çözülür.',
            ),
            
            _buildSection(
              icon: Icons.cloud_sync,
              title: '13. Google Sign-In ve Bulut Senkronizasyonu',
              content: '• Google Sign-In opsiyoneldir ve zorunlu değildir.\n'
                  '• Misafir olarak uygulamayı tam işlevselliği ile kullanabilirsiniz.\n'
                  '• Google ile giriş yaparsanız verileriniz Cloud Firestore\'da saklanır.\n'
                  '• Bulut senkronizasyonu sayesinde verileriniz birden fazla cihazda senkronize olur.\n'
                  '• Google hesabınızı sildiğinizde tüm bulut verileri silinir.\n'
                  '• Gizlilik Politikası bölümünde veri işleme hakkında detaylı bilgi bulunmaktadır.',
            ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryYellow),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: AppTheme.primaryYellow),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Önemli Hatırlatma',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Namaz vakitleri ve dini bilgiler için şüpheli durumlarda '
                    'yerel müftülük veya din görevlilerine danışmanız önerilir.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Son Güncelleme: 22 Kasım 2025 (Google Sign-In Opsiyonel)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryYellow, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
