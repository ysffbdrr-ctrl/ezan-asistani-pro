import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ezan_asistani/services/ads_removal_service.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static final InterstitialAdService instance = InterstitialAdService._();

  static const int _showEvery = 3;

  int _navigationCount = 0;
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  String get _testInterstitialAdUnitId {
    if (!_isSupportedPlatform) return '';
    if (Platform.isAndroid) return 'ca-app-pub-5825676889846336/3232193562';
    if (Platform.isIOS) return '';
    return '';
  }

  void preload() {
    if (AdsRemovalService.adsRemoved.value) return;
    if (!_isSupportedPlatform) return;
    if (_interstitialAd != null) return;
    if (_isLoading) return;

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: _testInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitialAd = ad;
          debugPrint('InterstitialAd loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _interstitialAd = null;
          debugPrint(
            'InterstitialAd failed to load: '
            'code=${error.code} domain=${error.domain} message=${error.message} '
            'responseInfo=${error.responseInfo}',
          );
        },
      ),
    );
  }

  bool _shouldShowNow() {
    _navigationCount++;
    return _navigationCount % _showEvery == 0;
  }

  Future<void> maybeShowThen(Future<void> Function() onContinue) async {
    if (AdsRemovalService.adsRemoved.value) {
      await onContinue();
      return;
    }

    if (!_isSupportedPlatform) {
      await onContinue();
      return;
    }

    final shouldShow = _shouldShowNow();
    if (!shouldShow) {
      await onContinue();
      preload();
      return;
    }

    if (_isShowing) {
      await onContinue();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      await onContinue();
      preload();
      return;
    }

    _isShowing = true;

    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        preload();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'InterstitialAd failed to show: '
          'code=${error.code} domain=${error.domain} message=${error.message}',
        );
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        preload();
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      ad.show();
    } catch (_) {
      _isShowing = false;
      _interstitialAd = null;
      preload();
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
    await onContinue();
  }
}
