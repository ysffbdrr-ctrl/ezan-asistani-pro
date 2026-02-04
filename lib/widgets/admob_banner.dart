import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ezan_asistani/services/ads_removal_service.dart';

class AdMobBanner extends StatefulWidget {
  const AdMobBanner({super.key});

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  bool _isLoading = false;
  bool _loadFailed = false;
  Timer? _loadingTimeout;
  bool _didAttemptLoad = false;
  Timer? _retryTimer;
  double? _lastWidth;

  Widget _placeholder(double height, {required bool failed}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Center(
          child: kDebugMode && failed
              ? Text(
                  'Reklam yüklenemedi',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  String get _testBannerAdUnitId {
    if (!_isSupportedPlatform) return '';
    if (Platform.isAndroid) return 'ca-app-pub-5825676889846336/4771332489';
    if (Platform.isIOS) return '';
    return '';
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadAdForWidth(double width) async {
    if (!_isSupportedPlatform) return;
    if (_isLoading || _isLoaded) return;
    if (_loadFailed || _didAttemptLoad) return;
    if (width <= 0) return;

    _lastWidth = width;

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    _didAttemptLoad = true;

    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (_isLoaded) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    });

    final adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width.truncate());
    if (!mounted) return;
    if (adaptiveSize == null) {
      _loadingTimeout?.cancel();
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
      return;
    }

    _adSize = adaptiveSize;

    final ad = BannerAd(
      adUnitId: _testBannerAdUnitId,
      request: const AdRequest(),
      size: adaptiveSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          final banner = ad as BannerAd;
          debugPrint(
            'AdMob banner loaded: ${banner.adUnitId} size=${banner.size}',
          );
          setState(() {
            _bannerAd = banner;
            _isLoaded = true;
            _isLoading = false;
            _loadFailed = false;
          });
          _loadingTimeout?.cancel();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          debugPrint(
            'AdMob banner failed: ${ad.adUnitId} '
            'code=${error.code} domain=${error.domain} message=${error.message} '
            'responseInfo=${error.responseInfo}',
          );
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _isLoading = false;
            _loadFailed = true;
          });
          _loadingTimeout?.cancel();

          _retryTimer?.cancel();
          _retryTimer = Timer(const Duration(seconds: 30), () {
            if (!mounted) return;
            final w = _lastWidth;
            if (w == null || w <= 0) return;
            setState(() {
              _loadFailed = false;
              _didAttemptLoad = false;
            });
            _loadAdForWidth(w);
          });
        },
      ),
    );

    ad.load();
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupportedPlatform) {
      return const SizedBox(height: 0);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: AdsRemovalService.adsRemoved,
      builder: (context, removed, _) {
        if (removed) {
          return const SizedBox(height: 0);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
            _lastWidth = width;
            if (width > 0 &&
                !_isLoading &&
                !_isLoaded &&
                !_loadFailed &&
                !_didAttemptLoad) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _loadAdForWidth(width);
              });
            }

            final reservedHeight =
                (_adSize?.height.toDouble() ?? AdSize.banner.height.toDouble());

            final ad = _bannerAd;
            if (_isLoaded && ad != null) {
              return SizedBox(
                width: double.infinity,
                height: reservedHeight,
                child: Center(
                  child: SizedBox(
                    width: ad.size.width.toDouble(),
                    height: ad.size.height.toDouble(),
                    child: AdWidget(ad: ad),
                  ),
                ),
              );
            }

            if (_loadFailed) {
              return _placeholder(reservedHeight, failed: true);
            }

            if (!_isLoading) {
              return _placeholder(reservedHeight, failed: false);
            }

            return SizedBox(
              width: double.infinity,
              height: reservedHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
