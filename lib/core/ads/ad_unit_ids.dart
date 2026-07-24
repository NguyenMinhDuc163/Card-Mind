import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized Ad Unit IDs for Card Mind.
///
/// - Debug mode uses Google's official test ad unit IDs.
/// - Release mode uses production placeholders that the developer must replace
///   with real AdMob ad unit IDs before publishing.
class AdUnitIds {
  // Google official test ad unit IDs
  static const String _testAppOpen = 'ca-app-pub-3940256099942544/3419835294';
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testNativeAdvanced =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testRewarded =
      'ca-app-pub-3940256099942544/5224354917';

  // ── Android production IDs ──
  static const String _androidHomeNative = 'ca-app-pub-4649011658078977/5079742293';
  static const String _androidLibraryNative = 'ca-app-pub-4649011658078977/7514333944';
  static const String _androidSearchNative = 'ca-app-pub-4649011658078977/2262007261';
  static const String _androidCourseInfoBanner = 'ca-app-pub-4649011658078977/8635843923';
  static const String _androidAfterStudyInterstitial =
      'ca-app-pub-4649011658078977/7098686969';
  static const String _androidAfterTestInterstitial =
      'ca-app-pub-4649011658078977/8444272232';
  static const String _androidRewardedAi = 'ca-app-pub-4649011658078977/3191945550';
  static const String _androidAppOpen = 'ca-app-pub-4649011658078977/8252700549';

  // ── iOS production IDs ──
  static const String _iosHomeNative = 'ca-app-pub-4649011658078977/8280620704';
  static const String _iosLibraryNative = 'ca-app-pub-4649011658078977/3240312940';
  static const String _iosSearchNative = 'ca-app-pub-4649011658078977/4341375693';
  static const String _iosCourseInfoBanner = 'ca-app-pub-4649011658078977/2229503669';
  static const String _iosAfterStudyInterstitial =
      'ca-app-pub-4649011658078977/4971931088';
  static const String _iosAfterTestInterstitial =
      'ca-app-pub-4649011658078977/2297666289';
  static const String _iosRewardedAi = 'ca-app-pub-4649011658078977/7406522737';
  static const String _iosAppOpen = 'ca-app-pub-4649011658078977/4149804002';

  // ── Public getters ──

  static String get homeNative {
    if (kDebugMode) return _testNativeAdvanced;
    if (Platform.isAndroid) return _androidHomeNative;
    if (Platform.isIOS) return _iosHomeNative;
    throw UnsupportedError('Unsupported platform');
  }

  static String get libraryNative {
    if (kDebugMode) return _testNativeAdvanced;
    if (Platform.isAndroid) return _androidLibraryNative;
    if (Platform.isIOS) return _iosLibraryNative;
    throw UnsupportedError('Unsupported platform');
  }

  static String get searchNative {
    if (kDebugMode) return _testNativeAdvanced;
    if (Platform.isAndroid) return _androidSearchNative;
    if (Platform.isIOS) return _iosSearchNative;
    throw UnsupportedError('Unsupported platform');
  }

  static String get courseInfoBanner {
    if (kDebugMode) return _testBanner;
    if (Platform.isAndroid) return _androidCourseInfoBanner;
    if (Platform.isIOS) return _iosCourseInfoBanner;
    throw UnsupportedError('Unsupported platform');
  }

  static String get afterStudyInterstitial {
    if (kDebugMode) return _testInterstitial;
    if (Platform.isAndroid) return _androidAfterStudyInterstitial;
    if (Platform.isIOS) return _iosAfterStudyInterstitial;
    throw UnsupportedError('Unsupported platform');
  }

  static String get afterTestInterstitial {
    if (kDebugMode) return _testInterstitial;
    if (Platform.isAndroid) return _androidAfterTestInterstitial;
    if (Platform.isIOS) return _iosAfterTestInterstitial;
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAi {
    if (kDebugMode) return _testRewarded;
    if (Platform.isAndroid) return _androidRewardedAi;
    if (Platform.isIOS) return _iosRewardedAi;
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpen {
    if (kDebugMode) return _testAppOpen;
    if (Platform.isAndroid) return _androidAppOpen;
    if (Platform.isIOS) return _iosAppOpen;
    throw UnsupportedError('Unsupported platform');
  }
}
