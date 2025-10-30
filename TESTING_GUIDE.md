# 🧪 Hướng Dẫn Kiểm Thử Spaced Repetition

## ⏱️ Thời Gian Test Đã Rút Ngắn

Code hiện tại đã được chỉnh để **rút ngắn thời gian từ NGÀY xuống PHÚT** để test dễ dàng:

### 📊 Bảng So Sánh:

| Lần ôn | Production (Thật) | Test (Rút ngắn) |
|--------|-------------------|-----------------|
| Lần 1  | 1 ngày            | **1 phút** ⏱️   |
| Lần 2  | 3 ngày            | **3 phút** ⏱️   |
| Lần 3  | ~8 ngày           | **~8 phút** ⏱️  |
| Lần 4  | ~20 ngày          | **~20 phút** ⏱️ |
| Max    | 180 ngày          | **30 phút** ⏱️  |

---

## 🔧 Code Đã Sửa

### File: `lib/data/models/card_review_data.dart`

**2 chỗ đã sửa:**

#### 1️⃣ Dòng 64-68: `CardReviewData.initial()`
```dart
// PRODUCTION CODE (đã comment):
// final nextReviewDate = now.add(Duration(days: intervalDays));

// TEST CODE (đang dùng):
final nextReviewDate = now.add(Duration(minutes: intervalDays)); // 🧪 PHÚT
```

#### 2️⃣ Dòng 120-158: `nextReview()`
```dart
// PRODUCTION CODE (đã comment):
// if (newRepetitions == 1) {
//   newInterval = 1; // 1 ngày
// } else if (newRepetitions == 2) {
//   newInterval = 3; // 3 ngày
// }
// newInterval = newInterval.clamp(1, 180); // Max 180 ngày
// nextReviewDate: now.add(Duration(days: newInterval)),

// TEST CODE (đang dùng):
if (newRepetitions == 1) {
  newInterval = 1; // 1 PHÚT ⏱️
} else if (newRepetitions == 2) {
  newInterval = 3; // 3 PHÚT ⏱️
}
newInterval = newInterval.clamp(1, 30); // Max 30 phút ⏱️
nextReviewDate: now.add(Duration(minutes: newInterval)), // 🧪 PHÚT
```

---

## 🧪 Kịch Bản Test Chi Tiết

### **Test 1: Học Lần Đầu (1 phút)**

#### Bước 1: Chạy app
```bash
flutter run
```

#### Bước 2: Tạo hoặc chọn course
- Tạo course mới HOẶC chọn course có sẵn
- Vào màn hình học flashcard

#### Bước 3: Học tất cả thẻ
- Swipe **RIGHT** (➡️) tất cả các thẻ
- Xem console log:
```
💾 Saved review data for card xxx: interval=1 days, nextReview=14:35:00
✅ Updated review for card xxx: isCorrect=true, nextInterval=1 days
```

#### Bước 4: Về HomeScreen
- Back về HomeScreen
- **KHÔNG THẤY** section "Cần ôn tập hôm nay" (vì chưa đến 1 phút)

#### Bước 5: Đợi 1 phút ⏱️
- Đợi **1-2 phút**
- Pull to refresh HomeScreen (vuốt xuống)
- **THẤY** section "Cần ôn tập hôm nay" ✅
- Có badge "5 thẻ" (hoặc số thẻ bạn đã học)

#### Kết quả mong đợi:
✅ Section hiển thị
✅ Badge đúng số lượng
✅ Nhấn vào → vào màn hình học

---

### **Test 2: Ôn Lần 2 (3 phút)**

#### Bước 1: Nhấn vào course trong "Cần ôn tập"
- Vào màn hình học flashcard

#### Bước 2: Học lại tất cả thẻ
- Swipe **RIGHT** (➡️) tất cả các thẻ
- Console log:
```
✅ Updated review for card xxx: isCorrect=true, nextInterval=3 days
```

#### Bước 3: Về HomeScreen
- **KHÔNG THẤY** section "Cần ôn tập" (vì chưa đến 3 phút)

#### Bước 4: Đợi 3 phút ⏱️
- Đợi **3-4 phút**
- Pull to refresh HomeScreen
- **THẤY** section "Cần ôn tập hôm nay" lại ✅

#### Kết quả mong đợi:
✅ Sau 3 phút lại hiển thị
✅ Badge vẫn đúng số lượng

---

### **Test 3: Swipe Left (Reset)**

#### Bước 1: Vào màn hình học
- Chọn course cần ôn

#### Bước 2: Swipe LEFT một thẻ
- Swipe **LEFT** (⬅️) 1-2 thẻ
- Console log:
```
❌ Swiped LEFT - Unlearned: Apple
✅ Updated review for card xxx: isCorrect=false, nextInterval=0 days
```

#### Bước 3: Về HomeScreen NGAY
- Back về HomeScreen
- **THẤY NGAY** section "Cần ôn tập" ✅
- Badge tăng lên (vì có thẻ cần ôn ngay)

#### Kết quả mong đợi:
✅ Hiển thị ngay (không cần đợi)
✅ Badge tăng lên

---

### **Test 4: Ôn Lần 3 (~8 phút)**

#### Bước 1: Ôn lại lần 2 (interval = 3 phút)
- Swipe RIGHT tất cả thẻ
- Console log:
```
✅ nextInterval=7 days (hoặc 8 phút)
```

