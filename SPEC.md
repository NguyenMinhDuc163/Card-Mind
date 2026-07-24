# SPEC: Tích hợp Google AdMob production cho Card Mind trên Android và iOS

## 1. Bối cảnh dự án

Dự án: `Card Mind`
Nền tảng: Flutter Android + iOS
Mục tiêu: tích hợp Google AdMob production vào app theo hướng kiếm tiền hiệu quả nhưng không phá trải nghiệm học flashcard.

Card Mind là app học bằng flashcard, có các flow chính:

* Dashboard có 4 tab: Home, Create Course, Chat Bot, Library.
* Home hiển thị danh sách khóa học, class và khóa học cần ôn tập.
* Create Course cho phép tạo khóa học/flashcard.
* Course Info hiển thị thông tin khóa học trước khi học.
* Detail Flashcard là màn học chính bằng swipe.
* TestScreen là màn làm bài kiểm tra.
* CourseResultScreen/TestResultScreen là màn kết quả sau học/test.
* ChatBotScreen là màn chat AI, hiện đã có consent riêng cho AI.
* App có local storage bằng Hive/LocalStorageHelper và có Firebase Auth/Firestore sync.

Yêu cầu triển khai là bản production nghiêm túc, không chia phase, không làm demo.

## 2. Mục tiêu

Triển khai đầy đủ các loại quảng cáo sau:

1. Native Ads
2. Adaptive Banner Ads
3. Interstitial Ads
4. Rewarded Ads
5. App Open Ads

Tuy nhiên, placement phải được kiểm soát chặt để không vi phạm chính sách và không phá core learning flow.

## 3. Nguyên tắc bắt buộc

### 3.1 Không đặt quảng cáo trong lúc người dùng đang học

Không được hiển thị bất kỳ quảng cáo nào trong các trạng thái sau:

* Đang học flashcard.
* Đang swipe thẻ.
* Đang làm test.
* Đang nhập form tạo course.
* Đang chat trong ChatBotScreen.
* Đang tương tác với nút quan trọng như Bookmark, Đã học, Chưa học, Submit.

### 3.2 Interstitial chỉ được hiện ở điểm nghỉ tự nhiên

Interstitial chỉ được phép hiện sau khi user hoàn thành task, ví dụ:

* Sau khi học xong một flashcard session.
* Sau khi làm xong bài test.
* Khi user đang ở màn result và bấm “Về Home”, “Học tiếp”, “Làm lại”, hoặc action tương tự.

Không được hiện interstitial:

* Khi app vừa mở.
* Khi app thoát.
* Khi user bấm vào course để bắt đầu học.
* Sau mỗi swipe.
* Sau mỗi click.
* Ngay sau khi một interstitial khác vừa đóng.
* Ngay sau khi màn result vừa render mà user chưa chủ động bấm gì.

Theo tài liệu AdMob, interstitial nên dùng ở natural pauses như sau khi hoàn thành task; không được làm user bất ngờ khi họ đang tập trung vào task như đọc nội dung, điền form, chơi game hoặc thao tác trong app. Google cũng cảnh báo không đặt interstitial sau mọi click/swipe, không đặt lúc app load/exit, và khuyến nghị dùng App Open Ads nếu muốn monetization khi app load hoặc quay lại app.
Nguồn tham khảo: Google Mobile Ads Flutter Quick Start và AdMob Help về disallowed interstitial implementations.

## 4. AdMob SDK setup

### 4.1 Thêm dependency

Thêm package vào `pubspec.yaml`:

```yaml
dependencies:
  google_mobile_ads: latest_stable_version
```

Codex cần kiểm tra version stable mới nhất tương thích Flutter hiện tại của project trước khi sửa file.

### 4.2 Android setup

File cần sửa:

```text
android/app/src/main/AndroidManifest.xml
```

Trong thẻ `<application>`, thêm:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ANDROID_ADMOB_APP_ID"/>
```

`ANDROID_ADMOB_APP_ID` phải là App ID dạng:

```text
ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

Không dùng ad unit ID ở đây.

