# 🔔 HƯỚNG DẪN TEST NOTIFICATION

## 📋 Các bước test đơn giản:

### Bước 1: Rebuild app
```bash
# Dừng app hiện tại (Ctrl+C hoặc Stop trong IDE)
# Sau đó rebuild và chạy lại:
flutter run

# Hoặc nếu đang chạy trên emulator/device cụ thể:
flutter run -d <device-id>
```

⚠️ **QUAN TRỌNG**: Phải rebuild app vì đã thêm native plugin mới (flutter_local_notifications)

---

### Bước 2: Mở màn hình Test Notification

Có 2 cách để mở màn hình test:

#### Cách 1: Thêm button tạm vào màn Settings
Thêm code này vào màn Settings của bạn:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/notification-test');
  },
  child: Text('Test Notifications'),
)
```

#### Cách 2: Mở trực tiếp từ code (nhanh nhất)
Tìm file `lib/modules/dashboard/screen/dashboard_screen.dart` hoặc màn hình home, thêm dòng này vào `initState()`:

```dart
@override
void initState() {
  super.initState();

  // TẠM THỜI: Mở màn test notification sau 1 giây
  Future.delayed(Duration(seconds: 1), () {
    Navigator.pushNamed(context, '/notification-test');
  });
}
```

---

### Bước 3: Test các tính năng

Sau khi màn hình test mở ra, bạn sẽ thấy 7 nút test:

#### 🟢 Test 1: Test Notification Ngay
- Nhấn nút này để gửi notification ngay lập tức
- Check thanh notification trên điện thoại
- **Nếu thấy notification = THÀNH CÔNG!**

#### 🔵 Test 2: Schedule Sau 10 Giây
- Nhấn nút này
- Đợi 10 giây
- Notification sẽ hiện lên (app có thể đóng hoặc background)

#### 🟠 Test 3: Schedule Ngày Mai 9:00
- Schedule notification cho 9:00 sáng ngày mai
- Kiểm tra pending notifications tăng lên

#### 🟣 Test 4: Request Permissions
- **BẮT BUỘC chạy đầu tiên trên iOS**
- Trên Android notifications đã được bật mặc định

#### 🔷 Test 5: Check Enabled
- Kiểm tra xem notifications có được bật không

#### 🟦 Test 6: Toggle On/Off
- Bật/tắt notifications

#### 🔴 Test 7: Cancel All
- Hủy tất cả pending notifications

---

## 🎯 Test nhanh nhất (1 phút):

```bash
# 1. Rebuild app
flutter run

# 2. Sau khi app chạy, navigate tới màn test notification
#    (dùng một trong 2 cách ở Bước 2)

# 3. Nhấn nút "1. Test Notification Ngay"

# 4. Check thanh notification trên điện thoại
#    → Nếu thấy "Test Notification" = THÀNH CÔNG! 🎉
```

---

## 🔧 Troubleshooting

### Lỗi: MissingPluginException
**Nguyên nhân**: Chưa rebuild app sau khi thêm package

**Giải pháp**:
```bash
flutter clean
flutter pub get
flutter run
```

### Không thấy notification
**Kiểm tra**:
1. ✅ Đã rebuild app chưa?
2. ✅ Đã request permissions chưa? (iOS)
3. ✅ Notification setting của app có bật không?
4. ✅ Do Not Disturb có bật không?

### Android: Không thấy notification
```bash
# Check Android logs
flutter logs | grep -i notification

# Hoặc
adb logcat | grep -i flutter
```

---

## 📱 Platform-specific notes

### Android
- Notifications hoạt động ngay, không cần setup thêm
- Channel được tạo tự động
- Check trong Settings > Apps > Card Mind > Notifications

### iOS
- Phải request permissions lần đầu
- Test trên simulator có thể không show notification
- **NÊN test trên thiết bị thật**

---

## 🎨 Customize notification

Chỉnh sửa các tham số trong file:
```
lib/core/config/notification_config.dart
```

Ví dụ:
```dart
// Đổi thời gian gửi từ 9:00 sang 8:00
static const int defaultNotificationHour = 8;

// Đổi title
static const String defaultTitle = '📚 Giờ học rồi!';

// Tắt âm thanh
static const bool playSound = false;
```

---

## ✅ Khi nào notification sẽ tự động gửi?

Sau khi test xong, trong sử dụng thực tế:

1. **User học flashcard** (swipe right/left)
2. **SpacedRepetitionService tính toán** nextReviewDate
3. **Notification tự động được schedule** cho thời gian đó
4. **Đến giờ → Notification tự động gửi** (mặc định 9:00 sáng)

**Không cần làm gì thêm!** Hệ thống đã tự động hoạt động.

---

## 🗑️ Xóa màn hình test sau khi xong

Sau khi test xong và chắc chắn hoạt động, có thể:

1. Xóa file: `lib/modules/settings/screen/notification_test_screen.dart`
2. Xóa route trong: `lib/core/routes/routers.dart`
3. Xóa file hướng dẫn này

Hoặc giữ lại để test sau này! 😊
