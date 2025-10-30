
# Hướng Dẫn Tính Năng Spaced Repetition (Lặp Lại Ngắt Quãng)

## Tổng Quan

Tính năng **Spaced Repetition** (Lặp lại ngắt quãng) đã được tích hợp vào ứng dụng Card Mind để giúp người dùng ghi nhớ kiến thức hiệu quả hơn và lâu dài hơn.

### Spaced Repetition là gì?

Spaced Repetition là một phương pháp học tập khoa học, dựa trên việc ôn tập kiến thức theo khoảng thời gian tăng dần. Thay vì học lại tất cả mọi thứ mỗi ngày, bạn chỉ cần ôn tập những gì sắp quên.

## Cách Hoạt Động

### 1. Thuật Toán

Ứng dụng sử dụng thuật toán đơn giản hóa của **SM-2** với các đặc điểm:

#### Khi người dùng đánh dấu "Đã học" (Swipe Right ➡️):
- **Lần 1**: Ôn lại sau **1 ngày**
- **Lần 2**: Ôn lại sau **3 ngày**
- **Lần 3+**: Interval = Interval_trước × Ease_Factor
  - Ease Factor tăng dần (mặc định: 2.5, tăng 0.1 mỗi lần)
  - Interval tối đa: **180 ngày** (6 tháng)

#### Khi người dùng đánh dấu "Chưa học" (Swipe Left ⬅️):
- Reset về đầu: Ôn lại **ngay hôm nay**
- Ease Factor giảm 0.2 (minimum: 1.3)
- Repetitions reset về 0

### 2. Dữ Liệu Lưu Trữ

Mỗi flashcard có thông tin review được lưu trong Hive với cấu trúc:

```dart
CardReviewData {
  cardId: String              // ID của flashcard
  courseId: String            // ID của khóa học
  lastReviewDate: DateTime    // Ngày ôn tập lần cuối
  nextReviewDate: DateTime    // Ngày cần ôn tập tiếp theo
  intervalDays: int           // Số ngày giữa các lần ôn tập
  easeFactor: double          // Hệ số độ dễ (1.3 - 2.5)
  repetitions: int            // Số lần ôn tập thành công
  quality: int                // Chất lượng ôn tập (0-5)
}
```

**Hive Keys:**
- `review_data_{courseId}_{cardId}` - Dữ liệu review của từng card
- `course_reviews_{courseId}` - Danh sách cardIds có review data

### 3. Giao Diện Người Dùng

#### Màn Hình Home
- **Section "Cần ôn tập hôm nay"**: Hiển thị các khóa học có thẻ cần ôn tập
- **Badge số lượng**: Hiển thị số thẻ cần ôn trong mỗi khóa học
- **Thiết kế nổi bật**: Gradient xanh lá với border để thu hút sự chú ý

#### Trong Quá Trình Học
- Khi swipe right/left, hệ thống tự động lưu review data
- Không cần thao tác thêm từ người dùng

## Cấu Trúc Code

### 1. Models
**`lib/data/models/card_review_data.dart`**
- Model chứa thông tin review của flashcard
- Các methods:
  - `initial()` - Tạo review data lần đầu
  - `needsReview()` - Kiểm tra có cần ôn tập không
  - `nextReview()` - Tính toán review data tiếp theo

### 2. Services
**`lib/core/services/spaced_repetition_service.dart`**
- Singleton service quản lý review data
- Các methods chính:
  - `saveCardReviewData()` - Lưu review data
  - `getCardReviewData()` - Lấy review data của 1 card
  - `getCardsNeedingReview()` - Lấy cards cần ôn của 1 course
  - `getCoursesWithCardsNeedingReview()` - Lấy tất cả courses có cards cần ôn
  - `updateAfterReview()` - Cập nhật sau khi ôn tập
  - `deleteCourseReviewData()` - Xóa review data khi xóa course

### 3. Provider Updates

#### DetailFlashCardNotifier
**`lib/modules/course/provider/detail_flash_card_notifier.dart`**
- Thêm import: `SpacedRepetitionService`
- Update `onSwipeRight()`: Lưu review data với `isCorrect: true`
- Update `onSwipeLeft()`: Lưu review data với `isCorrect: false`

#### HomeNotifier
**`lib/modules/home/provider/home_notifier.dart`**
- Thêm field: `_coursesNeedingReview` (Map<courseId, reviewCount>)
- Thêm getter: `coursesNeedingReview` - Lấy courses cần ôn
- Update `initializeData()`: Load courses needing review
- Update `_loadCourses()`: Gắn reviewCardsCount vào CourseItem

### 4. UI Updates

#### HomeData Model
**`lib/modules/home/model/home_data.dart`**
- Thêm field `reviewCardsCount` vào `CourseItem`

#### HomeScreen
**`lib/modules/home/screen/home_screen.dart`**
- Thêm section "Cần ôn tập hôm nay" với horizontal ListView
- Hiển thị badge số lượng thẻ cần ôn
- Gradient design nổi bật với màu xanh lá

## Quy Trình Hoạt Động

### Flow 1: Học Lần Đầu
```
1. User học flashcard mới
2. Swipe right (đã học) → SpacedRepetitionService.updateAfterReview(isCorrect: true)
3. Tạo CardReviewData với:
   - intervalDays: 1
   - nextReviewDate: hôm nay + 1 ngày
   - repetitions: 1
4. Lưu vào Hive
```

