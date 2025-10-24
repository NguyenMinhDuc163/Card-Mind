import 'package:card_mind/modules/course/services/course_interface.dart';
import 'package:card_mind/modules/course/model/course_data.dart';

class CourseService implements ICourseInterface {
  @override
  Future<void> saveCourseData(CourseData courseData) async {
    // TODO: Implement save logic
  }

  @override
  Future<CourseData?> loadCourseData() async {
    // TODO: Implement load logic
    return null;
  }

  @override
  Future<void> deleteCourseData() async {
    // TODO: Implement delete logic
  }

  @override
  Future<List<CourseData>> getAllCourses() async {
    // TODO: Implement get all courses logic
    return [];
  }
}
