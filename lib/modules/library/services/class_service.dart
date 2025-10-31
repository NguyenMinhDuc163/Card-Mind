import 'package:card_mind/modules/library/services/class_interface.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/services/data_sync_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ClassService implements IClassInterface {
  static const String _classesKey = 'library_classes';

  @override
  Future<void> saveClass(ClassData classData) async {
    try {
      final allClasses = await getAllClasses();
      final existingIndex = allClasses.indexWhere((c) => c.id == classData.id);

      if (existingIndex >= 0) {
        allClasses[existingIndex] = classData;
      } else {
        allClasses.add(classData);
      }

      LocalStorageHelper.setValue(
        _classesKey,
        allClasses.map((classData) => classData.toJson()).toList(),
      );

      // Đồng bộ class lên Firestore (nếu user đã đăng nhập)
      DataSyncService().syncClass(classData).catchError((error) {
        print('⚠️ [ClassService] Sync failed (will retry): $error');
        // Không throw error, data đã lưu local thành công
      });
    } catch (e) {
      throw Exception(
        tr('library.class_service.error_save', args: [e.toString()]),
      );
    }
  }

  @override
  Future<ClassData?> loadClass(String classId) async {
    try {
      final allClasses = await getAllClasses();
      return allClasses.firstWhere(
        (classData) => classData.id == classId,
        orElse:
            () => throw Exception(tr('library.class_service.error_not_found')),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteClass(String classId) async {
    try {
      final allClasses = await getAllClasses();
      allClasses.removeWhere((classData) => classData.id == classId);

      LocalStorageHelper.setValue(
        _classesKey,
        allClasses.map((classData) => classData.toJson()).toList(),
      );
    } catch (e) {
      throw Exception(
        tr('library.class_service.error_delete', args: [e.toString()]),
      );
    }
  }

  @override
  Future<List<ClassData>> getAllClasses() async {
    try {
      final data = LocalStorageHelper.getValue(_classesKey);
      if (data != null && data is List) {
        return data.map((classJson) => ClassData.fromJson(classJson)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(
        tr('library.class_service.error_load_list', args: [e.toString()]),
      );
    }
  }

  @override
  Future<List<ClassData>> searchClasses(String query) async {
    try {
      final allClasses = await getAllClasses();
      return allClasses
          .where(
            (classData) =>
                classData.className.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                classData.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                classData.instructor.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        tr('library.class_service.error_search', args: [e.toString()]),
      );
    }
  }
}