### Flow 2: Ôn Tập
```
1. Ngày mai, HomeScreen load courses needing review
2. User thấy khóa học trong section "Cần ôn tập hôm nay"
3. User học lại → swipe right
4. SpacedRepetitionService tính toán:
   - intervalDays: 3 (lần 2)
   - nextReviewDate: hôm nay + 3 ngày
   - repetitions: 2
   - easeFactor: 2.6
5. Lưu vào Hive
```

### Flow 3: Quên (Swipe Left)
```
1. User swipe left (chưa nhớ)
2. SpacedRepetitionService reset:
   - intervalDays: 0
   - nextReviewDate: hôm nay (ôn lại ngay)
   - repetitions: 0
   - easeFactor: 2.3 (giảm 0.2)
3. Thẻ vẫn hiển thị trong "Cần ôn tập hôm nay"
```

## Ví Dụ Thời Gian Ôn Tập

Giả sử bạn học một từ mới hôm nay (Ease Factor = 2.5):

| Lần ôn | Kết quả | Interval | Ngày ôn tiếp theo |
|--------|---------|----------|-------------------|
| 1      | ✅ Đúng | 1 ngày   | Ngày mai          |
| 2      | ✅ Đúng | 3 ngày   | 3 ngày sau        |
| 3      | ✅ Đúng | 7 ngày   | 1 tuần sau        |
| 4      | ✅ Đúng | 17 ngày  | 2.5 tuần sau      |
| 5      | ❌ Sai  | 0 ngày   | Hôm nay (reset)   |
| 6      | ✅ Đúng | 1 ngày   | Ngày mai          |

## Testing

### Test Thủ Công

1. **Tạo một khóa học mới**
   ```
   - Tạo course với 5 flashcards
   - Học tất cả cards (swipe right)
   ```

2. **Kiểm tra review data trong Hive**
   ```dart
   final reviewData = await SpacedRepetitionService()
       .getCardReviewData(courseId, cardId);
   print('Next review: ${reviewData?.nextReviewDate}');
   ```

3. **Kiểm tra HomeScreen**
   ```
   - Restart app
   - Không thấy section "Cần ôn tập" (vì chưa đến ngày)
   - Đợi 1 ngày hoặc manual change nextReviewDate
   - Reload → Thấy section "Cần ôn tập hôm nay"
   ```

4. **Test swipe left**
   ```
   - Swipe left một card
   - Kiểm tra card xuất hiện ngay trong "Cần ôn tập"
   ```

### Test Tích Hợp

```dart
// Test service
void testSpacedRepetition() async {
  final service = SpacedRepetitionService();

  // Test 1: Create review data
  await service.updateAfterReview(
    courseId: 'test_course',
    cardId: 'test_card',
    isCorrect: true,
  );

  final reviewData = await service.getCardReviewData(
    'test_course',
    'test_card',
  );

  assert(reviewData != null);
  assert(reviewData!.intervalDays == 1);

  // Test 2: Check needs review
  assert(!reviewData.needsReview()); // Chưa đến ngày

  // Test 3: Get courses needing review
  final courses = await service.getCoursesWithCardsNeedingReview();
  print('Courses needing review: $courses');
}
```

## Lưu Ý Quan Trọng

### 1. Performance
- Service sử dụng Singleton pattern để tránh khởi tạo nhiều lần
- Hive operations rất nhanh (< 1ms)
- Load courses needing review chỉ scan qua courses, không load toàn bộ cards

### 2. Data Consistency
- Review data được lưu NGAY sau mỗi swipe
- Nếu app crash, dữ liệu vẫn được bảo toàn
- Khi xóa course, tất cả review data liên quan cũng bị xóa

### 3. Edge Cases
- **Card chưa từng học**: Không có review data → không hiển thị trong "Cần ôn tập"
- **Course mới**: Chưa có cards review → không hiển thị
- **Reset course**: Xóa toàn bộ review data

## Tương Lai & Mở Rộng

### Các tính năng có thể thêm:

1. **Statistics Dashboard**
   - Biểu đồ tiến độ học tập
   - Số lượng thẻ đã thuộc
   - Streak (số ngày học liên tục)

2. **Notification**
   - Nhắc nhở khi có thẻ cần ôn tập
   - Daily reminder

3. **Advanced Algorithms**
   - SM-2 đầy đủ với 6 levels quality
   - Anki algorithm
   - Custom intervals

4. **Review Modes**
   - Chế độ ôn tập nhanh (quick review)
   - Chế độ cram (học gấp trước kỳ thi)

5. **Analytics**
   - Tỷ lệ đúng/sai theo thời gian
   - Cards khó nhất
   - Optimal review time (sáng/tối)

## Troubleshooting

### Vấn đề: Section "Cần ôn tập" không hiển thị
**Giải pháp:**
1. Kiểm tra có cards nào đã học chưa
2. Check console logs: "Found X courses with cards needing review"
3. Verify nextReviewDate trong Hive

### Vấn đề: Review data không được lưu
**Giải pháp:**
1. Check courseId có null không
2. Verify Hive đã được initialize
3. Check console: "Saved review data for card..."

### Vấn đề: Interval không đúng
**Giải pháp:**
1. Kiểm tra repetitions count
2. Verify ease factor
3. Check logic trong CardReviewData.nextReview()

## Tài Liệu Tham Khảo

- [SM-2 Algorithm](https://www.supermemo.com/en/archives1990-2015/english/ol/sm2)
- [Anki Documentation](https://docs.ankiweb.net/)
- [Spaced Repetition Research](https://gwern.net/spaced-repetition)

---

**Tác giả**: Claude Code
**Ngày tạo**: 2025-01-30
**Version**: 1.0.0
