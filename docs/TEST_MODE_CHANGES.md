# 🧪 Thay Đổi Code Cho Test Mode

## 📂 File Đã Sửa

### `lib/data/models/card_review_data.dart`

Chỉ sửa **1 file duy nhất** với **3 thay đổi nhỏ**:

---

## 🔄 Thay Đổi Chi Tiết

### ✏️ Thay Đổi 1: `CardReviewData.initial()` - Dòng 58-68

#### ❌ Code PRODUCTION (đã comment):
```dart
// ============ PRODUCTION CODE (THỜI GIAN THẬT - NGÀY) ============
// Nếu đã học: ôn lại sau 1 ngày
// Nếu chưa học: ôn lại ngay hôm nay
// final intervalDays = isLearned ? 1 : 0;
// final nextReviewDate = now.add(Duration(days: intervalDays));
```

#### ✅ Code TEST (đang dùng):
```dart
// ============ TEST CODE (THỜI GIAN RÚT NGẮN - PHÚT) ============
// 🧪 TESTING: 1 ngày → 1 phút để test nhanh
final intervalDays = isLearned ? 1 : 0;
final nextReviewDate = now.add(Duration(minutes: intervalDays)); // 👈 PHÚT thay vì NGÀY
// ============================================================
```

**Thay đổi:** `Duration(days: ...)` → `Duration(minutes: ...)`

---

### ✏️ Thay Đổi 2: `nextReview()` - Interval Logic - Dòng 120-144

#### ❌ Code PRODUCTION (đã comment):
```dart
// ============ PRODUCTION CODE (THỜI GIAN THẬT - NGÀY) ============
// if (newRepetitions == 1) {
//   newInterval = 1; // Ngày 1: ôn lại sau 1 ngày
// } else if (newRepetitions == 2) {
//   newInterval = 3; // Ngày 2: ôn lại sau 3 ngày
// } else {
//   // Từ lần 3 trở đi: interval = interval_trước * ease_factor
//   newInterval = (intervalDays * easeFactor).round();
// }
// // Giới hạn interval tối đa 180 ngày (6 tháng)
// newInterval = newInterval.clamp(1, 180);
```

#### ✅ Code TEST (đang dùng):
```dart
// ============ TEST CODE (THỜI GIAN RÚT NGẮN - PHÚT) ============
// 🧪 TESTING: 1 ngày → 1 phút, 3 ngày → 3 phút
if (newRepetitions == 1) {
  newInterval = 1; // Lần 1: ôn lại sau 1 PHÚT 👈
} else if (newRepetitions == 2) {
  newInterval = 3; // Lần 2: ôn lại sau 3 PHÚT 👈
} else {
  // Từ lần 3 trở đi: interval = interval_trước * ease_factor
  newInterval = (intervalDays * easeFactor).round();
}
// Giới hạn interval tối đa 30 phút (thay vì 180 ngày) 👈
newInterval = newInterval.clamp(1, 30);
// ============================================================
```

**Thay đổi:**
- Max interval: `180 ngày` → `30 phút`
- Comment thêm "PHÚT" để dễ phân biệt

---

### ✏️ Thay Đổi 3: `nextReview()` - Next Review Date - Dòng 152-158

#### ❌ Code PRODUCTION (đã comment):
```dart
// ============ PRODUCTION CODE ============
// nextReviewDate: now.add(Duration(days: newInterval)),
```

#### ✅ Code TEST (đang dùng):
```dart
// ============ TEST CODE ============
// 🧪 TESTING: Dùng PHÚT thay vì NGÀY
nextReviewDate: now.add(Duration(minutes: newInterval)), // 👈 PHÚT
// ====================================
```

**Thay đổi:** `Duration(days: ...)` → `Duration(minutes: ...)`

---

## 📊 Bảng So Sánh Tổng Quan

