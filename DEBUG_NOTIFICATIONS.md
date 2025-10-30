# 🔍 Hướng dẫn Debug Notifications

## ❗ Vấn đề: Notifications không hiện khi đến lịch nhắc lại

### 📋 Checklist kiểm tra từng bước:

---

## ✅ Bước 1: Kiểm tra Console Logs khi mở app

Khi mở app, bạn PHẢI thấy các logs sau:

```
📱 [Daily Reminders] SCHEDULING
📱 Scheduled morning reminder at 08:00
📱 Scheduled afternoon reminder at 13:00
📱 Scheduled evening reminder at 20:00
📱 ✅ All daily reminders scheduled successfully

📱 [Reschedule] RESCHEDULING ALL REVIEW NOTIFICATIONS
📱 ✅ Rescheduled X review notifications
```

**Nếu KHÔNG thấy** → Có lỗi trong main.dart initialization

---

## ✅ Bước 2: Kiểm tra khi học xong một thẻ

Sau khi swipe right/left một thẻ, PHẢI thấy:

```
📱 ============================================
📱 [Notification] SCHEDULING REQUEST
📱 ============================================
📱 Course: 1761878288020
📱 Card: 1761878264962
📱 Next Review Date (input): 2025-11-03 09:38:17.304922
📱 Current time: 2025-10-31 09:38:17.410088
📱 Calculated scheduled time: 2025-11-03 09:00:00.000
📱 Time difference: 71:21:42.585013

📱 ============================================
📱 [Notification] SCHEDULED SUCCESSFULLY
📱 ============================================
📱 Notification ID: #123456
📱 Scheduled Time: 2025-11-03 09:00:00.000
📱 Time until notification: 71:21:42.585013
```

### 🚫 Nếu thấy:

**Case 1: Notification bị SKIPPED**
```
📱 ❌ SKIPPED: too far in future (30 days)
```
→ **Giải pháp**: Card được schedule quá xa (> 30 ngày). Đổi về minutes mode để test.

**Case 2: Notification bị DISABLED**
```
📱 ❌ DISABLED IN SETTINGS
```
→ **Giải pháp**: Notifications bị tắt. Vào Settings bật lại.

**Case 3: Permission denied**
```
❌ Error scheduling notification: PlatformException(exact_alarms_not_permitted)
```
→ **Giải pháp**: Xem Bước 3 để cấp permissions.

---

## ✅ Bước 3: Kiểm tra Permissions trên Device/Emulator

### 📱 **Android 12+ (Quan trọng nhất!)**

1. Mở **Settings** → **Apps** → **Card Mind**
2. Vào **Notifications**:
   - ✅ "Allow notifications" phải BẬT
3. Vào **Alarms & reminders**:
   - ✅ "Allow setting alarms and reminders" phải BẬT
4. Quay lại, vào **Battery**:
   - ✅ Chọn "Unrestricted" (QUAN TRỌNG!)

### 🔋 **Battery Optimization (Bắt buộc!)**

Settings → Battery → Battery optimization → Card Mind → **Don't optimize**

**Giải thích**: Nếu không tắt battery optimization, Android sẽ kill app và clear hết notifications khi app ở background lâu.

---

## ✅ Bước 4: Test với Minutes Mode

Để test nhanh, đổi sang minutes mode:

1. Vào app → Drawer → Spaced Repetition Settings
2. Đổi **Time Unit** → "minutes"
3. Đặt **Interval 1** = 1 phút
4. **Lưu cấu hình**
5. Học một thẻ (swipe right)
6. Xem console log → phải thấy:
   ```
   📱 Calculated scheduled time: 2025-10-31 09:39:17.000
   📱 Time difference: 0:01:00.000000
   ```
7. **Thoát app** (không kill)
8. Chờ 1 phút
9. ✅ Notification phải hiện

---

## ✅ Bước 5: Kiểm tra Pending Notifications

Trong app:
1. Vào **Settings** → **Notification Settings**
2. Nhấn **"Xem thông báo đang chờ"**
3. Xem danh sách

**Kết quả mong đợi**:
```
Có X thông báo đang được lên lịch:

ID: 999991
Title: 📚 Card Mind
Body: Chào buổi sáng! ☀️ Bắt đầu ngày mới...

ID: 999992
Title: 📚 Card Mind
Body: Giờ nghỉ trưa học chút...

ID: 123456 (từ card review)
Title: ⏰ Đến giờ ôn tập rồi!
Body: Bạn có 1 thẻ cần ôn tập
```

**Nếu list rỗng** → Notifications không được schedule!

---

## ✅ Bước 6: Test Immediate Notification

1. Vào **Settings** → **Notification Settings**
2. Nhấn **"Gửi thông báo thử nghiệm"**
3. ✅ Notification phải hiện **NGAY LẬP TỨC**

