import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class Takvim extends StatefulWidget {
  const Takvim({Key? key}) : super(key: key);

  @override
  State<Takvim> createState() => _TakvimState();
}

class _TakvimState extends State<Takvim> {
  late DateTime selectedDate;
  late HijriCalendar hijriDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    hijriDate = HijriCalendar.fromDate(selectedDate);
  }

  void _updateDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      hijriDate = HijriCalendar.fromDate(newDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryYellow,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      _updateDate(picked);
    }
  }

  String _getHijriMonthName(int month) {
    const months = [
      'Muharrem',
      'Safer',
      'Rebiülevvel',
      'Rebiülahir',
      'Cemaziyelevvel',
      'Cemaziyelahir',
      'Recep',
      'Şaban',
      'Ramazan',
      'Şevval',
      'Zilkade',
      'Zilhicce',
    ];
    return months[month - 1];
  }

  String _getTurkishDayName(int weekday) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[weekday - 1];
  }

  String _getTurkishMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final mainScaffold = Scaffold.maybeOf(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            mainScaffold?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _updateDate(DateTime.now()),
            tooltip: 'Bugüne Dön',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Miladi Takvim Kartı
              Card(
                elevation: 6,
                color: AppTheme.primaryYellow,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Miladi Takvim',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTurkishDayName(selectedDate.weekday),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${selectedDate.day}',
                            style: const TextStyle(
                              fontSize: 64,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTurkishMonthName(selectedDate.month),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Hicri Takvim Kartı
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mosque,
                        size: 48,
                        color: AppTheme.darkYellow,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hicri Takvim',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hijriDate.getDayName(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${hijriDate.hDay}',
                            style: const TextStyle(
                              fontSize: 64,
                              color: AppTheme.darkYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getHijriMonthName(hijriDate.hMonth),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${hijriDate.hYear}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tarih seçme butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text(
                    'Tarih Seç',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Önemli günler bilgisi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryYellow,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Önemli Günler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildImportantDay('Ramazan Ayı', 'Ramazan', 1),
                      _buildImportantDay('Ramazan Bayramı', 'Şevval', 1),
                      _buildImportantDay('Kurban Bayramı', 'Zilhicce', 10),
                      _buildImportantDay('Hicri Yılbaşı', 'Muharrem', 1),
                      _buildImportantDay('Mevlid Kandili', 'Rebiülevvel', 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportantDay(String name, String month, int day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '$day $month',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
