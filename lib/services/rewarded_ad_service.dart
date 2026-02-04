import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ezan_asistani/services/ads_removal_service.dart';

class RewardedAdService {
  RewardedAdService._();

  static final RewardedAdService instance = RewardedAdService._();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isShowing = false;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  String get _testRewardedAdUnitId {
    if (!_isSupportedPlatform) return '';
    if (Platform.isAndroid) return 'ca-app-pub-5825676889846336/9222886845';
    if (Platform.isIOS) return '';
    return '';
  }

  void preload() {
    if (AdsRemovalService.adsRemoved.value) return;
    if (!_isSupportedPlatform) return;
    if (_rewardedAd != null) return;
    if (_isLoading) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _rewardedAd = ad;
          debugPrint('RewardedAd loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _rewardedAd = null;
          debugPrint(
            'RewardedAd failed to load: '
            'code=${error.code} domain=${error.domain} message=${error.message} '
            'responseInfo=${error.responseInfo}',
          );
        },
      ),
    );
  }

  /// Returns true if user earned the reward.
  Future<bool> show() async {
    if (AdsRemovalService.adsRemoved.value) return false;
    if (!_isSupportedPlatform) return false;
    if (_isShowing) return false;

    final ad = _rewardedAd;
    if (ad == null) {
      preload();
      return false;
    }

    _isShowing = true;
    bool earned = false;

    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isShowing = false;
        preload();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'RewardedAd failed to show: '
          'code=${error.code} domain=${error.domain} message=${error.message}',
        );
        ad.dispose();
        _rewardedAd = null;
        _isShowing = false;
        preload();
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          earned = true;
        },
      );
    } catch (_) {
      _isShowing = false;
      _rewardedAd = null;
      preload();
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
    return earned;
  }
}
