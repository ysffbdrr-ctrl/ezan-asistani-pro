import 'package:flutter_tts/flutter_tts.dart';
import 'package:ezan_asistani/utils/logger.dart';
import 'dart:async';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  Completer<void>? _speakCompleter;

  Future<void> _selectPreferredEngineAndVoice() async {
    try {
      final engines = await _flutterTts.getEngines;
      if (engines is List) {
        final google = engines
            .whereType<String>()
            .firstWhere(
              (e) => e.toLowerCase().contains('google'),
              orElse: () => '',
            );
        if (google.isNotEmpty) {
          await _flutterTts.setEngine(google);
        }
      }
    } catch (_) {
      // ignore
    }

    try {
      final voices = await _flutterTts.getVoices;
      if (voices is! List) return;

      Map<String, dynamic>? best;
      for (final v in voices) {
        if (v is! Map) continue;
        final map = Map<String, dynamic>.from(v.cast<String, dynamic>());
        final locale = (map['locale'] ?? map['language'] ?? map['lang'])?.toString().toLowerCase() ?? '';
        if (!locale.startsWith('tr')) continue;
        best ??= map;
        final name = (map['name'] ?? '').toString().toLowerCase();
        if (name.contains('wavenet') || name.contains('natural') || name.contains('enhanced')) {
          best = map;
          break;
        }
      }

      if (best != null) {
        final voice = <String, String>{};
        for (final entry in best.entries) {
          final k = entry.key;
          final v = entry.value;
          if (v == null) continue;
          voice[k] = v.toString();
        }
        await _flutterTts.setVoice(voice);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      try {
        await _flutterTts.awaitSpeakCompletion(true);
      } catch (_) {
        // Some platforms may not support this.
      }
      try {
        await _flutterTts.awaitSynthCompletion(true);
      } catch (_) {
        // Some platforms may not support this.
      }

      await _selectPreferredEngineAndVoice();

      await _flutterTts.setLanguage('tr_TR');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        AppLogger.info('Sesli okuma başladı');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _speakCompleter?.complete();
        _speakCompleter = null;
        AppLogger.info('Sesli okuma tamamlandı');
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _speakCompleter?.completeError(msg);
        _speakCompleter = null;
        AppLogger.error('TTS hatası', error: msg);
      });

      _isInitialized = true;
      AppLogger.success('TTS servisi başlatıldı');
    } catch (e) {
      AppLogger.error('TTS başlatma hatası', error: e);
    }
  }

  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (_isSpeaking) {
        await stop();
      }

      await _flutterTts.speak(text);
    } catch (e) {
      AppLogger.error('Konuşma hatası', error: e);
    }
  }

  Duration _estimateSpeakDuration(String text) {
    // Very rough fallback when platform completion callbacks don't fire reliably.
    // Assume ~18 chars/sec at default rate (0.8), clamp to a reasonable window.
    final len = text.trim().length;
    final seconds = (len / 18.0).ceil();
    final clamped = seconds.clamp(1, 30);
    return Duration(seconds: clamped);
  }

  Future<void> speakAndWait(String text, {Duration? timeout}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (_isSpeaking) {
        await stop();
      }

      _speakCompleter?.complete();
      _speakCompleter = Completer<void>();

      final trimmed = text.trim();
      if (trimmed.isEmpty) return;

      await _flutterTts.speak(trimmed);

      final effectiveTimeout = timeout ?? _estimateSpeakDuration(trimmed);
      try {
        await _speakCompleter!.future.timeout(effectiveTimeout);
      } on TimeoutException {
        // If completion didn't arrive, allow the caller to continue auto-play.
        AppLogger.warning('TTS completion timeout; continuing to next item');
        _speakCompleter?.complete();
        _speakCompleter = null;
      }
    } catch (e) {
      AppLogger.error('Konuşma hatası', error: e);
      _speakCompleter?.complete();
      _speakCompleter = null;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
      AppLogger.info('Sesli okuma durduruldu');
    } catch (e) {
      AppLogger.error('Durdurma hatası', error: e);
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      AppLogger.info('Sesli okuma duraklatıldı');
    } catch (e) {
      AppLogger.error('Duraklatma hatası', error: e);
    }
  }

  bool get isSpeaking => _isSpeaking;

  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      AppLogger.info('Dil değiştirildi: $language');
    } catch (e) {
      AppLogger.error('Dil değiştirme hatası', error: e);
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      AppLogger.error('Hız ayarlama hatası', error: e);
    }
  }
}
