import 'package:card_mind/modules/library/model/class_data.dart';

abstract class IClassInterface {
  Future<void> saveClass(ClassData classData);
  Future<ClassData?> loadClass(String classId);
  Future<void> deleteClass(String classId);
  Future<List<ClassData>> getAllClasses();
  Future<List<ClassData>> searchClasses(String query);
}
