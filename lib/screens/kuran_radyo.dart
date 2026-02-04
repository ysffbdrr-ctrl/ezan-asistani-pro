import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/widgets/admob_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KuranRadyo extends StatefulWidget {
  const KuranRadyo({Key? key}) : super(key: key);

  @override
  State<KuranRadyo> createState() => _KuranRadyoState();
}

class _KuranRadyoState extends State<KuranRadyo> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.7;
  String _currentStationName = '';
  String _currentStationDescription = '';
  int _selectedStationIndex = -1;
  Set<int> _favoriteStations = {};
  Timer? _timer;
  Timer? _videoFallbackTimer;
  Duration _listenedDuration = Duration.zero;
  WebViewController? _webViewController;
  VideoPlayerController? _videoController;
  bool _isNativeVideoReady = false;
  bool _isVideoInitializing = false;
  bool _forceAudioForCurrent = false;
  
  // Radyo istasyonları
  final List<Map<String, String>> _stations = [
    {
      'name': 'Kur\'an Radyo - Türkiye',
      'description': '24/7 Kur\'an-ı Kerim',
      'url': 'https://stream.tvhizmetleri.org/kuran',
      'country': 'Türkiye',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Kur\'an Radyo - Türkçe Meal',
      'description': 'Kur\'an anlamlarının Türkçe tercümesi',
      'url': 'https://backup.qurango.net/radio/translation_quran_turkish',
      'country': 'Türkiye',
      'language': 'Türkçe',
      'type': 'audio',
    },
    {
      'name': 'Mekke Canlı (Ses)',
      'description': 'Mescid-i Haram\'dan Canlı Yayın',
      'url': 'http://stream.radiojar.com/4wqre23fytzuv',
      'country': 'Suudi Arabistan',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Medine Canlı (Ses)',
      'description': 'Mescid-i Nebevi\'den Canlı Yayın',
      'url': 'http://stream.radiojar.com/amdq86n3bnzuv',
      'country': 'Suudi Arabistan',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Kur\'an Radyo - Kahire',
      'description': 'Mısır Kur\'an Radyosu',
      'url': 'http://stream.radiojar.com/8s5u5tpdtwzuv',
      'country': 'Mısır',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Abdulbasit Abdussamed',
      'description': 'Meşhur Kari\'nin Tilavetleri',
      'url': 'http://quraan.us:9996/',
      'country': 'Mısır',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Sheikh Mishary Rashid',
      'description': 'Mishary Rashid Alafasy Tilavetleri',
      'url': 'http://server8.mp3quran.net:8808/',
      'country': 'Kuveyt',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Kur\'an Radyo - İngilizce',
      'description': 'İngilizce Meal ile Kur\'an',
      'url': 'http://66.45.232.131:9994/',
      'country': 'ABD',
      'language': 'İngilizce',
      'type': 'audio',
    },
    {
      'name': 'Kur\'an Radyo - Malayca',
      'description': 'Malezya Kur\'an Radyosu',
      'url': 'http://radio.Garden/api/ara/content/listen/7bR0bR0b/channel.mp3',
      'country': 'Malezya',
      'language': 'Malayca',
      'type': 'audio',
    },
    {
      'name': 'Maher Al Muaiqly',
      'description': 'Sheikh Maher Tilavetleri',
      'url': 'http://server8.mp3quran.net:8004/',
      'country': 'Suudi Arabistan',
      'language': 'Arapça',
      'type': 'audio',
    },
    {
      'name': 'Kur\'an Radyo - Diyanet',
      'description': 'Diyanet İşleri Başkanlığı',
      'url': 'https://radyo.diyanet.gov.tr/kuranradyo',
      'country': 'Türkiye',
      'language': 'Arapça/Türkçe',
      'type': 'audio',
    },
    {
      'name': 'Mekke Canlı (Video)',
      'description': 'Mescid-i Haram - Canlı görüntü & ses',
      'url': 'https://cdnamd-hls-globecast.akamaized.net/live/ramdisk/saudi_quran/saudi_quran.m3u8',
      'country': 'Suudi Arabistan',
      'language': 'Arapça',
      'type': 'video',
      'video_embed_url': 'https://www.youtube.com/embed/live_stream?channel=UCos52azQNBgW63_9uDJoPDA&autoplay=1&playsinline=1&rel=0&enablejsapi=1',
      'fallback_audio_url': 'http://stream.radiojar.com/4wqre23fytzuv',
    },
    {
      'name': 'Medine Canlı (Video)',
      'description': 'Mescid-i Nebevi - Canlı görüntü & ses',
      'url': 'https://cdnamd-hls-globecast.akamaized.net/live/ramdisk/saudi_sunnah/saudi_sunnah.m3u8',
      'country': 'Suudi Arabistan',
      'language': 'Arapça',
      'type': 'video',
      'video_embed_url': 'https://www.youtube.com/embed/4HtT0YafY9s?autoplay=1&playsinline=1&rel=0&enablejsapi=1',
      'fallback_audio_url': 'http://stream.radiojar.com/amdq86n3bnzuv',
    },
  ];

  static const String _youtubeUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36';

  bool get _hasSelection =>
      _selectedStationIndex >= 0 && _selectedStationIndex < _stations.length;

  Map<String, String>? get _currentStation =>
      _hasSelection ? _stations[_selectedStationIndex] : null;

  bool get _isCurrentStationVideo => _hasSelection &&
      !_forceAudioForCurrent &&
      ((_stations[_selectedStationIndex]['type'] ?? 'audio') == 'video');

  void _startListeningTimer() {
    _stopListeningTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _listenedDuration =
            _listenedDuration + const Duration(seconds: 1);
      });
    });
  }

  void _stopListeningTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _stopVideoFallbackTimer() {
    _videoFallbackTimer?.cancel();
    _videoFallbackTimer = null;
  }

  void _startVideoFallbackTimer(Map<String, String> station) {
    _stopVideoFallbackTimer();
    _videoFallbackTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (_forceAudioForCurrent) return;
      if (!_isCurrentStationVideo) return;

      // Video hâlâ hazır/oynuyor görünmüyorsa ses yayınına geç.
      if (_isVideoInitializing || _isLoading || !_isPlaying) {
        unawaited(
          _fallbackToAudio(
            station,
            message:
                '${station['name']} video yayını bu cihazda açılamadı (oynatıcı yapılandırma hatası olabilir). Ses yayınına geçildi.',
          ),
        );
      }
    });
  }

  void _disposeWebView() {
    if (_webViewController != null) {
      unawaited(_sendYoutubeCommand('stopVideo'));
    }
    _webViewController = null;
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    _isNativeVideoReady = false;
    if (controller != null) {
      try {
        await controller.pause();
      } catch (_) {}
      await controller.dispose();
    }
  }

  Future<void> _setVolume(double value) async {
    setState(() {
      _volume = value;
    });

    if (_isCurrentStationVideo) {
      final controller = _videoController;
      if (controller != null) {
        try {
          await controller.setVolume(value);
        } catch (_) {}
      }
      return;
    }

    await _audioPlayer.setVolume(value);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAudio();
    _loadFavorites();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListeningTimer();
    _stopVideoFallbackTimer();
    _disposeWebView();
    unawaited(_disposeVideo());
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Uygulama arka plana alındığında çalmaya devam et
    } else if (state == AppLifecycleState.resumed) {
      // Uygulama öne geldiğinde UI'ı güncelle
      setState(() {});
    }
  }

  Future<void> _initializeAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _audioPlayer.playerStateStream.listen((playerState) {
      if (_isCurrentStationVideo) {
        return;
      }

      final isLoading = playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering;
      final isPlaying = playerState.playing &&
          playerState.processingState != ProcessingState.completed;

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = isLoading;
        _isPlaying = isPlaying;
      });

      if (isPlaying) {
        _startListeningTimer();
      } else {
        _stopListeningTimer();
      }
    });

    await _audioPlayer.setVolume(_volume);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_stations') ?? [];
    setState(() {
      _favoriteStations = favorites.map((e) => int.parse(e)).toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_stations',
      _favoriteStations.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _playStation(int index) async {
    final station = _stations[index];

    _disposeWebView();
    _stopVideoFallbackTimer();
    await _disposeVideo();
    await _audioPlayer.stop();
    _stopListeningTimer();

    final isVideo = station['type'] == 'video';

    setState(() {
      _isLoading = true;
      _selectedStationIndex = index;
      _currentStationName = station['name'] ?? '';
      _currentStationDescription = station['description'] ?? '';
      _listenedDuration = Duration.zero;
      _isVideoInitializing = isVideo;
      _isPlaying = false;
      _forceAudioForCurrent = false;
    });

    try {
      if (isVideo) {
        final url = station['url'];
        if (url == null || url.isEmpty) {
          throw Exception('Video stream url tanımlı değil');
        }

        final videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        _videoController = videoController;

        videoController.addListener(() {
          if (!mounted) return;
          final value = videoController.value;
          if (value.hasError) {
            unawaited(_fallbackToAudio(
              station,
              message:
                  '${station['name']} videosu bu cihazda oynatılamadı. Ses yayınına geçildi.',
            ));
          }
        });

        await videoController.initialize().timeout(const Duration(seconds: 10));
        await videoController.setLooping(true);
        await videoController.play();

        if (!mounted) return;
        setState(() {
          _isNativeVideoReady = true;
          _isLoading = false;
          _isVideoInitializing = false;
          _isPlaying = true;
        });

        _startListeningTimer();
        unawaited(_saveListeningStats());

        // Eğer video başlamazsa fallback.
        _startVideoFallbackTimer(station);
        return;
      }

      await _audioPlayer.setUrl(station['url']!);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });

      _startListeningTimer();
      await _saveListeningStats();
    } on TimeoutException {
      await _audioPlayer.stop();
      _disposeWebView();
      await _disposeVideo();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isVideoInitializing = false;
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yayın zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stack) {
      await _audioPlayer.stop();
      _disposeWebView();
      await _disposeVideo();

      debugPrint('Video/Radyo bağlantı hatası: $e');
      debugPrintStack(stackTrace: stack);

      if (isVideo) {
        await _fallbackToAudio(
          station,
          message:
              '${station['name']} video yayınına ulaşılamadı. Ses yayınına geçildi.\nDetay: ${e.runtimeType}',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isVideoInitializing = false;
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağlantı hatası: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Yeniden Dene',
            onPressed: () => _playStation(_selectedStationIndex),
          ),
        ),
      );
    }
  }

  Future<void> _sendYoutubeCommand(String command) async {
    final controller = _webViewController;
    if (controller == null) return;

    try {
      await controller.runJavaScript(
        "window.postMessage(JSON.stringify({event:'command',func:'$command',args:[]}), '*');",
      );
    } catch (error) {
      debugPrint('YouTube command ($command) failed: $error');
    }
  }

  String _buildYoutubeEmbedHtml(String embedUrl) {
    final html = '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      html, body {
        margin: 0;
        padding: 0;
        background-color: #000;
        overflow: hidden;
      }
      iframe {
        position: absolute;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        border: 0;
      }
    </style>
    <script>
      function notifyFlutter(message) {
        if (window.FlutterBridge && window.FlutterBridge.postMessage) {
          FlutterBridge.postMessage(message);
        }
      }

      window.addEventListener('load', function() {
        notifyFlutter('playerReady');
      });
    </script>
  </head>
  <body>
    <iframe
      id="playerFrame"
      src="$embedUrl"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen>
    </iframe>
  </body>
