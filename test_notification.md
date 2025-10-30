# Debug Notification Issues

## Bước 1: Kiểm tra Permissions

1. Mở Settings trên emulator/device
2. Vào Apps → Card Mind → Permissions
3. Kiểm tra các permissions sau:
   - ✅ Notifications: Allowed
   - ✅ Alarms & reminders: Allowed
   - ✅ Exact alarms: Allowed

## Bước 2: Tắt Battery Optimization

1. Settings → Apps → Card Mind
2. Battery → Unrestricted
3. Hoặc: Settings → Battery → Battery optimization → Card Mind → Don't optimize

## Bước 3: Test Immediate Notification

Vào app → Settings → Notification Settings → "Gửi thông báo thử nghiệm"

**Kết quả mong đợi**: Notification hiện ngay lập tức

## Bước 4: Check Pending Notifications

Vào app → Settings → Notification Settings → "Xem thông báo đang chờ"

**Kết quả mong đợi**: Hiện danh sách notifications đang được schedule

## Bước 5: Xem Console Logs

Khi chạy app, xem console để tìm:

```
📱 [Notification] SCHEDULED SUCCESSFULLY
📱 Notification ID: #...
📱 Scheduled Time: ...
📱 Time until notification: ...
```

Hoặc lỗi:

```
❌ Error scheduling notification: ...
📱 ❌ SKIPPED: ...
📱 ❌ DISABLED IN SETTINGS
```

## Bước 6: Test với Minutes Mode

1. Vào Settings → Spaced Repetition Settings
2. Đổi Time Unit sang "minutes"
3. Đặt Interval 1 = 1 phút
4. Học một thẻ
5. Xem console log
6. Chờ 1 phút

**Kết quả mong đợi**: Notification hiện sau 1 phút

## Các Vấn Đề Thường Gặp

### 1. Notification không hiện khi app ở background

**Nguyên nhân**: Battery optimization
**Giải pháp**: Tắt battery optimization (Bước 2)

### 2. Notification bị skip

**Nguyên nhân**: Scheduled time là quá khứ hoặc quá xa tương lai
**Giải pháp**: Check console log để xem lý do

### 3. Permission denied

**Nguyên nhân**: Chưa grant permissions
**Giải pháp**: Grant permissions (Bước 1)

### 4. Timezone sai

**Nguyên nhân**: Emulator timezone khác với system
**Giải pháp**: Đặt timezone trong emulator về Asia/Ho_Chi_Minh
