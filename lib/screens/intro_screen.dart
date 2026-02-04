import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class IntroPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final bool isLastPage;

  IntroPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    this.isLastPage = false,
  });
}

class IntroScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const IntroScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      icon: Icons.mosque,
      title: 'Ezan Asistanı Pro',
      subtitle: 'İslami Yaşamınız İçin Eksiksiz Çözüm',
      description:
          'Ezan vakitleri, Quran, hadisler ve daha birçok İslami bilgiye erişin.',
      color: AppTheme.primaryYellow,
    ),
    IntroPage(
      icon: Icons.schedule,
      title: 'Namaz Vakitleri',
      subtitle: 'Her Zaman Hazır Ol',
      description:
          'Konum bazlı namaz vakitleri bildirimleri alın. Asla bir namazı kaçırmayın.',
      color: Colors.blue,
    ),
    IntroPage(
      icon: Icons.book,
      title: 'Quran & Hadis',
      subtitle: 'İslami Bilgileri Keşfet',
      description:
          'Gün içinde hadisler öğrenin ve Quran ayetlerini okuyun. Her gün yeni bilgiler.',
      color: Colors.green,
    ),
    IntroPage(
      icon: Icons.trending_up,
      title: 'Gamifikasyon',
      subtitle: 'Başarılarını Takip Et',
      description:
          'Rozet kazan, puan topla ve liderlik tablosunda sıralınızı yükseltin.',
      color: Colors.purple,
    ),
    IntroPage(
      icon: Icons.location_on,
      title: 'Komşu Camiileri',
      subtitle: 'Yakındaki Mescidleri Bul',
      description: 'Haritada yakın camileri bulun ve daha fazla bilgi edinin.',
      color: Colors.orange,
    ),
    IntroPage(
      icon: Icons.favorite,
      title: 'Başlayalım',
      subtitle: 'İslami Yolculuğuna Hoş Geldin',
      description:
          'Şimdi uygulamayı keşfet ve tüm özellikleri kullan. Dualarla başarılar dileriz.',
      color: AppTheme.primaryYellow,
      isLastPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markIntroComplete() async {
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildIntroPage(_pages[index], context);
            },
          ),

          // Bottom Navigation
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[index].color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Önceki'),
                        )
                      else
                        const SizedBox(width: 80),
                      if (_currentPage < _pages.length - 1)
                        ElevatedButton.icon(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Sonraki'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _markIntroComplete,
                          icon: const Icon(Icons.check),
                          label: const Text('Başla'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Skip Button
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: _markIntroComplete,
                    child: Text(
                      'Atla',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroPage(IntroPage page, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            page.color.withValues(alpha: 0.1),
            page.color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 96,
                  color: page.color,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                page.subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: page.color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                page.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
