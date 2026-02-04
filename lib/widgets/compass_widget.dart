import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class CompassWidget extends StatelessWidget {
  final double direction;
  final double qiblaDirection;

  const CompassWidget({
    Key? key,
    required this.direction,
    required this.qiblaDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kıble yönüne göre pusula açısını hesapla
    double angle = (qiblaDirection - direction) * (math.pi / 180);

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pusula çemberi
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryYellow,
                width: 4,
              ),
            ),
          ),
          // Yön işaretleri
          ...List.generate(4, (index) {
            final labels = ['K', 'D', 'G', 'B']; // Kuzey, Doğu, Güney, Batı
            final rotationAngle = index * math.pi / 2;
            return Transform.rotate(
              angle: rotationAngle - direction * (math.pi / 180),
              child: Transform.translate(
                offset: const Offset(0, -110),
                child: Transform.rotate(
                  angle: -(rotationAngle - direction * (math.pi / 180)),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: index == 0
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Kıble oku
          Transform.rotate(
            angle: angle,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.navigation,
                  size: 80,
                  color: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'KIBLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Merkez nokta
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkYellow,
            ),
          ),
        ],
      ),
    );
  }
}
