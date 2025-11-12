import 'package:card_mind/modules/course/services/course_interface.dart';
import 'package:card_mind/modules/course/model/course_data.dart';

class CourseService implements ICourseInterface {
  @override
  Future<void> saveCourseData(CourseData courseData) async {
    
  }

  @override
  Future<CourseData?> loadCourseData() async {
    
    return null;
  }

  @override
  Future<void> deleteCourseData() async {
    
  }

  @override
  Future<List<CourseData>> getAllCourses() async {
    
    return [];
  }
}
