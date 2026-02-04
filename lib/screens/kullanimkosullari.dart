import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class KullanimKosullari extends StatelessWidget {
  const KullanimKosullari({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kullanım Koşulları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Son Güncelleme: Aralık 2025',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Kabul Etme',
              'Bu uygulamayı kullanarak, bu Kullanım Koşullarını kabul edersiniz. '
                  'Koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayın.',
            ),
            _buildSection(
              'Lisans',
              'Ezan Asistanı size kişisel, ticari olmayan kullanım için sınırlı bir lisans verir. '
                  'Uygulamayı değiştiremez, kopyalayamaz, dağıtamaz veya tersine mühendislik yapamassınız.',
            ),
            _buildSection(
              'Doğruluk',
              'Ezan saatleri en iyi bilgilere göre hesaplanır, ancak bazı faktörlere bağlı olarak '
                  'değişebilir. Namazı kımışmadan önce lütfen diğer kaynakları da kontrol edin.',
            ),
            _buildSection(
              'Sorumluluk Reddi',
              'Uygulama \"olduğu gibi\" sağlanır. Ticari başarısızlık veya herhangi bir '
                  'kullanımdan kaynaklanan zararlardan sorumlu değiliz.',
            ),
            _buildSection(
              'Fikri Mülkiyet',
              'Uygulamadaki tüm içerik, tasarım ve işlevsellik fikri mülkiyetimizdir. '
                  'İzin almadan kopya veya kullanım yasaktır.',
            ),
            _buildSection(
              'Değişiklikler',
              'Bu koşulları herhangi bir zamanda değiştirebiliriz. Düzenli olarak kontrol etmenizi '
                  'öneririz. Değişiklik sonrası uygulamayı kullanmaya devam etmek, yeni koşulları '
                  'kabul etmek anlamına gelir.',
            ),
            _buildSection(
              'Yasal Uygunluk',
              'Bu uygulama yalnızca eğitim ve kişisel namaz takibi amaçlarıyla tasarlanmıştır. '
                  'Dini kaynaklar olarak kullanmak istiyorsanız, lütfen yerel din görevlilerine danışın.',
            ),
            _buildSection(
              'İletişim',
              'Bu koşullar hakkında sorularınız varsa:\n'
                  'Email: legal@ezanasistani.com',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryYellow,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