Theo Google, nếu thiếu AdMob App ID trong `AndroidManifest.xml`, app có thể crash khi launch.

### 4.3 iOS setup

File cần sửa:

```text
ios/Runner/Info.plist
```

Thêm:

```xml
<key>GADApplicationIdentifier</key>
<string>IOS_ADMOB_APP_ID</string>
```

`IOS_ADMOB_APP_ID` phải là App ID dạng:

```text
ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

Không dùng ad unit ID ở đây.

Theo Google, iOS cần cấu hình `GADApplicationIdentifier` trong `Info.plist`.

### 4.4 iOS privacy

Codex cần chuẩn bị sẵn cấu trúc để sau này thêm:

* SKAdNetworkItems cho Google Mobile Ads.
* UMP consent nếu app target người dùng EEA/UK.
* ATT prompt nếu app dùng personalized ads/IDFA.

Không tự ý bật ATT prompt nếu chưa có nội dung `NSUserTrackingUsageDescription` chuẩn.

Google có hướng dẫn riêng về iOS privacy, SKAdNetwork và ATT/IDFA cho AdMob.

### 4.5 Initialize SDK trong `main.dart`

File:

```text
lib/main.dart
```

Thêm import:

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
```

Trong `main()`, sau khi init local/Firebase cơ bản và trước `runApp`, gọi:

```dart
await MobileAds.instance.initialize();
```

Vị trí đề xuất:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Bloc.observer = AppBlocObserver();
  await EasyLocalization.ensureInitialized();
  await ThemeService.init();
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();

  await MobileAds.instance.initialize();

  await SampleDataService.initializeSampleData();

  final Locale savedLocale = LocaleService.load();

  runApp(...);
}
```

Google yêu cầu initialize Mobile Ads SDK trước khi load ads và nên gọi sớm trong app.

## 5. Ad unit cần tạo trong AdMob

Tạo riêng Android và iOS. Không dùng chung ad unit giữa 2 nền tảng.

### 5.1 Android ad units

Tạo các ad unit sau:

```text
android_home_native
android_library_native
android_search_native
android_course_info_banner
android_after_study_interstitial
android_after_test_interstitial
android_rewarded_ai
android_app_open
```

### 5.2 iOS ad units

Tạo các ad unit sau:

```text
ios_home_native
ios_library_native
ios_search_native
ios_course_info_banner
ios_after_study_interstitial
ios_after_test_interstitial
ios_rewarded_ai
ios_app_open
```

### 5.3 Quy tắc test ad

Trong debug mode, bắt buộc dùng test ad unit IDs của Google. Không dùng ad unit production khi debug/dev.

Trong release mode, dùng ad unit thật.

## 6. Cấu trúc code cần tạo

Tạo module ads riêng, không gọi ads trực tiếp lộn xộn trong từng screen.

Tạo folder:

```text
lib/core/ads/
  ad_unit_ids.dart
  ad_config.dart
  ad_frequency_cap.dart
  ad_manager.dart
  interstitial_ad_service.dart
  rewarded_ad_service.dart
  app_open_ad_service.dart
  widgets/
    adaptive_banner_ad_widget.dart
    native_course_ad_widget.dart
