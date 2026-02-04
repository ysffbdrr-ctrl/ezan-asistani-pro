import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ezan_asistani/services/location_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class ArKibleYonu extends StatefulWidget {
  const ArKibleYonu({super.key});

  @override
  State<ArKibleYonu> createState() => _ArKibleYonuState();
}

class _ArKibleYonuState extends State<ArKibleYonu> {
  final LocationService _locationService = LocationService();

  late CameraController _cameraController;
  Position? _currentPosition;
  double? _qiblaDirection;
  double? _currentDirection;
  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _isInitialized = false;
  String? _errorMessage;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAR();
  }

  Future<void> _initializeAR() async {
    try {
      // Konum iznini kontrol et
      bool hasPermission = await _locationService.checkAndRequestPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Konum izni gerekli. Lütfen ayarlardan izin verin.';
        });
        return;
      }

      // Kamera iznini kontrol et
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Cihazda kamera bulunamadı.';
        });
        return;
      }

      // Arka kamerayı seç
      final rearCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.initialize();

      // Konumu al
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _qiblaDirection = _locationService.calculateQiblaDirection(
            position.latitude,
            position.longitude,
          );
        });

        // Pusula akışını dinle
        _compassSubscription =
            FlutterCompass.events?.listen((CompassEvent event) {
          setState(() {
            _currentDirection = event.heading;
          });
        });

        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isCameraInitialized = true;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Konum alınamadı. Lütfen konum izni verin.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kamera başlatılamadı: $e';
      });
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AR Kıble Bulucu'),
          backgroundColor: AppTheme.primaryYellow,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isInitialized = false;
                      _errorMessage = null;
                    });
                    _initializeAR();
                  },
                  child: const Text('Yeniden Dene'),
                ),
              ] else ...[
                const CircularProgressIndicator(
                  color: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 16),
                const Text('AR Kıble Bulucu başlatılıyor...'),
              ]
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Kıble Bulucu'),
        backgroundColor: AppTheme.primaryYellow,
      ),
      body: Stack(
        children: [
          // Kamera Feed
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            Container(color: Colors.black),

          // AR Overlay
          if (_currentDirection != null && _qiblaDirection != null)
            _buildAROverlay(),

          // Üst Bilgi Paneli
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTopInfoPanel(),
          ),

          // Alt Bilgi Paneli
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomInfoPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildAROverlay() {
    if (_currentDirection == null || _qiblaDirection == null) {
      return const SizedBox.shrink();
    }

    final angleDifference = (_qiblaDirection! - _currentDirection!).abs();
    final normalizedAngle =
        angleDifference > 180 ? 360 - angleDifference : angleDifference;
    final isAligned = normalizedAngle < 10;

    // Kıble göstergesinin konumunu hesapla
    final angleRadian = (_qiblaDirection! - _currentDirection!) * pi / 180;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;
    const radius = 100.0;

    final arrowX = centerX + radius * sin(angleRadian);
    final arrowY = centerY - radius * cos(angleRadian);

    return Stack(
      children: [
        // Merkez daire
        Positioned(
          left: centerX - 40,
          top: centerY - 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
        ),

        // Kıble yöne gösteren ok
        Positioned(
          left: arrowX - 20,
          top: arrowY - 20,
          child: Transform.rotate(
            angle: angleRadian,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAligned ? Colors.green : Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: isAligned ? Colors.green : Colors.orange,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Merkez göstergesi
        Positioned(
          left: centerX - 8,
          top: centerY - 8,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ),

        // Durum göstergesi (merkez üstü)
        Positioned(
          left: centerX - 60,
          top: centerY - 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAligned ? Colors.green : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAligned ? '✓ KIBLE' : 'KIBLE',
                  style: TextStyle(
                    color: isAligned ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${normalizedAngle.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: isAligned ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // İçerde büyük daire
        Positioned(
          left: centerX - 60,
          top: centerY - 60,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.yellow.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
        ),

        // Dış büyük daire
        Positioned(
          left: centerX - 100,
          top: centerY - 100,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.yellow.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopInfoPanel() {
    if (_currentDirection == null || _qiblaDirection == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mevcut Yön',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${_currentDirection!.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Kıble Yönü',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${_qiblaDirection!.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoPanel() {
    if (_currentPosition == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konum Bilgisi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Enlem',
            '${_currentPosition!.latitude.toStringAsFixed(4)}',
          ),
          _buildInfoRow(
            'Boylam',
            '${_currentPosition!.longitude.toStringAsFixed(4)}',
          ),
          _buildInfoRow(
            'Yükseklik',
            '${_currentPosition!.altitude.toStringAsFixed(1)} m',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryYellow),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryYellow),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Sarı ok kıble yönünü gösterir. Telefonunuzu çevirerek hizalayın.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
