import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataManagementService {
  /// Hiển thị dialog xác nhận xóa dữ liệu
  static Future<bool> showDeleteDataConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Xóa dữ liệu',
                style: AppTextStyles.textHeader3.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Bạn có chắc chắn muốn xóa tất cả dữ liệu?\n\nHành động này không thể hoàn tác.',
                style: AppTextStyles.textContent2.copyWith(
                  color: context.colors.onPrimary.withOpacity(0.8),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Hủy',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Xóa'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Xóa tất cả dữ liệu trong database local
  static Future<void> deleteAllData() async {
    try {
      // Xóa tất cả course keys và courses
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>?;
      if (courseKeys != null) {
        for (final key in courseKeys) {
          await LocalStorageHelper.deleteValue(key as String);
        }
        await LocalStorageHelper.deleteValue('course_keys');
      }

      // Xóa tất cả classes
      await LocalStorageHelper.deleteValue('library_classes');

      // Xóa tất cả bookmarks
      await LocalStorageHelper.deleteValue('bookmark_keys');

      // Xóa tất cả create course data
      await LocalStorageHelper.deleteValue('create_course_data');

      // Xóa first launch flag để có thể tạo lại sample data
      await LocalStorageHelper.deleteValue('is_first_launch');

      // Xóa tất cả keys khác có thể có
      await _deleteAllStorageKeys();

      print('All data deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
      throw Exception('Không thể xóa dữ liệu: $e');
    }
  }

  /// Xóa tất cả keys trong storage (fallback method)
  static Future<void> _deleteAllStorageKeys() async {
    try {
      // Xóa các keys phổ biến
      final commonKeys = [
        'course_keys',
        'library_classes',
        'bookmark_keys',
        'create_course_data',
        'is_first_launch',
        'theme_mode',
        'language_code',
      ];

      for (final key in commonKeys) {
        await LocalStorageHelper.deleteValue(key);
      }
    } catch (e) {
      print('Error deleting all keys: $e');
    }
  }

  /// Restart app và quay về dashboard
  static Future<void> restartApp(BuildContext context) async {
    try {
      // Đóng tất cả màn hình hiện tại và quay về dashboard
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/dashboardScreen', (route) => false);

      print('App restarted successfully');
    } catch (e) {
      print('Error restarting app: $e');
    }
  }

  /// Xử lý toàn bộ flow xóa dữ liệu
  static Future<void> handleDeleteData(BuildContext context) async {
    try {
      // 1. Hiển thị dialog xác nhận
      final confirmed = await showDeleteDataConfirmation(context);

      if (!confirmed) {
        return; // User hủy
      }

      // 2. Hiển thị loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: context.colors.primary,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Đang xóa dữ liệu...',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
      );

      // 3. Xóa dữ liệu
      await deleteAllData();

      // 4. Đóng loading dialog
      Navigator.of(context).pop();

      // 5. Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa tất cả dữ liệu'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 6. Restart app
      await Future.delayed(const Duration(milliseconds: 500));
      await restartApp(context);
    } catch (e) {
      // Đóng loading dialog nếu có
      Navigator.of(context).pop();

      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
