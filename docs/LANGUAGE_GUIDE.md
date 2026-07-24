# 🌐 Hướng dẫn hệ thống Đa ngôn ngữ

## 📋 Tổng quan

Dự án Card Mind đã được tích hợp hệ thống đa ngôn ngữ hoàn chỉnh với:
- ✅ **Quản lý state** với `LocaleCubit` (Bloc pattern)
- ✅ **Lưu trữ locale** với `LocaleService` (SharedPreferences)
- ✅ **Đồng bộ với EasyLocalization**
- ✅ **UI chuyển đổi ngôn ngữ** trong Drawer
- ✅ **Tự động load locale đã lưu** khi khởi động app

## 🏗️ Kiến trúc

```
lib/
├── core/
│   └── theme/
│       ├── locale_service.dart      # Service lưu/load locale
│       ├── locale_cubit.dart        # Bloc quản lý state locale
│       ├── theme_service.dart       # Tương tự cho theme
│       └── theme_cubit.dart         # Bloc quản lý state theme
├── core/widgets/
│   ├── switch_Lang.dart             # Widget chuyển đổi VI/EN
│   └── drawer_widget.dart           # Drawer có nút chuyển ngôn ngữ
└── assets/translations/
    ├── en-US.json                   # Translation tiếng Anh
    └── vi-VN.json                   # Translation tiếng Việt
```

## 🎯 Cách sử dụng

### 1. Thêm translation keys mới

**File:** `assets/translations/en-US.json`
```json
{
  "common": {
    "hello": "Hello"
  },
  "home_screen": {
    "welcome": "Welcome to Card Mind"
  }
}
```

**File:** `assets/translations/vi-VN.json`
```json
{
  "common": {
    "hello": "Xin chào"
  },
  "home_screen": {
    "welcome": "Chào mừng đến Card Mind"
  }
}
```

### 2. Sử dụng translation trong code

```dart
import 'package:easy_localization/easy_localization.dart';

// Cách 1: Sử dụng .tr()
Text('common.hello'.tr())

// Cách 2: Với parameters
Text('greeting'.tr(args: ['John']))

// Cách 3: Plural
Text('items'.plural(5))
```

### 3. Chuyển đổi ngôn ngữ trong code

```dart
import 'package:card_mind/core/theme/locale_cubit.dart';

// Lấy LocaleCubit
final localeCubit = context.read<LocaleCubit>();

// Toggle giữa EN và VI
await localeCubit.toggleLocale(context);

// Chuyển sang ngôn ngữ cụ thể
await localeCubit.changeLocale(const Locale('vi', 'VN'), context);

// Kiểm tra ngôn ngữ hiện tại
final isVietnamese = localeCubit.isVietnamese;
final isEnglish = localeCubit.isEnglish;
final languageName = localeCubit.currentLanguageName;
```

### 4. Lắng nghe thay đổi locale

```dart
BlocBuilder<LocaleCubit, Locale>(
  builder: (context, locale) {
    return Text('Current: ${locale.languageCode}');
  },
)
```

## 🎨 UI Components

### Switch Language Widget

```dart
import 'package:card_mind/core/widgets/switch_Lang.dart';

SwitchLang(
  onTap: () {
    context.read<LocaleCubit>().toggleLocale(context);
  },
  isEnglish: locale.languageCode == 'en',
  colorText: Colors.blue,
  colorBackground: Colors.white,
)
```

## 🔧 API Reference

### LocaleService

```dart
// Load locale từ storage
Locale locale = LocaleService.load();

// Lưu locale
await LocaleService.save(const Locale('vi', 'VN'));

// Xóa locale (reset về mặc định)
await LocaleService.clear();
```

### LocaleCubit

```dart
// Properties
List<Locale> supportedLocales        // ['en_US', 'vi_VN']
bool isVietnamese                     // true nếu đang dùng tiếng Việt
bool isEnglish                        // true nếu đang dùng tiếng Anh
String currentLanguageName            // 'Tiếng Việt' hoặc 'English'

// Methods
Future<void> changeLocale(Locale locale, BuildContext context)
Future<void> toggleLocale(BuildContext context)
```

