import 'package:card_mind/modules/course/model/course_data.dart';

abstract class ICourseInterface {
  Future<void> saveCourseData(CourseData courseData);
  Future<CourseData?> loadCourseData();
  Future<void> deleteCourseData();
  Future<List<CourseData>> getAllCourses();
}
