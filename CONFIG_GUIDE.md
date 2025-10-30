# 🎛️ Hướng Dẫn Cấu Hình Spaced Repetition

## ✅ ĐÃ HOÀN THÀNH

Tính năng **cấu hình tham số Spaced Repetition** đã được tích hợp hoàn chỉnh!

---

## 🎯 Tính Năng

### ✨ Điều Bạn Có Thể Làm:

1. ✅ **Thay đổi đơn vị thời gian**: Ngày hoặc Phút
2. ✅ **Tùy chỉnh interval lần 1**: Từ 1-7 ngày hoặc 1-10 phút
3. ✅ **Tùy chỉnh interval lần 2**: Từ 1-14 ngày hoặc 1-20 phút
4. ✅ **Tùy chỉnh interval tối đa**: Từ 30-365 ngày hoặc 20-60 phút
5. ✅ **Xem trước timeline**: Xem trước lịch ôn tập với config hiện tại
6. ✅ **Reset về mặc định**: Một nút bấm để reset tất cả
7. ✅ **Lưu vào Hive**: Config được lưu tự động

---

## 📱 Cách Sử Dụng

### Bước 1: Mở Settings

1. Mở **Drawer** (menu bên trái)
2. Nhấn vào **"Cài đặt Spaced Repetition"** (icon ⏰)

### Bước 2: Chọn Đơn Vị Thời Gian

**Có 2 lựa chọn:**

#### 🚀 **Ngày (Production)**
```
Dành cho sử dụng thực tế
Timeline: 1 ngày → 3 ngày → ~8 ngày → ...
```

#### 🧪 **Phút (Test)**
```
Dành cho kiểm thử nhanh
Timeline: 1 phút → 3 phút → ~8 phút → ...
```

### Bước 3: Điều Chỉnh Intervals

Sử dụng **Slider** để điều chỉnh:

- **Interval lần 1**: Ôn lại sau X ngày/phút
- **Interval lần 2**: Ôn lại sau Y ngày/phút
- **Interval tối đa**: Tối đa Z ngày/phút

### Bước 4: Xem Trước Timeline

Phần **"Xem trước timeline"** sẽ hiển thị:
```
Lần 1: Ôn lại sau 1 ngày
Lần 2: Ôn lại sau 3 ngày
Lần 3: ~8 ngày (3 × 2.5)
Max: 180 ngày
```

### Bước 5: Lưu Cấu Hình

Nhấn nút **"Lưu cấu hình"** ở dưới cùng.

✅ Thấy thông báo "Đã lưu cấu hình thành công!"

---

## 🎛️ Presets Có Sẵn

### 📦 **Mặc Định (Production)**
```
Đơn vị: Ngày
Interval 1: 1 ngày
Interval 2: 3 ngày
Max: 180 ngày
Ease Factor: 2.5
```

### 🧪 **Test Mode**
```
Đơn vị: Phút
Interval 1: 1 phút
Interval 2: 3 phút
Max: 30 phút
Ease Factor: 2.5
```

---

## 🔧 Cấu Trúc Code

### 1️⃣ **Tất Cả Đóng Gói Trong 1 File**

**File**: `lib/core/services/spaced_repetition_service.dart`

```dart
class SpacedRepetitionService {
  // ============ CẤU HÌNH MẶC ĐỊNH ============
  static const String _defaultTimeUnit = 'days';
  static const int _defaultInterval1 = 1;
  static const int _defaultInterval2 = 3;
  static const int _defaultMaxInterval = 180;

  // ============ GETTERS ============
  String get timeUnit => ...;
  int get interval1 => ...;
  int get interval2 => ...;
  int get maxInterval => ...;

  // ============ SETTERS ============
  Future<void> updateConfig({...}) async { ... }
  Future<void> resetToDefault() async { ... }

  // ============ LOGIC CŨ ============
  Future<void> saveCardReviewData(...) { ... }
  // ... các method khác
}
```

### 2️⃣ **Sử Dụng Config**

**File**: `lib/data/models/card_review_data.dart`

```dart
factory CardReviewData.initial(...) {
  final service = SpacedRepetitionService();

  final intervalDays = isLearned ? service.interval1 : 0;
  final nextReviewDate = isLearned
      ? now.add(service.getDuration(intervalDays))
      : now;

  return CardReviewData(...);
}
```

### 3️⃣ **Màn Hình Settings**

**File**: `lib/modules/settings/screen/spaced_repetition_settings_screen.dart`

- Radio buttons để chọn đơn vị (ngày/phút)
- Sliders để điều chỉnh intervals
- Preview timeline
- Nút lưu và reset

### 4️⃣ **Tích Hợp Vào Drawer**

**File**: `lib/core/widgets/drawer_widget.dart`

```dart
_buildDrawerItem(
  context,
  icon: Icon(Icons.schedule, color: context.colors.onPrimary),
  title: 'Cài đặt Spaced Repetition',
  onTap: () {
    Navigator.pushNamed(
      context,
      SpacedRepetitionSettingsScreen.routeName,
    );
  },
),
```

---

## 💾 Lưu Trữ Config

### Hive Key:
```
'spaced_repetition_config'
```

### Cấu Trúc Data:
```json
{
  "timeUnit": "days",
  "interval1": 1,
  "interval2": 3,
  "maxInterval": 180,
  "initialEaseFactor": 2.5,
  "easeFactorIncrement": 0.1,
  "easeFactorDecrement": 0.2,
  "minEaseFactor": 1.3,
  "maxEaseFactor": 2.5
}
```

---

## 🎨 Giao Diện

### Màu Sắc Sử Dụng (Từ Theme):

