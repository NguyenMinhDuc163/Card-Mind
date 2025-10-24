import 'package:card_mind/modules/create_course/model/create_course_data.dart';

abstract class ICreateCourseInterface {
  Future<void> saveCourseData(CreateCourseData courseData);
  Future<CreateCourseData?> loadCourseData();
  Future<void> deleteCourseData();
  Future<List<CreateCourseData>> getAllCourses();
}
