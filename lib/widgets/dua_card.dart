import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class DuaCard extends StatelessWidget {
  final String title;
  final String arabicText;
  final String turkishText;
  final VoidCallback? onTap;

  const DuaCard({
    Key? key,
    required this.title,
    required this.arabicText,
    required this.turkishText,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppTheme.darkYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                arabicText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                turkishText,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