```

## 7. `ad_unit_ids.dart`

Tạo file:

```text
lib/core/ads/ad_unit_ids.dart
```

Nội dung yêu cầu:

* Tách Android/iOS bằng `Platform.isAndroid`, `Platform.isIOS`.
* Tách debug/release bằng `kDebugMode`.
* Debug dùng test IDs.
* Release dùng constants production placeholder để developer thay thật.

Skeleton:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class AdUnitIds {
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testAppOpen = 'ca-app-pub-3940256099942544/3419835294';

  static String get homeNative {
    if (kDebugMode) return _testBanner;
    if (Platform.isAndroid) return 'ANDROID_HOME_NATIVE_ID';
    if (Platform.isIOS) return 'IOS_HOME_NATIVE_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get libraryNative {
    if (kDebugMode) return _testBanner;
    if (Platform.isAndroid) return 'ANDROID_LIBRARY_NATIVE_ID';
    if (Platform.isIOS) return 'IOS_LIBRARY_NATIVE_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get searchNative {
    if (kDebugMode) return _testBanner;
    if (Platform.isAndroid) return 'ANDROID_SEARCH_NATIVE_ID';
    if (Platform.isIOS) return 'IOS_SEARCH_NATIVE_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get courseInfoBanner {
    if (kDebugMode) return _testBanner;
    if (Platform.isAndroid) return 'ANDROID_COURSE_INFO_BANNER_ID';
    if (Platform.isIOS) return 'IOS_COURSE_INFO_BANNER_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get afterStudyInterstitial {
    if (kDebugMode) return _testInterstitial;
    if (Platform.isAndroid) return 'ANDROID_AFTER_STUDY_INTERSTITIAL_ID';
    if (Platform.isIOS) return 'IOS_AFTER_STUDY_INTERSTITIAL_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get afterTestInterstitial {
    if (kDebugMode) return _testInterstitial;
    if (Platform.isAndroid) return 'ANDROID_AFTER_TEST_INTERSTITIAL_ID';
    if (Platform.isIOS) return 'IOS_AFTER_TEST_INTERSTITIAL_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAi {
    if (kDebugMode) return _testRewarded;
    if (Platform.isAndroid) return 'ANDROID_REWARDED_AI_ID';
    if (Platform.isIOS) return 'IOS_REWARDED_AI_ID';
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpen {
    if (kDebugMode) return _testAppOpen;
    if (Platform.isAndroid) return 'ANDROID_APP_OPEN_ID';
    if (Platform.isIOS) return 'IOS_APP_OPEN_ID';
    throw UnsupportedError('Unsupported platform');
  }
}
```

Nếu Native Ads yêu cầu native-specific unit ID, vẫn giữ getter native riêng. Không dùng banner ID production cho native.

## 8. `ad_config.dart`

Tạo file:

```text
lib/core/ads/ad_config.dart
```

Nội dung:

```dart
class AdConfig {
  static const bool adsEnabled = true;

  static const int minStudyCardsForInterstitial = 5;
  static const int minTestQuestionsForInterstitial = 5;

  static const int interstitialCooldownSeconds = 180;
  static const int minCompletedSessionsBetweenInterstitials = 2;
  static const int maxInterstitialPerDay = 5;

  static const int maxRewardedPerDay = 10;

  static const int appOpenCooldownHours = 6;
  static const int appOpenInterstitialCooldownMinutes = 5;

  static const int homeNativeMinCourses = 4;
  static const int homeNativeInsertAfterIndex = 2;

  static const int libraryNativeFirstInsertAfterIndex = 3;
  static const int libraryNativeSecondInsertAfterIndex = 10;
  static const int libraryNativeMinItemsForSecondAd = 12;
  static const int libraryNativeMaxAds = 2;

  static const int searchNativeMinResults = 5;
  static const int searchNativeInsertAfterIndex = 3;
}
```

## 9. `ad_frequency_cap.dart`

Tạo file:

```text
lib/core/ads/ad_frequency_cap.dart
```

Dùng `LocalStorageHelper` để lưu trạng thái.

### 9.1 Keys cần lưu

```dart
class AdStorageKeys {
  static const String lastInterstitialShownAt = 'ads_last_interstitial_shown_at';
  static const String completedSessionsSinceLastInterstitial =
      'ads_completed_sessions_since_last_interstitial';
  static const String dailyInterstitialCount = 'ads_daily_interstitial_count';
  static const String dailyRewardedCount = 'ads_daily_rewarded_count';
  static const String dailyCounterDate = 'ads_daily_counter_date';
  static const String lastRewardedShownAt = 'ads_last_rewarded_shown_at';
  static const String lastAppOpenShownAt = 'ads_last_app_open_shown_at';
  static const String isLearningSession = 'ads_is_learning_session';
  static const String isTestSession = 'ads_is_test_session';
  static const String openedFromReviewNotification =
      'ads_opened_from_review_notification';
}
```

### 9.2 Logic bắt buộc

Implement các method:

