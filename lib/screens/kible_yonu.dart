import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:ezan_asistani/services/location_service.dart';
import 'package:ezan_asistani/widgets/compass_widget.dart';
import 'package:ezan_asistani/widgets/admob_banner.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class KibleYonu extends StatefulWidget {
  const KibleYonu({super.key});

  @override
  State<KibleYonu> createState() => _KibleYonuState();
}

class _KibleYonuState extends State<KibleYonu> {
  final LocationService _locationService = LocationService();

  double? _currentDirection;
  double? _qiblaDirection;
  Position? _currentPosition;
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool isLoading = true;
  String? errorMessage;

  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    if (!mounted) return;

    if (_initializing) return;
    _initializing = true;

    // Eğer önceki subscription varsa, yenisini başlatmadan iptal et
    await _compassSubscription?.cancel();
    _compassSubscription = null;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Konum iznini kontrol et
      bool hasPermission = await _locationService.checkAndRequestPermission();
      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Konum izni gerekli. Lütfen ayarlardan izin verin.';
          isLoading = false;
        });
        return;
      }

      // Konumu al
      Position? position = await _locationService.getCurrentLocation();

      if (position != null) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
          _qiblaDirection = _locationService.calculateQiblaDirection(
            position.latitude,
            position.longitude,
          );
          isLoading = false;
        });

        // Pusula akışını dinle
        final stream = FlutterCompass.events;
        if (stream == null) {
          if (!mounted) return;
          setState(() {
            errorMessage =
                'Pusula sensörü bulunamadı. Lütfen telefonu düz zeminde kalibre edin veya sensör desteğini kontrol edin.';
            isLoading = false;
          });
          return;
        }

        _compassSubscription = stream.listen((CompassEvent event) {
          if (!mounted) return;

          final heading = event.heading;
          if (heading == null) {
            setState(() {
              errorMessage =
                  'Pusula verisi alınamadı. Telefonu 8 çizerek kalibre edin ve mıknatıslı kılıf/metalden uzak tutun.';
            });
            return;
          }

          // Normalize: 0..360
          var normalized = heading % 360;
          if (normalized < 0) normalized += 360;

          setState(() {
            _currentDirection = normalized;
            errorMessage = null;
          });
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Konum alınamadı. Lütfen konum izni verin.';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Pusula başlatılamadı: $e';
        isLoading = false;
      });
    } finally {
      _initializing = false;
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  String _getDirectionText() {
    if (_currentDirection == null || _qiblaDirection == null) {
      return 'Hesaplanıyor...';
    }

    double diff = (_qiblaDirection! - _currentDirection!).abs();
    if (diff > 180) {
      diff = 360 - diff;
    }

    if (diff < 5) {
      return 'Kıbleye yöneldiniz! 🕋';
    } else if (diff < 15) {
      return 'Çok yakınsınız';
    } else if (diff < 45) {
      return 'Yaklaşıyorsunuz';
    } else {
      return 'Telefonunuzu çevirin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainScaffold = Scaffold.maybeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Yönü'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            mainScaffold?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeCompass,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryYellow.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryYellow.withOpacity(0.2),
                            ),
                            child: const CircularProgressIndicator(
                              color: AppTheme.primaryYellow,
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Kıble yönü hesaplanıyor...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Konum ve pusula verisi alınıyor',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _initializeCompass,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // Durum metni
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryYellow,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  _getDirectionText(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Pusula widget'ı
                              if (_currentDirection != null &&
                                  _qiblaDirection != null)
                                CompassWidget(
                                  direction: _currentDirection!,
                                  qiblaDirection: _qiblaDirection!,
                                ),
                              const SizedBox(height: 40),
                              // Konum bilgisi
                              if (_currentPosition != null)
                                Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: AppTheme.primaryYellow,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Konumunuz',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Enlem: ${_currentPosition!.latitude.toStringAsFixed(4)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          'Boylam: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Kıble Açısı: ${_qiblaDirection!.toStringAsFixed(1)}°',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.darkYellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              // Bilgilendirme
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Telefonunuzu düz tutun ve yavaşça çevirin. '
                                  'Sarı ok Kıble yönünü gösterir.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ),
          const AdMobBanner(),
        ],
      ),
    );
  }
}