**Nếu không hiện** → Permission bị tắt hoặc notification channel bị block.

---

## ✅ Bước 7: Reschedule Manually

Nếu notifications bị mất:

1. Vào **Settings** → **Notification Settings**
2. Nhấn **"Reschedule tất cả notifications"**
3. Xem console log:
   ```
   📱 [Reschedule] RESCHEDULING ALL REVIEW NOTIFICATIONS
   📱 ✅ Rescheduled X review notifications
   ```
4. Nhấn **"Xem thông báo đang chờ"** để verify

---

## 🐛 Các lỗi thường gặp

### ❌ Lỗi 1: "Exact alarms not permitted"

**Nguyên nhân**: Chưa grant permission SCHEDULE_EXACT_ALARM

**Giải pháp**:
1. Settings → Apps → Card Mind → Alarms & reminders → Allow
2. Hoặc chạy lại app (sẽ auto-request)

---

### ❌ Lỗi 2: Notification không hiện khi app ở background

**Nguyên nhân**: Battery optimization kill app

**Giải pháp**:
1. Settings → Battery → Battery optimization → Card Mind → Don't optimize
2. Settings → Apps → Card Mind → Battery → Unrestricted

---

### ❌ Lỗi 3: Timezone sai

**Triệu chứng**: Notification hiện sớm/muộn hơn dự kiến

**Giải pháp**:
1. Kiểm tra timezone emulator: `adb shell getprop persist.sys.timezone`
2. Set về Vietnam: `adb shell setprop persist.sys.timezone Asia/Ho_Chi_Minh`
3. Reboot emulator

---

### ❌ Lỗi 4: Notifications bị clear sau khi kill app

**Nguyên nhân**: Android policy

**Giải pháp**:
- Đây là behavior bình thường
- Khi user mở lại app → auto reschedule
- Nếu cần persistent notifications → cần WorkManager (advanced)

---

## 📊 Expected Behavior

### ✅ Khi app FOREGROUND:
- Notifications được schedule ✅
- Console logs hiện đầy đủ ✅
- Pending list có notifications ✅

### ✅ Khi app BACKGROUND:
- Notifications vẫn trigger đúng giờ ✅ (nếu đã tắt battery optimization)
- Không có logs (app đang sleep)

### ✅ Khi app bị KILLED:
- Notifications **CÓ THỂ** bị clear ⚠️
- Khi mở lại app → auto reschedule ✅

### ✅ Khi device REBOOT:
- Boot receiver sẽ reschedule (cần test) ⚠️
- Hoặc chờ user mở app → auto reschedule ✅

---

## 🎯 Test Case để verify

### Test Case 1: Daily Reminders
1. Mở app lúc 7:00 AM
2. Check pending notifications → phải có 3 notifications (8h, 13h, 20h)
3. Đợi đến 8:00 AM
4. ✅ Notification "Chào buổi sáng!..." phải hiện

### Test Case 2: Review Notification (Minutes Mode)
1. Đổi sang minutes mode, interval = 1 phút
2. Học một thẻ lúc 9:00:00
3. Check pending → phải có notification scheduled lúc 9:01:00
4. Thoát app (không kill)
5. Đợi đến 9:01:00
6. ✅ Notification "Đến giờ ôn tập rồi!" phải hiện

### Test Case 3: Background App
1. Học thẻ với interval = 2 phút
2. Thoát app, để background
3. Đợi 2 phút
4. ✅ Notification phải hiện (nếu đã tắt battery optimization)

### Test Case 4: Kill App
1. Học thẻ với interval = 5 phút
2. Kill app hoàn toàn
3. Đợi 5 phút
4. ⚠️ Có thể KHÔNG nhận notification (Android clear)
5. Mở lại app
6. ✅ Notifications được reschedule
7. Thoát app, đợi 5 phút
8. ✅ Notification phải hiện lần này

---

## 📝 Next Steps nếu vẫn không work

1. Copy toàn bộ console logs và gửi cho tôi
2. Chụp màn hình:
   - Notification permissions
   - Battery settings
   - Pending notifications list
3. Test trên device thật (không phải emulator)
4. Check xem có app nào khác block notifications không

---

## 🔧 Advanced Debugging

### Enable verbose logging:

Thêm vào đầu notification_service.dart:
```dart
static const bool _DEBUG = true;

void _log(String message) {
  if (_DEBUG) print('📱 [NotificationService] $message');
}
```

### Check notification channel:
```dart
final channels = await _notificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.getNotificationChannels();
print('Channels: $channels');
```

### Force reschedule on every app resume:

Trong main.dart, thêm AppLifecycleListener để reschedule mỗi khi app resume:
```dart
AppLifecycleListener(
  onResume: () async {
    await NotificationService().rescheduleAllReviewNotifications();
  },
);
```