| Tham số | Production (Thật) | Test Mode (Hiện tại) | Lý do |
|---------|-------------------|----------------------|-------|
| **Interval Lần 1** | 1 **ngày** | 1 **phút** | Test nhanh |
| **Interval Lần 2** | 3 **ngày** | 3 **phút** | Test nhanh |
| **Interval Lần 3** | ~8 **ngày** | ~8 **phút** | Test nhanh |
| **Max Interval** | 180 **ngày** (6 tháng) | 30 **phút** | Giới hạn hợp lý cho test |
| **Duration Unit** | `Duration(days: ...)` | `Duration(minutes: ...)` | Core change |

---

## ⚡ Tác Động Của Thay Đổi

### ✅ Điều KHÔNG thay đổi:
- ✅ Logic tính toán interval (vẫn là 1, 3, ease_factor × interval)
- ✅ Ease factor vẫn tăng/giảm bình thường
- ✅ Repetitions vẫn đếm đúng
- ✅ Swipe right/left vẫn hoạt động như cũ
- ✅ UI, HomeScreen, Section "Cần ôn tập" vẫn y chang

### 🔄 Điều ĐÃ thay đổi:
- 🔄 Đơn vị thời gian: **NGÀY → PHÚT**
- 🔄 Max interval: **180 ngày → 30 phút**
- 🔄 Tốc độ test: **Vài ngày → Vài phút**

---

## 🎯 Mục Đích

**Cho phép test tính năng Spaced Repetition trong vài phút thay vì vài ngày!**

Ví dụ timeline test:
```
⏱️ 00:00 - Học lần đầu (swipe right tất cả)
⏱️ 01:00 - Đợi 1 phút → Refresh → Thấy "Cần ôn tập" ✅
⏱️ 02:00 - Ôn lần 2 (swipe right tất cả)
⏱️ 05:00 - Đợi 3 phút → Refresh → Thấy "Cần ôn tập" lại ✅
⏱️ 06:00 - Ôn lần 3 (swipe right tất cả)
⏱️ 14:00 - Đợi ~8 phút → Refresh → Thấy "Cần ôn tập" lại ✅

TỔNG: ~15 phút để test đầy đủ 3 lần ôn tập! 🎉
```

---

## 🔧 Cách Khôi Phục Code Production

Khi test xong, làm ngược lại:

### Bước 1: Mở file
```
lib/data/models/card_review_data.dart
```

### Bước 2: Comment code TEST
Tìm các dòng có `// TEST CODE` và comment lại:
```dart
// ============ TEST CODE ============
// final nextReviewDate = now.add(Duration(minutes: intervalDays));
```

### Bước 3: Uncomment code PRODUCTION
Tìm các dòng có `// PRODUCTION CODE` và uncomment:
```dart
// ============ PRODUCTION CODE ============
final nextReviewDate = now.add(Duration(days: intervalDays)); // ✅ Bỏ //
```

### Bước 4: Tìm tất cả 3 chỗ:
1. Dòng 58-68: `CardReviewData.initial()`
2. Dòng 120-144: `nextReview()` - interval logic
3. Dòng 152-158: `nextReview()` - nextReviewDate

---

## 🔍 Cách Kiểm Tra Code Đang Ở Mode Nào

### Check nhanh:
```bash
# Mở file
code lib/data/models/card_review_data.dart

# Tìm dòng 67 hoặc 157
# Nếu thấy:
Duration(minutes: ...)  → Đang ở TEST MODE ✅
Duration(days: ...)     → Đang ở PRODUCTION MODE ❌ (cần sửa lại)
```

---

## 📝 Notes

- ⚠️ Code TEST chỉ dùng để kiểm thử
- ⚠️ Nhớ khôi phục lại code PRODUCTION trước khi release
- ⚠️ Nếu quên khôi phục → App sẽ ôn tập mỗi vài phút (quá nhanh!)
- ✅ Tất cả thay đổi đều có comment rõ ràng
- ✅ Code cũ vẫn còn nguyên (chỉ comment)
- ✅ Dễ dàng switch qua lại giữa TEST và PRODUCTION

---

## 🎯 Tóm Tắt 1 Dòng

**Chỉ sửa 1 file, thay `Duration(days: x)` → `Duration(minutes: x)` ở 3 chỗ để test nhanh!** ⚡

---

**Happy Testing!** 🚀
