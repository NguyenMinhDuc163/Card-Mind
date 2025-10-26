import 'package:card_mind/modules/library/services/class_interface.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';

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
    } catch (e) {
      throw Exception('Không thể lưu Chủ đề: $e');
    }
  }

  @override
  Future<ClassData?> loadClass(String classId) async {
    try {
      final allClasses = await getAllClasses();
      return allClasses.firstWhere(
        (classData) => classData.id == classId,
        orElse: () => throw Exception('Không tìm thấy Chủ đề'),
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
      throw Exception('Không thể xóa Chủ đề: $e');
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
      throw Exception('Không thể tải danh sách Chủ đề: $e');
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
      throw Exception('Không thể tìm kiếm Chủ đề: $e');
    }
  }
}