```dart
class AdFrequencyCap {
  Future<bool> canShowStudyInterstitial({
    required int sessionCards,
  });

  Future<bool> canShowTestInterstitial({
    required int questionCount,
  });

  Future<void> markCompletedSession();

  Future<void> markInterstitialShown();

  Future<bool> canShowRewarded();

  Future<void> markRewardedShown();

  Future<bool> canShowAppOpen();

  Future<void> markAppOpenShown();

  Future<void> setLearningSessionActive(bool value);

  Future<void> setTestSessionActive(bool value);

  Future<bool> isLearningSessionActive();

  Future<bool> isTestSessionActive();

  Future<void> resetDailyCountersIfNeeded();
}
```

### 9.3 Điều kiện interstitial sau học

`canShowStudyInterstitial` chỉ return true nếu:

```text
adsEnabled == true
sessionCards >= 5
completedSessionsSinceLastInterstitial >= 2
dailyInterstitialCount < 5
lastInterstitialShownAt cách hiện tại >= 180 giây
lastRewardedShownAt cách hiện tại >= 120 giây
isLearningSession == false
isTestSession == false
```

### 9.4 Điều kiện interstitial sau test

`canShowTestInterstitial` chỉ return true nếu:

```text
adsEnabled == true
questionCount >= 5
completedSessionsSinceLastInterstitial >= 2
dailyInterstitialCount < 5
lastInterstitialShownAt cách hiện tại >= 180 giây
lastRewardedShownAt cách hiện tại >= 120 giây
isLearningSession == false
isTestSession == false
```

### 9.5 Điều kiện rewarded

`canShowRewarded` return true nếu:

```text
adsEnabled == true
dailyRewardedCount < 10
```

Rewarded là user chủ động xem, nên không cần cooldown quá nặng.

### 9.6 Điều kiện App Open

`canShowAppOpen` chỉ return true nếu:

```text
adsEnabled == true
lastAppOpenShownAt cách hiện tại >= 6 tiếng
lastInterstitialShownAt cách hiện tại >= 5 phút
isLearningSession == false
isTestSession == false
openedFromReviewNotification == false
```

Không hiển thị App Open khi user đang học/test hoặc mở app từ notification ôn tập.

## 10. `interstitial_ad_service.dart`

Tạo file:

```text
lib/core/ads/interstitial_ad_service.dart
```

Yêu cầu:

* Preload interstitial sau khi app init hoặc sau khi một interstitial được đóng.
* Có 2 placement riêng:

  * afterStudyInterstitial
  * afterTestInterstitial
* Không load/show nếu ads disabled.
* Không show nếu chưa loaded.
* Nếu show fail thì callback vẫn phải chạy để không kẹt navigation.
* Sau khi show xong, dispose ad và preload lại.

Interface đề xuất:

```dart
class InterstitialAdService {
  static final InterstitialAdService instance = InterstitialAdService._();
  InterstitialAdService._();

  Future<void> loadAfterStudyAd();
  Future<void> loadAfterTestAd();

  Future<void> showAfterStudyAdIfAvailable({
    required int sessionCards,
    required VoidCallback onComplete,
  });

  Future<void> showAfterTestAdIfAvailable({
    required int questionCount,
    required VoidCallback onComplete,
  });

  void dispose();
}
```

Quan trọng:

* `onComplete` phải được gọi trong mọi trường hợp: ad không có, fail, user close ad.
* Không gọi trực tiếp trong `DetailFlashCardNotifier.onSwipeRight/onSwipeLeft`.
* Không gọi khi vào CourseInfo hoặc khi bấm bắt đầu học.

## 11. `rewarded_ad_service.dart`

Tạo file:

```text
lib/core/ads/rewarded_ad_service.dart
```

Dùng cho ChatBotScreen và các reward học tập.

Interface:

```dart
class RewardedAdService {
  static final RewardedAdService instance = RewardedAdService._();
  RewardedAdService._();

  Future<void> loadRewardedAiAd();

  Future<void> showRewardedAiAdIfAvailable({
    required VoidCallback onRewardEarned,
    required VoidCallback onClosed,
    required VoidCallback onFailed,
  });

  void dispose();
}
```

