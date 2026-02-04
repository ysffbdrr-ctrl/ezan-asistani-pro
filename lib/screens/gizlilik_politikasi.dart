import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class GizlilikPolitikasi extends StatelessWidget {
  const GizlilikPolitikasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.shield,
              title: 'Gizlilik Politikası',
              content: 'Ezan Asistanı Pro uygulaması olarak gizliliğinize önem veriyoruz. '
                  'Bu politika, uygulamayı kullanırken toplanan bilgilerin nasıl '
                  'kullanıldığını açıklar.',
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              icon: Icons.info_outline,
              title: '1. Toplanan Bilgiler',
              content: '• Konum Bilgisi: Namaz vakitlerini hesaplamak için GPS konumunuz kullanılır.\n'
                  '• Kullanım İstatistikleri: Namaz takibi, puan ve rozetler gibi veriler cihazınızda saklanır.\n'
                  '• Ayarlar: Bildirim tercihleri ve diğer ayarlar yerel olarak saklanır.',
            ),
            
            _buildSection(
              icon: Icons.security,
              title: '2. Verilerin Saklanması',
              content: '• Tüm verileriniz cihazınızda yerel olarak saklanır.\n'
                  '• Hiçbir kişisel veri sunucularımıza gönderilmez.\n'
                  '• Verileriniz üçüncü taraflarla paylaşılmaz.\n'
                  '• İnternet bağlantısı sadece ezan vakitlerini almak için kullanılır.',
            ),
            
            _buildSection(
              icon: Icons.location_on,
              title: '3. Konum İzni',
              content: '• Konum bilgisi sadece ezan vakitlerini hesaplamak için kullanılır.\n'
                  '• Konum verileriniz saklanmaz veya paylaşılmaz.\n'
                  '• Konum iznini istediğiniz zaman ayarlardan kapatabilirsiniz.\n'
                  '• Manuel şehir seçimi ile GPS kullanmadan devam edebilirsiniz.',
            ),
            
            _buildSection(
              icon: Icons.notifications,
              title: '4. Bildirimler',
              content: '• Bildirimler sadece namaz vakitlerini hatırlatmak için gönderilir.\n'
                  '• Reklam veya pazarlama bildirimi gönderilmez.\n'
                  '• Bildirimleri istediğiniz zaman ayarlardan kapatabilirsiniz.',
            ),
            
            _buildSection(
              icon: Icons.delete,
              title: '5. Verilerin Silinmesi',
              content: '• Tüm verilerinizi Ayarlar > Tehlikeli Bölge > Tüm Verileri Sil seçeneği ile silebilirsiniz.\n'
                  '• Uygulamayı kaldırdığınızda tüm veriler silinir.\n'
                  '• Hiçbir veri bulutta saklanmadığı için geri getirilemez.',
            ),
            
            _buildSection(
              icon: Icons.payment,
              title: '6. Satın Alma Verileri',
              content: '• Satın alma işlemleri Google Play Store veya Apple App Store aracılığıyla yapılır.\n'
                  '• Ödeme bilgileriniz bu platformlara iletilir (uygulama sunucularına değil).\n'
                  '• Satın alma tutarı ve tarihi cihazınızda yerel olarak kaydedilir.\n'
                  '• Satın alma geçmişi Ayarlar > Tehlikeli Bölge > Tüm Verileri Sil ile silinebilir.\n'
                  '• Geri ödeme talepleri ilgili platform aracılığıyla yapılmalıdır.',
            ),
            
            _buildSection(
              icon: Icons.update,
              title: '7. Güncellemeler',
              content: 'Bu gizlilik politikası zaman zaman güncellenebilir. '
                  'Önemli değişiklikler olduğunda uygulama içinde bilgilendirileceksiniz.',
            ),
            
            _buildSection(
              icon: Icons.cloud_sync,
              title: '8. Google Sign-In ve Bulut Senkronizasyonu',
              content: '• Google Sign-In tamamen opsiyoneldir.\n'
                  '• Giriş yapmazsanız tüm verileriniz cihazınızda yerel olarak saklanır.\n'
                  '• Google ile giriş yaparsanız:\n'
                  '  - E-posta adresiniz ve profil bilgileriniz Firestore\'da saklanır\n'
                  '  - Puan, rozet ve leaderboard verileri buluta yedeklenir\n'
                  '  - Verileriniz Google\'ın veri işleme politikasına tabidir\n'
                  '• Bulut verileri sadece sizin hesabınız tarafından erişilebilir\n'
                  '• Google hesabınızı sildiğinizde tüm bulut verileri silinir\n'
                  '• Bulut senkronizasyonu sayesinde verileriniz birden fazla cihazda senkronize olur',
            ),
            
            _buildSection(
              icon: Icons.email,
              title: '9. İletişim',
              content: 'Gizlilik politikası ile ilgili sorularınız için:\n'
                  'Email: xnxgamesdev@gmail.com',
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
                      Icon(Icons.check_circle, color: AppTheme.primaryYellow),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Verileriniz güvende!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Misafir olarak: Tüm veriler cihazınızda saklanır\n'
                    '• Google ile giriş yaparsanız: Veriler buluta yedeklenir ve şifreli saklanır',
                    style: TextStyle(
                      fontSize: 12,
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
