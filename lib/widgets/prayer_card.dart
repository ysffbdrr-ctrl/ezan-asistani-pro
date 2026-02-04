import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/l10n/app_localizations.dart';

class PrayerCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final IconData icon;
  final bool isNext;
  final VoidCallback? onTap;

  const PrayerCard({
    Key? key,
    required this.prayerName,
    required this.prayerTime,
    required this.icon,
    this.isNext = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cardColor = isNext
        ? AppTheme.primaryYellow
        : Theme.of(context).cardTheme.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: isNext
            ? LinearGradient(
                colors: [
                  AppTheme.primaryYellow,
                  AppTheme.darkYellow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isNext ? null : cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isNext
                ? AppTheme.primaryYellow.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: isNext ? 12 : 6,
            offset: Offset(0, isNext ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.white.withOpacity(0.25)
                        : AppTheme.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isNext ? Colors.white : AppTheme.primaryYellow)
                            .withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isNext ? Colors.white : AppTheme.darkYellow,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isNext
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            loc.translate('prayer_card_next_badge'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.white.withOpacity(0.2)
                        : AppTheme.primaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prayerTime,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isNext
                          ? Colors.white
                          : AppTheme.primaryYellow,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