Rule:

* Chỉ show khi user chủ động bấm xem quảng cáo.
* Không tự bật rewarded.
* Nếu reward earned, cộng lượt AI hoặc unlock benefit.
* Không dùng rewarded để khóa core flashcard learning.

## 12. `app_open_ad_service.dart`

Tạo file:

```text
lib/core/ads/app_open_ad_service.dart
```

Yêu cầu:

* Load App Open Ad sau khi SDK init.
* Lắng nghe app lifecycle resume.
* Chỉ show khi `AdFrequencyCap.canShowAppOpen() == true`.
* Không show lần đầu app mở ngay sau install.
* Không show nếu đang learning/test.
* Không show nếu app mở từ notification ôn tập.
* Không show nếu interstitial vừa hiện trong 5 phút.

Interface:

```dart
class AppOpenAdService with WidgetsBindingObserver {
  static final AppOpenAdService instance = AppOpenAdService._();
  AppOpenAdService._();

  Future<void> initialize();
  Future<void> loadAd();
  Future<void> showAdIfAvailable();
  void dispose();
}
```

Trong `main.dart` hoặc sau `runApp`, gọi initialize service phù hợp.

## 13. `ad_manager.dart`

Tạo file:

```text
lib/core/ads/ad_manager.dart
```

`AdManager` là facade duy nhất để screen gọi.

Interface:

```dart
class AdManager {
  static final AdManager instance = AdManager._();
  AdManager._();

  Future<void> initialize();

  Future<void> setLearningSessionActive(bool value);
  Future<void> setTestSessionActive(bool value);

  Future<void> onStudySessionCompleted({
    required int sessionCards,
    required VoidCallback onComplete,
  });

  Future<void> onTestCompleted({
    required int questionCount,
    required VoidCallback onComplete,
  });

  Future<void> showRewardedAi({
    required VoidCallback onRewardEarned,
    required VoidCallback onClosed,
    required VoidCallback onFailed,
  });
}
```

Screen chỉ gọi `AdManager`, không gọi trực tiếp `InterstitialAdService`, `RewardedAdService`, `AdFrequencyCap`.

## 14. Widget: Adaptive Banner

Tạo file:

```text
lib/core/ads/widgets/adaptive_banner_ad_widget.dart
```

Yêu cầu:

* Dùng `AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)`.
* Load banner bằng `AdUnitIds.courseInfoBanner`.
* Có loading state.
* Nếu fail thì return `SizedBox.shrink()`.
* Dispose ad trong `dispose()`.

Dùng ở CourseInfoScreen cuối màn.

## 15. Widget: Native Course Ad

Tạo file:

```text
lib/core/ads/widgets/native_course_ad_widget.dart
```

Yêu cầu:

* Tạo native ad card match style app.
* Có dark/light theme support.
* Nếu fail thì return `SizedBox.shrink()`.
* Không làm layout jump quá mạnh.
* Có label “Ad” hoặc “Sponsored” rõ ràng theo rule native ad.
* Dùng placement ID truyền từ ngoài:

  * Home dùng `AdUnitIds.homeNative`
  * Library dùng `AdUnitIds.libraryNative`
  * Search dùng `AdUnitIds.searchNative`

Interface:

```dart
class NativeCourseAdWidget extends StatelessWidget {
  final String adUnitId;
  final EdgeInsetsGeometry? margin;

  const NativeCourseAdWidget({
    super.key,
    required this.adUnitId,
    this.margin,
  });
}
```

Nếu Flutter native ad cần platform factory Android/iOS, Codex phải thêm native factory theo hướng dẫn của `google_mobile_ads`.

## 16. Placement chi tiết theo màn

### 16.1 HomeScreen

File cần tìm/sửa:

```text
lib/modules/home/screen/home_screen.dart
```

Đặt Native Ad trong danh sách course.

Rule:

```text
Nếu số course < 4: không hiện ad.
Nếu số course >= 4: chèn 1 NativeCourseAdWidget sau course index 1 hoặc sau item thứ 2.
Không hiện banner trên Home nếu đã hiện native.
Không show interstitial khi bấm course.
```

