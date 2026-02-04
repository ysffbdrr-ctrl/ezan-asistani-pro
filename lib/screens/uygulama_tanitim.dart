import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UygulamaTanitim extends StatefulWidget {
  final VoidCallback onCompleted;

  const UygulamaTanitim({
    Key? key,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<UygulamaTanitim> createState() => _UygulamaTanitimState();
}

class _UygulamaTanitimState extends State<UygulamaTanitim> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.mosque,
      title: 'Ezan Asistanı Pro',
      description: 'Hoş geldiniz! Ezan Asistanı Pro ile dini hayatınızı kolaylaştırın. '
          'Namaz vakitlerini takip edin, Kur\'an okuyun ve daha fazlası...',
      color: AppTheme.primaryYellow,
    ),
    OnboardingPage(
      icon: Icons.access_time,
      title: 'Namaz Vakitleri',
      description: 'Bulunduğunuz konuma göre doğru namaz vakitlerini öğrenin. '
          'İstediğiniz vakitte bildirim alın ve hiçbir namazı kaçırmayın.',
      color: Colors.blue,
    ),
    OnboardingPage(
      icon: Icons.explore,
      title: 'Kıble Yönü',
      description: 'Dünyanın her yerinden Kıble yönünü kolayca bulun. '
          'Dijital pusula ile doğru yönü belirleyin.',
      color: Colors.green,
    ),
    OnboardingPage(
      icon: Icons.menu_book,
      title: 'Kur\'an-ı Kerim',
      description: 'Kur\'an-ı Kerim\'i okuyun, sureler arasında gezinin. '
          'Meal ve tefsir bilgilerine ulaşın.',
      color: Colors.purple,
    ),
    OnboardingPage(
      icon: Icons.check_circle,
      title: 'Namaz Takip',
      description: 'Kıldığınız namazları takip edin, istatistiklerinizi görün. '
          'Puan kazanın ve rozetler toplayın.',
      color: Colors.orange,
    ),
    OnboardingPage(
      icon: Icons.school,
      title: 'İslami Eğitim',
      description: 'Günlük dualar, İslam quiz, bilgi kartları ve daha fazlası. '
          'Dini bilginizi artırın ve öğrenmeye devam edin.',
      color: Colors.teal,
    ),
    OnboardingPage(
      icon: Icons.celebration,
      title: 'Hazırsınız!',
      description: 'Artık Ezan Asistanı Pro\'nun tüm özelliklerinden yararlanabilirsiniz. '
          'Hadi başlayalım!',
      color: AppTheme.primaryYellow,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tanitim_gosterildi', true);
    widget.onCompleted();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _skip() {
    _completeTutorial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip butonu
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Atla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 60),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
            ),

            // Next/Start butonu
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage < _pages.length - 1
                            ? 'Devam'
                            : 'Başlayalım',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage < _pages.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryYellow : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
