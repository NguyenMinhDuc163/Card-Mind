import 'package:card_mind/modules/create_course/services/create_course_interface.dart';
import 'package:card_mind/modules/create_course/model/create_course_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';

class CourseService implements ICreateCourseInterface {
  static const String _courseDataKey = 'create_course_data';
  static const String _coursesListKey = 'courses_list';

  @override
  Future<void> saveCourseData(CreateCourseData courseData) async {
    try {
      LocalStorageHelper.setValue(_courseDataKey, courseData.toJson());

      final allCourses = await getAllCourses();
      final existingIndex = allCourses.indexWhere((course) => course.id == courseData.id);

      if (existingIndex >= 0) {
        allCourses[existingIndex] = courseData;
      } else {
        allCourses.add(courseData);
      }

      LocalStorageHelper.setValue(
        _coursesListKey,
        allCourses.map((course) => course.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Không thể lưu dữ liệu khóa học: $e');
    }
  }

  @override
  Future<CreateCourseData?> loadCourseData() async {
    try {
      final data = LocalStorageHelper.getValue(_courseDataKey);
      if (data != null) {
        return CreateCourseData.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể tải dữ liệu khóa học: $e');
    }
  }

  @override
  Future<void> deleteCourseData() async {
    try {
      LocalStorageHelper.deleteValue(_courseDataKey);
    } catch (e) {
      throw Exception('Không thể xóa dữ liệu khóa học: $e');
    }
  }

  @override
  Future<List<CreateCourseData>> getAllCourses() async {
    try {
      final data = LocalStorageHelper.getValue(_coursesListKey);
      if (data != null && data is List) {
        return data.map((courseJson) => CreateCourseData.fromJson(courseJson)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Không thể tải danh sách khóa học: $e');
    }
  }

  Future<void> saveCompletedCourse(CreateCourseData courseData) async {
    try {
      final allCourses = await getAllCourses();
      final existingIndex = allCourses.indexWhere((course) => course.id == courseData.id);

      if (existingIndex >= 0) {
        allCourses[existingIndex] = courseData;
      } else {
        allCourses.add(courseData);
      }

      LocalStorageHelper.setValue(
        _coursesListKey,
        allCourses.map((course) => course.toJson()).toList(),
      );

      await deleteCourseData();
    } catch (e) {
      throw Exception('Không thể lưu khóa học đã hoàn thành: $e');
    }
  }
}