Pseudo:

```dart
final courses = notifier.homeData.courses;

ListView.builder(
  itemCount: courses.length + shouldShowHomeNative ? 1 : 0,
  itemBuilder: (context, index) {
    if (shouldShowHomeNative && index == AdConfig.homeNativeInsertAfterIndex) {
      return NativeCourseAdWidget(adUnitId: AdUnitIds.homeNative);
    }

    final courseIndex = shouldShowHomeNative && index > AdConfig.homeNativeInsertAfterIndex
        ? index - 1
        : index;

    return CourseItemWidget(course: courses[courseIndex]);
  },
);
```

### 16.2 LibraryScreen

File cần tìm/sửa:

```text
lib/modules/library/screen/library_screen.dart
```

Đặt Native Ad giữa danh sách.

Rule:

```text
Sau item thứ 3: hiện Native Ad thứ nhất.
Nếu list > 12 item: hiện Native Ad thứ hai sau item thứ 10.
Tối đa 2 native ads.
Không dùng interstitial trong Library.
```

### 16.3 GlobalSearchScreen

File cần tìm/sửa:

```text
lib/modules/home/screen/global_search_screen.dart
```

Rule:

```text
Chỉ hiện Native Ad khi result count >= 5.
Chèn sau result thứ 3.
Không hiện khi empty state.
Không hiện khi đang typing/debounce search.
Không show interstitial sau khi bấm search.
```

### 16.4 CourseInfoScreen

File cần tìm/sửa:

```text
lib/modules/course/screen/course_info_screen.dart
```

Đặt `AdaptiveBannerAdWidget` ở cuối màn, dưới thông tin khóa học và dưới nhóm nút hành động nếu layout cho phép.

Rule:

```text
Hiện banner cuối màn.
Không show interstitial khi bấm Học tất cả.
Không show interstitial khi bấm Ôn tập.
Không show interstitial khi bấm Học thẻ bookmark.
Không show interstitial khi bấm Làm kiểm tra.
```

### 16.5 DetailFlashCardScreen

File cần tìm/sửa:

```text
lib/modules/course/screen/detail_flash_card_screen.dart
lib/modules/course/provider/detail_flash_card_notifier.dart
```

Rule tuyệt đối:

```text
Không đặt banner.
Không đặt native.
Không đặt interstitial.
Không đặt rewarded.
Không gọi AdManager trong onSwipeRight.
Không gọi AdManager trong onSwipeLeft.
```

Khi vào màn học:

```dart
await AdManager.instance.setLearningSessionActive(true);
```

Khi thoát màn học hoặc dispose:

```dart
await AdManager.instance.setLearningSessionActive(false);
```

Khi học xong và đã lưu result, chuyển sang CourseResultScreen. Không show interstitial tại màn học.

### 16.6 CourseResultScreen

File cần tìm/sửa:

```text
lib/modules/course/screen/course_result_screen.dart
```

Rule:

```text
Không tự show interstitial ngay khi result screen render.
Chỉ show khi user bấm action như Về Home, Học tiếp, Làm bài test, hoặc button điều hướng tiếp.
```

Pseudo:

```dart
onPressed: () {
  AdManager.instance.onStudySessionCompleted(
    sessionCards: totalCards,
    onComplete: () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        DashboardScreen.routeName,
        (_) => false,
      );
    },
  );
}
```

Nếu màn này có button “Học lại thẻ sai”:

```text
Có thể show interstitial trước khi navigate nếu đủ điều kiện.
Không show nếu sessionCards < 5.
```

Có thể đặt thêm Native Ad dưới thống kê kết quả, nhưng không bắt buộc nếu đã có interstitial ở action.

### 16.7 TestScreen

File cần tìm/sửa:

```text
lib/modules/course/screen/test_screen.dart
```

Rule:

```text
Không đặt bất kỳ ads nào trong lúc làm test.
Không banner.
Không native.
Không interstitial.
Không rewarded.
```

Khi vào TestScreen:

```dart
await AdManager.instance.setTestSessionActive(true);
```

