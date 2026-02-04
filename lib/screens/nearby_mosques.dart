import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ezan_asistani/services/mosque_finder_service.dart';
import 'package:ezan_asistani/services/location_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/utils/logger.dart';
import 'package:ezan_asistani/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyMosques extends StatefulWidget {
  const NearbyMosques({Key? key}) : super(key: key);

  @override
  State<NearbyMosques> createState() => _NearbyMosquesState();
}

class _NearbyMosquesState extends State<NearbyMosques> {
  final MosqueFinderService _mosqueFinderService = MosqueFinderService();
  final LocationService _locationService = LocationService();

  List<Mosque> _mosques = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _userPosition;
  double _radiusKm = 5.0;

  bool _favoritesLoaded = false;
  final Map<String, Map<String, dynamic>> _favoriteMosquesByKey = {};
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadNearbyMosques();
  }

  String _mosqueKey(Mosque mosque) {
    return '${mosque.latitude.toStringAsFixed(5)}_${mosque.longitude.toStringAsFixed(5)}';
  }

  bool _isFavorite(Mosque mosque) {
    final key = _mosqueKey(mosque);
    return _favoriteMosquesByKey.containsKey(key);
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('favorite_mosques') ?? <String>[];

      final Map<String, Map<String, dynamic>> parsed = {};
      for (final item in list) {
        final parts = item.split('|');
        if (parts.length < 4) continue;
        final key = parts[0];
        final name = parts[1];
        final lat = double.tryParse(parts[2]);
        final lon = double.tryParse(parts[3]);
        if (lat == null || lon == null) continue;
        parsed[key] = {
          'name': name,
          'latitude': lat,
          'longitude': lon,
        };
      }

      if (!mounted) return;
      setState(() {
        _favoriteMosquesByKey
          ..clear()
          ..addAll(parsed);
        _favoritesLoaded = true;
      });
    } catch (e) {
      AppLogger.error('Favoriler yüklenemedi', error: e);
      if (!mounted) return;
      setState(() {
        _favoritesLoaded = true;
      });
    }
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favoriteMosquesByKey.entries.map((e) {
      final name = (e.value['name'] as String?) ?? AppLocalizations.of(context).translate('nearby_mosques_default_name');
      final lat = (e.value['latitude'] as num).toDouble();
      final lon = (e.value['longitude'] as num).toDouble();
      return '${e.key}|$name|$lat|$lon';
    }).toList();
    await prefs.setStringList('favorite_mosques', list);
  }

  Future<void> _toggleFavorite(Mosque mosque) async {
    final loc = AppLocalizations.of(context);
    final key = _mosqueKey(mosque);
    final wasFav = _favoriteMosquesByKey.containsKey(key);

    setState(() {
      if (wasFav) {
        _favoriteMosquesByKey.remove(key);
      } else {
        _favoriteMosquesByKey[key] = {
          'name': mosque.name,
          'latitude': mosque.latitude,
          'longitude': mosque.longitude,
        };
      }
    });

    try {
      await _persistFavorites();
    } catch (e) {
      AppLogger.error('Favori kaydetme hatası', error: e);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFav
              ? loc.translate('nearby_mosques_favorite_removed')
              : loc.translate('nearby_mosques_favorite_added'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _oneTapDirections(Mosque mosque) async {
    try {
      final googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}&travelmode=walking',
      );
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('Tek tık yol tarifi hatası', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate(
              'nearby_mosques_directions_open_failed',
              params: {'error': e.toString()},
            ),
          ),
        ),
      );
    }
  }

  Future<void> _loadNearbyMosques() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Kullanıcı konumunu al
      Position? position = await _locationService.getCurrentLocation();

      if (position == null) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).translate('nearby_mosques_location_unavailable');
          _isLoading = false;
        });
        return;
      }

      _userPosition = position;

      // Yakındaki camileri bul
      List<Mosque> mosques = await _mosqueFinderService.findNearbyMosques(
        position.latitude,
        position.longitude,
        radiusKm: _radiusKm,
      );

      AppLogger.info('Overpass sonucu: ${mosques.length} cami');

      // Eğer sonuç yoksa Nominatim ile dene
      if (mosques.isEmpty) {
        AppLogger.info('Overpass sonucu boş, Nominatim deneniyor');
        mosques = await _mosqueFinderService.findMosquesByNominatim(
          position.latitude,
          position.longitude,
          radiusKm: _radiusKm,
        );
        AppLogger.info('Nominatim sonucu: ${mosques.length} cami');
      }

      setState(() {
        _mosques = mosques;
        _isLoading = false;
        if (mosques.isEmpty) {
          _errorMessage = AppLocalizations.of(context).translate(
            'nearby_mosques_none_found',
            params: {
              'radius': _radiusKm.toStringAsFixed(1),
            },
          );
        }
      });
    } catch (e) {
      AppLogger.error('Cami yükleme hatası', error: e);
      setState(() {
        _errorMessage = AppLocalizations.of(context).translate(
          'nearby_mosques_error_generic',
          params: {'error': e.toString()},
        );
        _isLoading = false;
      });
    }
  }

  // Harita seçeneğini göster
  void _showMapOptions(Mosque mosque) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate('nearby_mosques_map_options_title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMapOption(
              icon: Icons.map,
              title: AppLocalizations.of(context).translate('nearby_mosques_map_google_title'),
              subtitle: AppLocalizations.of(context).translate('nearby_mosques_map_google_subtitle'),
              onTap: () {
                Navigator.pop(context);
                _launchGoogleMaps(mosque);
              },
            ),
            _buildMapOption(
              icon: Icons.location_on,
              title: AppLocalizations.of(context).translate('nearby_mosques_map_yandex_title'),
              subtitle: AppLocalizations.of(context).translate('nearby_mosques_map_yandex_subtitle'),
              onTap: () {
                Navigator.pop(context);
                _launchYandexMaps(mosque);
              },
            ),
            _buildMapOption(
              icon: Icons.map_outlined,
              title: AppLocalizations.of(context).translate('nearby_mosques_map_mapsme_title'),
              subtitle: AppLocalizations.of(context).translate('nearby_mosques_map_mapsme_subtitle'),
              onTap: () {
                Navigator.pop(context);
                _launchMapsMeApp(mosque);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Harita seçeneği widget'ı
  Widget _buildMapOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryYellow),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Google Maps'i aç
  Future<void> _launchGoogleMaps(Mosque mosque) async {
    try {
      // Android 11+ package visibility yüzünden canLaunchUrl false dönebiliyor.
      // Bu yüzden direkt launchUrl dene, hata alırsak fallback'e geç.
      final encodedName = Uri.encodeComponent(mosque.name);

      final geoUri = Uri.parse(
        'geo:${mosque.latitude},${mosque.longitude}?q=${mosque.latitude},${mosque.longitude}($encodedName)',
      );

      final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}',
      );

      AppLogger.info('Google Maps açılıyor (geo): $geoUri');
      try {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        AppLogger.success('Harita uygulaması (geo) açıldı');
        return;
      } catch (_) {
        // geo handler yoksa web'e düş.
      }

      AppLogger.info('Google Maps açılıyor (web): $webUri');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      AppLogger.success('Google Maps web açıldı');
    } catch (e) {
      AppLogger.error('Google Maps açma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate(
              'nearby_mosques_google_open_failed',
              params: {'error': e.toString()},
            ),
          ),
        ),
      );
    }
  }

  // Yandex Haritalar'ı aç
  Future<void> _launchYandexMaps(Mosque mosque) async {
    // Yandex Maps URL format (türkçe karakterleri encode et)
    final encodedName = Uri.encodeComponent(mosque.name);
    final String yandexUrl =
        'https://yandex.com/maps/?text=$encodedName&pt=${mosque.longitude},${mosque.latitude}&z=16&l=map';
    
    try {
      AppLogger.info('Yandex Haritalar açılıyor: $yandexUrl');
      await launchUrl(Uri.parse(yandexUrl), mode: LaunchMode.externalApplication);
      AppLogger.success('Yandex Haritalar açıldı');
    } catch (e) {
      AppLogger.error('Yandex Haritalar açma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate(
              'nearby_mosques_yandex_open_failed',
              params: {'error': e.toString()},
            ),
          ),
        ),
      );
    }
  }

  // Maps.me uygulamasını aç
  Future<void> _launchMapsMeApp(Mosque mosque) async {
    // Maps.me URL format (türkçe karakterleri encode et)
    final encodedName = Uri.encodeComponent(mosque.name);
    final String mapsmeUrl =
        'https://maps.me/map?v=1&q=$encodedName&ll=${mosque.latitude},${mosque.longitude}&z=16';
    
    try {
      AppLogger.info('Maps.me açılıyor: $mapsmeUrl');
      await launchUrl(Uri.parse(mapsmeUrl), mode: LaunchMode.externalApplication);
      AppLogger.success('Maps.me açıldı');
    } catch (e) {
      AppLogger.error('Maps.me açma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate(
              'nearby_mosques_mapsme_open_failed',
              params: {'error': e.toString()},
            ),
          ),
        ),
      );
    }
  }

  // Eski _launchMaps fonksiyonu - backward compatibility
  Future<void> _launchMaps(Mosque mosque) async {
    _showMapOptions(mosque);
  }

  Future<void> _launchPhone(String phone) async {
    final String phoneUrl = 'tel:$phone';
    
    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('nearby_mosques_phone_app_failed'),
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Telefon açma hatası', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nearby_mosques_appbar_title')),
        backgroundColor: AppTheme.primaryYellow,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _showOnlyFavorites
                ? loc.translate('nearby_mosques_all_mosques')
                : loc.translate('nearby_mosques_favorites'),
            icon: Icon(_showOnlyFavorites ? Icons.format_list_bulleted : Icons.star),
            onPressed: _favoritesLoaded
                ? () {
                    setState(() {
                      _showOnlyFavorites = !_showOnlyFavorites;
                    });
                  }
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildMosquesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNearbyMosques,
        backgroundColor: AppTheme.primaryYellow,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: AppTheme.primaryYellow.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? loc.translate('nearby_mosques_generic_error'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNearbyMosques,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
              ),
              child: Text(loc.translate('nearby_mosques_retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosquesList() {
    final loc = AppLocalizations.of(context);
    final favoritesInResults = _mosques.where(_isFavorite).toList();
    final displayMosques = _showOnlyFavorites
        ? favoritesInResults
        : _mosques;

    return Column(
      children: [
        if (_favoriteMosquesByKey.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.star, size: 18, color: AppTheme.primaryYellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showOnlyFavorites
                        ? loc.translate('nearby_mosques_favorite_mosques')
                        : loc.translate(
                            'nearby_mosques_favorites_with_count',
                            params: {
                              'count': _favoriteMosquesByKey.length.toString(),
                            },
                          ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showOnlyFavorites = !_showOnlyFavorites;
                    });
                  },
                  child: Text(
                    _showOnlyFavorites
                        ? loc.translate('nearby_mosques_all')
                        : loc.translate('nearby_mosques_only_favorites'),
                  ),
                ),
              ],
            ),
          ),
        // Radius seçici
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('nearby_mosques_search_distance'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_radiusKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _radiusKm,
                min: 1.0,
                max: 25.0,
                divisions: 24,
                activeColor: AppTheme.primaryYellow,
                onChanged: (value) {
                  setState(() {
                    _radiusKm = value;
                  });
                },
                onChangeEnd: (_) {
                  _loadNearbyMosques();
                },
              ),
            ],
          ),
        ),
        // Cami sayısı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            loc.translate(
              'nearby_mosques_found_count',
              params: {
                'count': displayMosques.length.toString(),
              },
            ),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Cami listesi
        Expanded(
          child: ListView.builder(
            itemCount: displayMosques.length,
            itemBuilder: (context, index) {
              final mosque = displayMosques[index];
              return _buildMosqueCard(mosque);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMosqueCard(Mosque mosque) {
    final loc = AppLocalizations.of(context);
    final isFav = _isFavorite(mosque);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.primaryYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mosque.distance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFav
                      ? loc.translate('nearby_mosques_remove_favorite_tooltip')
                      : loc.translate('nearby_mosques_add_favorite_tooltip'),
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: AppTheme.primaryYellow,
                  ),
                  onPressed: () => _toggleFavorite(mosque),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${mosque.distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Adres
            if (mosque.address != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.home,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mosque.address!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Telefon
            if (mosque.phone != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _launchPhone(mosque.phone!),
                        child: Text(
                          mosque.phone!,
                          style: const TextStyle(
                            color: AppTheme.primaryYellow,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Koordinatlar
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.map,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${mosque.latitude.toStringAsFixed(4)}, ${mosque.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _oneTapDirections(mosque),
                    icon: const Icon(Icons.directions_walk),
                    label: Text(loc.translate('nearby_mosques_one_tap_directions')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchMaps(mosque),
                    icon: const Icon(Icons.map),
                    label: Text(loc.translate('nearby_mosques_choose_map')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryYellow,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final coords = '${mosque.latitude},${mosque.longitude}';
                  try {
                    await Clipboard.setData(ClipboardData(text: coords));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.translate(
                              'nearby_mosques_coords_copied',
                              params: {'coords': coords},
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    AppLogger.success('Koordinatlar kopyalandı: $coords');
                  } catch (e) {
                    AppLogger.error('Koordinat kopyalama hatası: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.translate(
                              'nearby_mosques_copy_failed',
                              params: {'error': e.toString()},
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(loc.translate('nearby_mosques_copy_coords')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