#### Bước 2: Đợi ~8 phút ⏱️
- Đợi **8-10 phút**
- Pull to refresh
- **THẤY** section lại

#### Kết quả mong đợi:
✅ Interval tăng dần theo công thức

---

## 📱 Các Cách Kiểm Tra

### **Cách 1: Xem Console Log**
Trong Flutter console, bạn sẽ thấy:
```
💾 Saved review data for card abc123: interval=1 days, nextReview=14:35
📚 Loaded courses needing review: {course-456: 5}
🔍 Found 1 courses with cards needing review: {course-456: 5}
```

### **Cách 2: Xem Hive Data (Advanced)**
Mở Hive Inspector hoặc check console:
```dart
// Trong console sẽ có log từ SpacedRepetitionService
```

### **Cách 3: Pull to Refresh**
- Vuốt xuống ở HomeScreen để refresh
- Section sẽ xuất hiện/biến mất tùy theo thời gian

---

## ⚠️ Lưu Ý Quan Trọng

### 1. **Hot Reload Không Đủ**
- Sau khi đợi 1-3 phút, **KHÔNG dùng Hot Reload**
- Phải **PULL TO REFRESH** hoặc **RESTART APP**
- Vì HomeNotifier chỉ load data khi `initializeData()`

### 2. **Xem Đồng Hồ**
- Lần 1: Đợi **1 phút**
- Lần 2: Đợi **3 phút**
- Lần 3: Đợi **~8 phút**

### 3. **Console Log Là Bạn**
- Luôn mở console để xem log
- Check `nextReview` time
- Verify interval đúng không

### 4. **Section Tự Ẩn**
- Nếu không có thẻ cần ôn → section tự ẩn
- Đây là tính năng, không phải bug

---

## 🔄 Khôi Phục Lại Code Production

Khi test xong, **uncomment code production** và **comment code test**:

### File: `lib/data/models/card_review_data.dart`

#### Dòng 58-68: Khôi phục
```dart
// ============ PRODUCTION CODE (THỜI GIAN THẬT - NGÀY) ============
final intervalDays = isLearned ? 1 : 0;
final nextReviewDate = now.add(Duration(days: intervalDays)); // ✅ NGÀY

// ============ TEST CODE (THỜI GIAN RÚT NGẮN - PHÚT) ============
// final intervalDays = isLearned ? 1 : 0;
// final nextReviewDate = now.add(Duration(minutes: intervalDays)); // ❌ Comment
```

#### Dòng 120-158: Khôi phục
```dart
// ============ PRODUCTION CODE (THỜI GIAN THẬT - NGÀY) ============
if (newRepetitions == 1) {
  newInterval = 1; // Ngày 1: ôn lại sau 1 ngày ✅
} else if (newRepetitions == 2) {
  newInterval = 3; // Ngày 2: ôn lại sau 3 ngày ✅
} else {
  newInterval = (intervalDays * easeFactor).round();
}
newInterval = newInterval.clamp(1, 180); // Max 180 ngày ✅
// ...
nextReviewDate: now.add(Duration(days: newInterval)), // ✅ NGÀY

// ============ TEST CODE (THỜI GIAN RÚT NGẮN - PHÚT) ============
// if (newRepetitions == 1) {
//   newInterval = 1; // ❌ Comment
// ...
// nextReviewDate: now.add(Duration(minutes: newInterval)), // ❌ Comment
```

---

## ✅ Checklist Test

- [ ] Test 1: Học lần đầu → đợi 1 phút → thấy section
- [ ] Test 2: Ôn lần 2 → đợi 3 phút → thấy section lại
- [ ] Test 3: Swipe left → thấy section ngay
- [ ] Test 4: Ôn lần 3 → đợi ~8 phút → thấy section
- [ ] Badge hiển thị đúng số lượng thẻ
- [ ] Section tự ẩn khi không có thẻ cần ôn
- [ ] Console log đúng như mong đợi
- [ ] Nhấn vào course → vào màn hình học đúng

---

## 🐛 Troubleshooting

### Vấn đề: Đợi 1 phút rồi mà không thấy section
**Giải pháp:**
1. Pull to refresh HomeScreen (vuốt xuống)
2. Hoặc restart app
3. Check console log: `Found X courses with cards needing review`

### Vấn đề: Section không ẩn khi không có thẻ
**Giải pháp:**
1. Check logic trong HomeScreen line 106-108
2. Verify `coursesNeedingReview.isEmpty`

### Vấn đề: Badge hiển thị sai số lượng
**Giải pháp:**
1. Check console: `Loaded courses needing review: {course-456: 5}`
2. Verify field `reviewCardsCount` trong CourseItem

---

## 📝 Kết Luận

Bây giờ bạn có thể test tính năng Spaced Repetition trong **vài phút** thay vì **vài ngày**!

**Timeline test nhanh:**
- ⏱️ **0 phút**: Học lần đầu
- ⏱️ **1 phút**: Thấy section "Cần ôn tập"
- ⏱️ **4 phút**: Ôn lần 2 xong
- ⏱️ **12 phút**: Thấy section lại (ôn lần 3)

**Tổng thời gian test đầy đủ: ~15-20 phút** 🎉

---

**Chúc bạn test thành công!** 🚀

Nếu có vấn đề gì, check console log và file này để debug.