Khi rời TestScreen hoặc submit xong:

```dart
await AdManager.instance.setTestSessionActive(false);
```

### 16.8 TestResultScreen

File cần tìm/sửa:

```text
lib/modules/course/screen/test_result_screen.dart
```

Rule:

```text
Có thể đặt Native Ad dưới thống kê kết quả.
Interstitial chỉ show khi user bấm Về Home, Làm lại, Học thẻ sai.
Không auto show khi màn vừa render.
```

Pseudo:

```dart
onPressed: () {
  AdManager.instance.onTestCompleted(
    questionCount: totalQuestions,
    onComplete: () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        DashboardScreen.routeName,
        (_) => false,
      );
    },
  );
}
```

### 16.9 CreateCourseScreen

File cần tìm/sửa:

```text
lib/modules/create_course/screen/create_course_screen.dart
```

Rule:

```text
Không đặt ads.
Không banner cuối form.
Không interstitial khi lưu course.
Không interstitial khi thêm term.
Không native giữa input.
```

Lý do: đây là màn nhập liệu, ads dễ gây accidental click và phá trải nghiệm tạo nội dung.

### 16.10 ChatBotScreen

File cần tìm/sửa:

```text
lib/modules/message/screen/chat_bot_screen.dart
```

Rule:

```text
Không banner trong chat.
Không native trong conversation.
Không interstitial khi mở chat.
Chỉ dùng Rewarded Ad khi user hết lượt AI miễn phí và chủ động bấm xem quảng cáo.
```

Flow:

```text
User hết lượt AI miễn phí
→ Hiện option: "Xem quảng cáo để nhận thêm 3 lượt hỏi AI"
→ User bấm
→ showRewardedAi
→ onRewardEarned: cộng 3 lượt AI
→ onClosed: đóng ads
→ onFailed: báo nhẹ, không cộng lượt
```

Lưu lượt AI local bằng `LocalStorageHelper` hoặc nơi hiện tại app đang quản lý quota.

### 16.11 Settings

File cần tìm/sửa:

```text
lib/modules/settings/...
```

Rule:

```text
Không ưu tiên ads.
Không cần đặt ads.
Nếu đã có NotificationSettingsScreen hoặc SpacedRepetitionSettingsScreen thì không đặt interstitial.
```

### 16.12 App Open Ads

Rule:

```text
Chỉ show khi app resume từ background sau >= 6 tiếng.
Không show lần đầu mở app.
Không show khi đang học flashcard.
Không show khi đang làm test.
Không show nếu app mở từ notification ôn tập.
Không show nếu interstitial vừa show trong 5 phút.
```

Codex cần đảm bảo không show App Open nếu route hiện tại là:

```text
DetailFlashCardScreen
TestScreen
CreateCourseScreen đang nhập form
ChatBotScreen đang mở conversation
```

Nếu khó xác định route, dùng flags:

```text
ads_is_learning_session
ads_is_test_session
```

## 17. Frequency cap production

Áp dụng chính xác:

```text
Native:
- Home: tối đa 1
- Library: tối đa 2
- Search: tối đa 1

Banner:
- Chỉ CourseInfo.
- Không banner trong flashcard/test/chat/create.

Interstitial:
- Chỉ sau study/test result action.
- sessionCards >= 5.
- questionCount >= 5.
- Cooldown >= 180 giây.
- Cứ 2 completed sessions mới show tối đa 1 interstitial.
- Tối đa 5 interstitial/ngày/user.
- Không show nếu vừa xem rewarded trong 120 giây.
- Không show liên tiếp ngay sau một interstitial khác.

Rewarded:
- Tối đa 10 rewarded/ngày/user.
- User phải chủ động bấm xem.
- Không dùng để khóa học flashcard cơ bản.

App Open:
- Cooldown 6 tiếng.
- Không show nếu đang học/test.
- Không show nếu vừa interstitial trong 5 phút.
```

## 18. Analytics/logging

Nếu project đã có Firebase Analytics thì log các event:

```text
ad_load_success
ad_load_failed
ad_impression
ad_clicked
ad_show_requested
ad_show_skipped_frequency_cap
ad_show_skipped_learning_session
ad_show_skipped_test_session
study_session_completed
test_completed
rewarded_ai_earned
```

Nếu chưa có Analytics thì dùng debug log có prefix:

```text
[Ads]
```

Không log thông tin nhạy cảm của user.

## 19. Error handling

Yêu cầu:

* Ads load fail không được crash app.
* Ads show fail không được chặn navigation.
* Nếu native/banner fail thì return empty widget.
* Nếu interstitial fail thì chạy `onComplete`.
* Nếu rewarded fail thì gọi `onFailed`.
* Dispose toàn bộ ad object đúng lifecycle.

## 20. Acceptance criteria

Codex chỉ coi task hoàn thành khi đạt tất cả điều kiện sau:

### 20.1 Build

* Android build thành công.
* iOS build thành công.
* Không crash khi launch do thiếu AdMob App ID.
* Không lỗi import/dependency.

### 20.2 Placement

* Home có Native Ad đúng rule.
* Library có Native Ad đúng rule.
* Search có Native Ad đúng rule.
* CourseInfo có Adaptive Banner cuối màn.
* DetailFlashCardScreen không có ads.
* TestScreen không có ads.
* CreateCourseScreen không có ads.
* ChatBotScreen không có banner/native/interstitial.
* CourseResultScreen show interstitial qua button action nếu đủ điều kiện.
* TestResultScreen show interstitial qua button action nếu đủ điều kiện.
* Rewarded AI hoạt động qua user action.
* App Open chỉ hiện khi app resume sau cooldown và không ở learning/test session.

### 20.3 Policy/UX

* Không có interstitial sau mỗi swipe.
* Không có interstitial khi bấm vào course.
* Không có interstitial khi app vừa mở bằng interstitial thường.
* Không có interstitial khi user đang nhập form.
* Không có interstitial khi đang làm test.
* Không có ads che nút core action.
* Navigation không bị kẹt nếu ads fail.

### 20.4 Frequency cap

* Interstitial cooldown 180 giây hoạt động.
* Tối đa 5 interstitial/ngày/user.
* Cứ 2 completed sessions mới show 1 interstitial.
* App Open cooldown 6 tiếng hoạt động.
* Rewarded tối đa 10/ngày/user.

## 21. Ghi chú triển khai cho Codex

1. Ưu tiên sửa theo module ads trước, sau đó mới gắn vào từng màn.
2. Không tự ý thay đổi flow học flashcard.
3. Không tự ý đổi state management hiện tại.
4. Không refactor lớn ngoài phạm vi ads.
5. Không đặt ads trực tiếp trong notifier nghiệp vụ, ngoại trừ set flag learning/test session nếu cần.
6. Không dùng production ad unit trong debug.
7. Placeholder production IDs phải để rõ để developer thay:

   * `ANDROID_HOME_NATIVE_ID`
   * `IOS_HOME_NATIVE_ID`
   * v.v.
8. Sau khi sửa, chạy format và kiểm tra compile.
9. Nếu Native Ads yêu cầu native factory platform-side, triển khai đúng cho Android/iOS theo package `google_mobile_ads`, không bỏ dở bằng widget giả.

## 22. Kết luận

Chiến lược AdMob production cho Card Mind:

```text
Kiếm tiền ở màn danh sách và sau khi hoàn thành việc học/test.
Không kiếm tiền trong lúc người dùng đang học, đang làm test, đang nhập liệu hoặc đang chat.
```

Placement bắt buộc:

```text
Home: Native
Library: Native
Search: Native
CourseInfo: Adaptive Banner
CourseResult: Interstitial qua button action
TestResult: Interstitial qua button action
ChatBot: Rewarded cho thêm lượt AI
App Resume: App Open có cooldown chặt
```

Placement bị cấm trong app này:

```text
DetailFlashCardScreen
TestScreen
CreateCourseScreen
Trong conversation ChatBot
Sau mỗi swipe
Khi bấm vào course
Khi app vừa mở bằng interstitial thường
Khi user bấm Back liên tục
```