</html>
''';

    return html;
  }

  void _handleYoutubeBridgeMessage(String message, Map<String, String> station) {
    if (!mounted || _forceAudioForCurrent) {
      return;
    }

    if (message == 'playerReady') {
      _stopVideoFallbackTimer();
      setState(() {
        _isLoading = false;
        _isVideoInitializing = false;
        _isPlaying = true;
      });
      _startListeningTimer();
      unawaited(_saveListeningStats());
      return;
    }

    if (message.startsWith('playerState:')) {
      final stateCode = int.tryParse(message.split(':').last) ?? -1;
      switch (stateCode) {
        case 0: // ended
          unawaited(_sendYoutubeCommand('playVideo'));
          break;
        case 1: // playing
          if (!mounted) return;
          setState(() {
            _isPlaying = true;
          });
          _startListeningTimer();
          break;
        case 2: // paused
          if (!mounted) return;
          setState(() {
            _isPlaying = false;
          });
          _stopListeningTimer();
          break;
        default:
          break;
      }
      return;
    }

    if (message.startsWith('playerError:')) {
      final errorCode = message.split(':').last;
      debugPrint('YouTube player error code: $errorCode');

      final fatalCodes = {'150', '151', '152', '153'};
      if (fatalCodes.contains(errorCode)) {
        unawaited(_fallbackToAudio(
          station,
          message:
              '${station['name']} videosu bu uygulamada oynatılamıyor (hata $errorCode). Ses yayınına geçildi.',
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'YouTube oynatıcı hata verdi (kod: $errorCode). Tekrar denemek için videoyu durdurup başlatabilirsiniz.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _fallbackToAudio(
    Map<String, String> station, {
    required String message,
  }) async {
    final fallbackUrl = station['fallback_audio_url'];

    if (fallbackUrl == null || fallbackUrl.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isVideoInitializing = false;
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video yayını açılamadı ve ses yedeği bulunamadı.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      _stopListeningTimer();
      _disposeWebView();
      await _disposeVideo();

      await _audioPlayer.setUrl(fallbackUrl);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play();

      if (!mounted) return;
      setState(() {
        _forceAudioForCurrent = true;
        _isLoading = false;
        _isVideoInitializing = false;
        _isPlaying = true;
      });

      _startListeningTimer();
      await _saveListeningStats();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (error, stack) {
      debugPrint('Video fallback audio hatası: $error');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isVideoInitializing = false;
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ses yedeği de başlatılamadı. Lütfen tekrar deneyin.\n${error.runtimeType}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveListeningStats() async {
    final prefs = await SharedPreferences.getInstance();
    final totalMinutes = prefs.getInt('kuran_radyo_dakika') ?? 0;
    await prefs.setInt('kuran_radyo_dakika', totalMinutes + 1);
  }

  Future<void> _togglePlay() async {
    if (!_hasSelection) {
      await _playStation(0);
      return;
    }

    if (_isCurrentStationVideo) {
      final videoController = _videoController;
      if (videoController != null) {
        if (videoController.value.isPlaying) {
          await videoController.pause();
          _stopListeningTimer();
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        } else {
          await videoController.play();
          _startListeningTimer();
          if (mounted) {
            setState(() {
              _isPlaying = true;
            });
          }
        }
        return;
      }

      if (_webViewController == null) {
        await _playStation(_selectedStationIndex);
        return;
      }

      if (_isPlaying) {
        await _sendYoutubeCommand('pauseVideo');
        _stopListeningTimer();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } else {
        await _sendYoutubeCommand('playVideo');
        _startListeningTimer();
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      }
      return;
    }

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      _stopListeningTimer();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      await _audioPlayer.play();
      _startListeningTimer();
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteStations.contains(index)) {
        _favoriteStations.remove(index);
      } else {
        _favoriteStations.add(index);
      }
    });
    _saveFavorites();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Widget _buildNowPlaying() {
    if (!_hasSelection) {
      return const SizedBox.shrink();
    }

    final station = _currentStation!;
    final isVideo = _isCurrentStationVideo;
    final webController = _webViewController;
    final videoController = _videoController;

    final decoration = isVideo
        ? BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          )
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryYellow,
                AppTheme.primaryYellow.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryYellow.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isVideo && !_forceAudioForCurrent)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: Colors.black),
                    if (_isVideoInitializing)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    else if (videoController != null && _isNativeVideoReady)
                      AspectRatio(
                        aspectRatio: videoController.value.aspectRatio == 0
                            ? (16 / 9)
                            : videoController.value.aspectRatio,
                        child: VideoPlayer(videoController),
                      )
                    else if (webController != null)
                      WebViewWidget(controller: webController)
                    else
                      Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    if (!_isPlaying)
                      const IgnorePointer(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white70,
                          size: 72,
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isPlaying ? 100 : 80,
                  height: _isPlaying ? 100 : 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: _isPlaying
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.radio : Icons.radio_outlined,
                    size: _isPlaying ? 60 : 50,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  station['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isVideo) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CANLI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if ((station['description'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              station['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isVideo
                  ? Colors.white10
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Dinleme Süresi: ${_formatDuration(_listenedDuration)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _selectedStationIndex > 0
                    ? () => _playStation(_selectedStationIndex - 1)
                    : null,
                icon: const Icon(Icons.skip_previous, size: 40),
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _togglePlay,
                  iconSize: 40,
                  icon: _isLoading
                      ? SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryYellow,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.primaryYellow,
                          size: 40,
                        ),
                  tooltip: _isPlaying ? 'Duraklat' : 'Oynat',
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _selectedStationIndex < _stations.length - 1
                    ? () => _playStation(_selectedStationIndex + 1)
                    : null,
                icon: const Icon(Icons.skip_next, size: 40),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white),
              Expanded(
                child: Slider(
                  value: _volume.clamp(0.0, 1.0),
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          _setVolume(value);
                        },
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(Map<String, String> station, int index) {
    final isFavorite = _favoriteStations.contains(index);
    final isCurrentStation = _selectedStationIndex == index;
    
    return Card(
      elevation: isCurrentStation ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isCurrentStation ? AppTheme.primaryYellow.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => _playStation(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radyo ikonu
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCurrentStation
                      ? AppTheme.primaryYellow
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCurrentStation && _isPlaying
                      ? Icons.graphic_eq
                      : Icons.radio,
                  color: isCurrentStation ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              
              // İstasyon bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrentStation ? AppTheme.primaryYellow : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station['description']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          station['country']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.language, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          station['language']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favori butonu
              IconButton(
                onPressed: () => _toggleFavorite(index),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
              
              // Oynat göstergesi
              if (isCurrentStation)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (_isPlaying) ...[
                        const Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Text(
                        'Şuan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Favorileri üste al
    final favoritesList = _stations.asMap().entries
        .where((entry) => _favoriteStations.contains(entry.key))
        .toList();
    final regularList = _stations.asMap().entries
        .where((entry) => !_favoriteStations.contains(entry.key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kur\'an Radyo'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kur\'an Radyo'),
                  content: const Text(
                    'Dünyanın farklı yerlerinden 7/24 Kur\'an-ı Kerim dinleyin.\n\n'
                    '• Canlı yayınlar\n'
                    '• Meşhur kariler\n'
                    '• Mekke ve Medine\'den canlı\n'
                    '• Favori istasyonlarınızı kaydedin\n\n'
                    'İnternet bağlantısı gerektirir.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Şuan çalan
                  _buildNowPlaying(),

                  // İstasyon listesi
                  if (favoritesList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red[400], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Favori İstasyonlar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...favoritesList.map(
                      (entry) => _buildStationCard(entry.value, entry.key),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                  ],

                  if (regularList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.radio, color: AppTheme.primaryYellow, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Tüm İstasyonlar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...regularList.map(
                      (entry) => _buildStationCard(entry.value, entry.key),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          const AdMobBanner(),
        ],
      ),
    );
  }
}