## 🚀 Flow hoạt động

```
1. App Start
   ↓
2. LocaleService.load() → Đọc locale đã lưu từ SharedPreferences
   ↓
3. EasyLocalization(startLocale: savedLocale) → Khởi tạo với locale đã lưu
   ↓
4. LocaleCubit() → Tạo Cubit với state = savedLocale
   ↓
5. User tap vào nút chuyển ngôn ngữ
   ↓
6. localeCubit.toggleLocale(context)
   ↓
7. LocaleCubit:
   - emit(newLocale) → Cập nhật state
   - LocaleService.save(newLocale) → Lưu vào storage
   - context.setLocale(newLocale) → Cập nhật EasyLocalization
   ↓
8. BlocBuilder rebuild → UI cập nhật với ngôn ngữ mới
```

## 📦 Thêm ngôn ngữ mới

1. **Tạo file translation:** `assets/translations/ja-JP.json`

2. **Cập nhật LocaleCubit:**
```dart
static const List<Locale> supportedLocales = [
  Locale('en', 'US'),
  Locale('vi', 'VN'),
  Locale('ja', 'JP'), // Thêm tiếng Nhật
];
```

3. **Cập nhật main.dart và main_preview.dart:**
```dart
EasyLocalization(
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('vi', 'VN'),
    Locale('ja', 'JP'), // Thêm tiếng Nhật
  ],
  // ...
)
```

4. **Cập nhật Switch Widget** nếu cần UI phức tạp hơn

## ⚠️ Lưu ý quan trọng

1. **BuildContext across async gaps:**
   - LocaleCubit đã xử lý với `context.mounted` check
   - An toàn khi sử dụng async operations

2. **Đồng bộ Theme và Locale:**
   - ThemeCubit và LocaleCubit độc lập nhau
   - Cả hai đều sử dụng Bloc pattern tương tự
   - Cả hai đều lưu state vào SharedPreferences

3. **Hot reload:**
   - Thay đổi translation files → Hot reload OK
   - Thay đổi locale → Widget rebuild tự động

## 🧪 Testing

```dart
// Test LocaleService
test('LocaleService should save and load locale', () async {
  await LocaleService.save(const Locale('vi', 'VN'));
  final loaded = LocaleService.load();
  expect(loaded.languageCode, 'vi');
});

// Test LocaleCubit
blocTest<LocaleCubit, Locale>(
  'emits new locale when changeLocale is called',
  build: () => LocaleCubit(),
  act: (cubit) => cubit.changeLocale(const Locale('vi', 'VN'), context),
  expect: () => [const Locale('vi', 'VN')],
);
```

## 📝 Checklist triển khai

- [x] Tạo LocaleService để lưu/load locale
- [x] Tạo LocaleCubit để quản lý state
- [x] Cập nhật translation files (en-US.json, vi-VN.json)
- [x] Cải thiện SwitchLang widget
- [x] Thêm nút chuyển ngôn ngữ vào Drawer
- [x] Tích hợp LocaleCubit vào main.dart
- [x] Tích hợp LocaleCubit vào main_preview.dart
- [x] Tích hợp LocaleCubit vào app.dart (MultiBlocProvider)

## 🎉 Kết quả

Bây giờ ứng dụng của bạn đã có:
- ✅ Hệ thống đa ngôn ngữ hoàn chỉnh
- ✅ Lưu trữ ngôn ngữ đã chọn
- ✅ Tự động load lại khi mở app
- ✅ UI chuyển đổi mượt mà
- ✅ Đồng bộ với theme system
- ✅ Dễ dàng mở rộng thêm ngôn ngữ mới

---

**Created by:** Claude AI Assistant
**Date:** 2025-10-31
**Version:** 1.0.0
