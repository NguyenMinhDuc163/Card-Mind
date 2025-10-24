import 'package:card_mind/init.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:flutter/foundation.dart';

class CourseResultNotifier extends ChangeNotifier {
  CourseData? _courseData;
  bool _isLoading = false;
  String? _errorMessage;

  CourseData? get courseData => _courseData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
