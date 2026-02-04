import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:intl/intl.dart';

class Zekatmatik extends StatefulWidget {
  const Zekatmatik({Key? key}) : super(key: key);

  @override
  _ZekatmatikState createState() => _ZekatmatikState();
}

class _ZekatmatikState extends State<Zekatmatik> {
  final _formKey = GlobalKey<FormState>();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  double _goldPrice = 2000.0; // Default gold price (user can change)
  double _goldAmount = 0.0;
  double _cash = 0.0;
  double _debt = 0.0;
  double _otherAssets = 0.0;
  
  double _nisap = 0.0;
  double _zekatAmount = 0.0;
  bool _isNisapReached = false;

  static const double _nisapGoldGrams = 80.18; // 80.18 grams of gold
  static const double _zekatRate = 2.5; // 2.5%

  void _calculateZakat() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Calculate total assets
      final totalGoldValue = _goldAmount * _goldPrice;
      final totalAssets = totalGoldValue + _cash + _otherAssets - _debt;
      
      // Calculate nisap (threshold)
      _nisap = _goldPrice * _nisapGoldGrams;
      
      setState(() {
        _isNisapReached = totalAssets >= _nisap;
        _zekatAmount = _isNisapReached ? (totalAssets * _zekatRate) / 100 : 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zekat Hesaplama'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGoldPriceField(),
              const SizedBox(height: 16),
              _buildGoldAmountField(),
              const SizedBox(height: 16),
              _buildCashField(),
              const SizedBox(height: 16),
              _buildOtherAssetsField(),
              const SizedBox(height: 16),
              _buildDebtField(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateZakat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Zekat Hesapla',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoldPriceField() {
    return TextFormField(
      initialValue: _goldPrice.toStringAsFixed(2),
      decoration: const InputDecoration(
        labelText: 'Altın Gram Fiyatı (₺)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.monetization_on),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _goldPrice = double.tryParse(value) ?? 0.0;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir değer giriniz';
        }
        final val = double.tryParse(value);
        if (val == null || val <= 0) {
          return 'Geçerli bir değer giriniz';
        }
        return null;
      },
    );
  }

  Widget _buildGoldAmountField() {
    return TextFormField(
      initialValue: _goldAmount.toStringAsFixed(2),
      decoration: const InputDecoration(
        labelText: 'Toplam Altın Miktarı (Gram)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.monetization_on),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _goldAmount = double.tryParse(value) ?? 0.0;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          _goldAmount = 0.0;
          return null;
        }
        final val = double.tryParse(value);
        if (val == null || val < 0) {
          return 'Geçerli bir değer giriniz';
        }
        return null;
      },
    );
  }

  Widget _buildCashField() {
    return TextFormField(
      initialValue: _cash.toStringAsFixed(2),
      decoration: const InputDecoration(
        labelText: 'Nakit Para (₺)', 
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _cash = double.tryParse(value) ?? 0.0;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          _cash = 0.0;
          return null;
        }
        final val = double.tryParse(value);
        if (val == null || val < 0) {
          return 'Geçerli bir değer giriniz';
        }
        return null;
      },
    );
  }

  Widget _buildOtherAssetsField() {
    return TextFormField(
      initialValue: _otherAssets.toStringAsFixed(2),
      decoration: const InputDecoration(
        labelText: 'Diğer Varlıklar (₺)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _otherAssets = double.tryParse(value) ?? 0.0;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          _otherAssets = 0.0;
          return null;
        }
        final val = double.tryParse(value);
        if (val == null || val < 0) {
          return 'Geçerli bir değer giriniz';
        }
        return null;
      },
    );
  }

  Widget _buildDebtField() {
    return TextFormField(
      initialValue: _debt.toStringAsFixed(2),
      decoration: const InputDecoration(
        labelText: 'Toplam Borç (₺)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.money_off),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _debt = double.tryParse(value) ?? 0.0;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          _debt = 0.0;
          return null;
        }
        final val = double.tryParse(value);
        if (val == null || val < 0) {
          return 'Geçerli bir değer giriniz';
        }
        return null;
      },
    );
  }

  Widget _buildResults() {
    final totalGoldValue = _goldAmount * _goldPrice;
    final totalAssets = totalGoldValue + _cash + _otherAssets - _debt;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zekat Sonuçları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            _buildResultRow('Toplam Altın Değeri:', _currencyFormat.format(totalGoldValue)),
            _buildResultRow('Toplam Varlıklar:', _currencyFormat.format(totalAssets)),
            _buildResultRow('Nisap Miktarı (${_nisapGoldGrams}g altın):', _currencyFormat.format(_nisap)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isNisapReached ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isNisapReached ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isNisapReached
                        ? '✓ Nisap miktarına ulaşıldı (Zekat vermek farzdır)'
                        : 'ℹ️ Nisap miktarına ulaşılmadı',
                    style: TextStyle(
                      color: _isNisapReached ? Colors.green.shade800 : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isNisapReached) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Zekat Miktarı (${_zekatRate}%):',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_zekatAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Not: Bu hesaplama bilgilendirme amaçlıdır. Detaylı bilgi için bir din görevlisine danışınız.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