```dart
- context.colors.primary          // Background chính
- context.colors.onPrimary        // Text trên primary
- context.brandColors.cardBackground  // Background của card
- context.brandColors.textPrimary     // Text chính
- context.brandColors.textSecondary   // Text phụ
- context.brandColors.progressValue   // Màu accent (xanh lá)
```

✅ **KHÔNG có màu hard-coded** → Tự động theo theme hệ thống

---

## 📝 Các Tham Số Có Thể Cấu Hình

| Tham Số | Mô Tả | Giá Trị Mặc Định |
|---------|-------|------------------|
| **timeUnit** | Đơn vị thời gian ('days' hoặc 'minutes') | 'days' |
| **interval1** | Interval ôn lần 1 | 1 |
| **interval2** | Interval ôn lần 2 | 3 |
| **maxInterval** | Interval tối đa | 180 |
| **initialEaseFactor** | Ease factor ban đầu | 2.5 |
| **easeFactorIncrement** | Tăng ease khi đúng | 0.1 |
| **easeFactorDecrement** | Giảm ease khi sai | 0.2 |
| **minEaseFactor** | Ease factor min | 1.3 |
| **maxEaseFactor** | Ease factor max | 2.5 |

---

## 🧪 Kịch Bản Test

### Test 1: Chuyển Sang Test Mode (Phút)

1. Mở Settings
2. Chọn **"Phút (Test)"**
3. Để mặc định interval1=1, interval2=3
4. Nhấn **"Lưu cấu hình"**
5. Học flashcard → Đợi **1 phút** → Thấy "Cần ôn tập" ✅

### Test 2: Tùy Chỉnh Intervals

1. Mở Settings
2. Đổi interval1 = 2 phút
3. Đổi interval2 = 5 phút
4. Xem preview timeline (Lần 1: 2 phút, Lần 2: 5 phút)
5. Lưu → Học flashcard → Đợi **2 phút** → Thấy "Cần ôn tập" ✅

### Test 3: Reset Về Mặc Định

1. Mở Settings
2. Nhấn icon **Reset** (⟳) ở góc phải trên
3. Confirm → Tất cả về mặc định ✅
4. Timeline: 1 ngày → 3 ngày → ... ✅

---

## 🚀 Ưu Điểm

### ✅ **Đơn Giản**
- Chỉ 1 file service duy nhất
- Không tạo file thừa
- Dễ bảo trì

### ✅ **Linh Hoạt**
- Thay đổi bất kỳ tham số nào
- Test mode và Production mode đều OK
- Không cần sửa code

### ✅ **Persistence**
- Config lưu vào Hive
- Tự động load khi khởi động
- Không mất config khi restart app

### ✅ **UI Thân Thiện**
- Slider dễ dùng
- Preview timeline
- Màu sắc theo theme

---

## 🎯 Workflow Thực Tế

### Khi Phát Triển (Development):
```
1. Mở Settings
2. Chọn "Phút (Test)"
3. Interval: 1, 3, 30
4. Lưu
5. Test nhanh trong vài phút
```

### Khi Production:
```
1. Mở Settings
2. Chọn "Ngày (Production)"
3. Interval: 1, 3, 180
4. Lưu
5. User sử dụng thực tế
```

### Khi Muốn Tùy Chỉnh:
```
1. Mở Settings
2. Điều chỉnh sliders
3. Xem preview timeline
4. Lưu
5. Done!
```

---

## 📊 So Sánh Trước/Sau

| Trước | Sau |
|-------|-----|
| ❌ Phải sửa code để test | ✅ Chỉ cần mở Settings |
| ❌ Comment/uncomment nhiều chỗ | ✅ Toggle 1 nút |
| ❌ Dễ quên uncomment | ✅ Lưu vào Hive tự động |
| ❌ Tạo nhiều file config | ✅ Tất cả trong 1 file |
| ❌ Khó bảo trì | ✅ Dễ bảo trì |

---

## 🔍 Troubleshooting

### Vấn đề: Thay đổi config nhưng không thấy khác biệt
**Giải pháp:**
1. Check console log: "✅ Đã cập nhật config"
2. Restart app (config mới áp dụng cho flashcard mới)
3. Flashcard cũ vẫn dùng config cũ

### Vấn đề: Reset không hoạt động
**Giải pháp:**
1. Nhấn icon Reset ở góc phải trên AppBar
2. Check console: "🔄 Đã reset config về mặc định"
3. Restart app

---

## 📁 Files Đã Thêm/Sửa

### ✅ Đã Sửa (3 files):
1. `lib/core/services/spaced_repetition_service.dart` - Thêm config
2. `lib/data/models/card_review_data.dart` - Sử dụng config
3. `lib/core/widgets/drawer_widget.dart` - Thêm menu Settings
4. `lib/core/routes/routers.dart` - Thêm route Settings

### ✅ Đã Tạo (1 file):
1. `lib/modules/settings/screen/spaced_repetition_settings_screen.dart` - Màn hình Settings

**Tổng: 5 files** (4 sửa, 1 tạo mới)

---

## 🎉 Kết Luận

Bây giờ bạn có thể **cấu hình mọi tham số Spaced Repetition** chỉ bằng vài cú nhấn chuột!

### Không cần:
- ❌ Sửa code
- ❌ Comment/uncomment
- ❌ Rebuild app
- ❌ Nhớ vị trí các tham số

### Chỉ cần:
- ✅ Mở Settings
- ✅ Điều chỉnh sliders
- ✅ Nhấn "Lưu"
- ✅ Done! 🎉

---

**Happy Coding!** 🚀
