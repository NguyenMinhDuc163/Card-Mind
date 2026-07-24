# AdMob Integration Plan for Card Mind

**Created**: 2026-07-24
**Status**: In Progress — Integration complete, awaiting static analysis

## Outcome

Integrate Google AdMob production into Card Mind Flutter app with all 5 ad formats: Native, Adaptive Banner, Interstitial, Rewarded, App Open. Ads placed only at natural breakpoints; no ads during learning, testing, form input, or chat.

## Files Created

### Core Ads Module (`lib/core/ads/`)

| File | Purpose |
|------|---------|
| `ad_unit_ids.dart` | Centralized ad unit IDs with debug/production toggle |
| `ad_config.dart` | All frequency caps and placement rules |
| `ad_frequency_cap.dart` | Stateful enforcement of caps via Hive |
| `ad_manager.dart` | Facade — screens call only this |
| `interstitial_ad_service.dart` | Pre-load and show after-study/after-test interstitials |
| `rewarded_ad_service.dart` | User-initiated rewarded ads for AI quota |
| `app_open_ad_service.dart` | App Open ads on resume with lifecycle observer |
| `widgets/adaptive_banner_ad_widget.dart` | Banner widget for CourseInfoScreen |
| `widgets/native_course_ad_widget.dart` | Native ad card widget for list screens |

## Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `google_mobile_ads: ^5.2.0` |
| `android/app/src/main/AndroidManifest.xml` | Added AdMob App ID meta-data |
| `ios/Runner/Info.plist` | Added `GADApplicationIdentifier` |
| `lib/main.dart` | Added `MobileAds.instance.initialize()` + `AdManager.instance.initialize()` |
| `lib/modules/home/screen/home_screen.dart` | Native ad in classes list |
| `lib/modules/library/widgets/content_screen.dart` | Native ads in content list |
| `lib/modules/home/screen/global_search_screen.dart` | Native ad in search results |
| `lib/modules/course/screen/course_info_screen.dart` | Banner ad at bottom |
| `lib/modules/course/screen/course_result_screen.dart` | Interstitial on action buttons |
| `lib/modules/course/screen/test_result_screen.dart` | Interstitial on "Finish" button |
| `lib/modules/course/screen/detail_flash_card_screen.dart` | Learning session flag |
| `lib/modules/course/screen/test_screen.dart` | Test session flag |
| `lib/modules/message/screen/chat_bot_screen.dart` | Rewarded ad button |
| `assets/translations/en-US.json` | Added reward translation keys |
| `assets/translations/vi-VN.json` | Added reward translation keys |

## Ad Placement Summary

| Screen | Ad Type | Rule |
|--------|---------|------|
| HomeScreen | Native (1x) | After index 2, min 4 classes |
| LibraryScreen (Content) | Native (2x max) | After index 3 & 10, min 12 items for 2nd |
| GlobalSearchScreen | Native (1x) | After index 3, min 5 results |
| CourseInfoScreen | Banner | Bottom of screen |
| DetailFlashCardScreen | 🚫 NONE | Sets learningSession=true |
| TestScreen | 🚫 NONE | Sets testSession=true |
| CreateCourseScreen | 🚫 NONE | No ads by design |
| ChatBotScreen | Rewarded (button) | User-initiated only |
| CourseResultScreen | Interstitial | On "Back to home" / close actions |
| TestResultScreen | Interstitial | On "Finish" button |
| App Resume | App Open | 6h cooldown, no learning/test session |

## Key Design Decisions

1. **Single facade pattern**: Screens call `AdManager.instance` only
2. **Minimal keys**: Only 2 platform App IDs + 16 ad unit placeholders
3. **Debug safety**: All debug mode uses Google test ad IDs
4. **Navigation safety**: `onComplete` always called, even on ad failure
5. **Session awareness**: Learning/test flags prevent ads during study

## Validation

- [ ] `fvm flutter pub get` — resolves dependencies
- [ ] `fvm flutter analyze` — no errors
- Developer must replace placeholder IDs before production release:
  - `ANDROID_*_ID` → real Android ad unit IDs
  - `IOS_*_ID` → real iOS ad unit IDs
  - `ca-app-pub-3940256099942544~3347511713` (Android App ID) → real App ID
  - `ca-app-pub-3940256099942544~1458002511` (iOS App ID) → real App ID

## Risks

- The `google_mobile_ads` API may have version-specific changes; the code
  avoids deprecated methods (`setOnImmersiveMode`, `setOnPaidEvent`) and uses
  stable API surfaces
- Native ads require a `factoryId` ('listTile' by default); if custom
  templates are needed, platform-specific factories must be registered
- SKAdNetwork and ATT are not yet configured — needed for iOS personalized ads
