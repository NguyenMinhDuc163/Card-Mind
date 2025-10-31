import 'package:card_mind/core/helpers/local_storage_helper.dart';

class SampleDataService {
  static const String _firstLaunchKey = 'is_first_launch';

  /// Kiểm tra và khởi tạo dữ liệu mẫu nếu cần
  static Future<void> initializeSampleData() async {
    try {
      // Kiểm tra xem đã là lần đầu chạy app chưa
      final isFirstLaunch =
          LocalStorageHelper.getValue(_firstLaunchKey) as bool? ?? true;

      if (!isFirstLaunch) {
        return; // Đã có dữ liệu, không cần tạo sample data
      }

      // Kiểm tra xem đã có dữ liệu thật chưa
      final existingCourses =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>?;
      final existingClasses =
          LocalStorageHelper.getValue('library_classes') as List<dynamic>?;

      if (existingCourses != null && existingCourses.isNotEmpty) {
        // Đã có courses thật, không tạo sample
        await LocalStorageHelper.setValue(_firstLaunchKey, false);
        return;
      }

      if (existingClasses != null && existingClasses.isNotEmpty) {
        // Đã có classes thật, không tạo sample
        await LocalStorageHelper.setValue(_firstLaunchKey, false);
        return;
      }

      // Tạo sample data
      await _createSampleCourses();
      await _createSampleClasses();

      // Đánh dấu đã khởi tạo
      await LocalStorageHelper.setValue(_firstLaunchKey, false);

      print('Sample data initialized successfully');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  /// Tạo 3 học phần mẫu về từ vựng tiếng Anh
  static Future<void> _createSampleCourses() async {
    final now = DateTime.now();
    final sampleCourses = [
      {
        'id': 'sample_course_1',
        'title': 'Từ Vựng Gia Đình',
        'description': 'Học từ vựng về các thành viên trong gia đình',
        'topic': 'Gia đình',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'terms': [
          {
            'id': 'term_1_1',
            'term': 'Father',
            'definition': 'Bố, cha',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'term_1_2',
            'term': 'Mother',
            'definition': 'Mẹ',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'term_1_3',
            'term': 'Brother',
            'definition': 'Anh trai, em trai',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        ],
      },
      {
        'id': 'sample_course_2',
        'title': 'Màu Sắc Cơ Bản',
        'description': 'Học tên các màu sắc cơ bản trong tiếng Anh',
        'topic': 'Màu sắc',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'terms': [
          {
            'id': 'term_2_1',
            'term': 'Red',
            'definition': 'Màu đỏ',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'term_2_2',
            'term': 'Blue',
            'definition': 'Màu xanh dương',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'term_2_3',
            'term': 'Green',
            'definition': 'Màu xanh lá',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        ],
      },
      {
        'id': 'sample_course_3',
        'title': 'Động Vật Dễ Thương',
        'description': 'Học tên các con vật dễ thương',
        'topic': 'Động vật',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'terms': [
          {
            'id': 'term_3_1',
            'term': 'Cat',
            'definition': 'Con mèo',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'term_3_2',
            'term': 'Dog',
            'definition': 'Con chó',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'term_3_3',
            'term': 'Bird',
            'definition': 'Con chim',
            'language': 'en',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        ],
      },
    ];

    // Lưu từng course vào storage (course_keys format)
    final List<String> courseKeys = [];
    for (final course in sampleCourses) {
      final courseKey = 'course_${course['id']}';
      await LocalStorageHelper.setValue(courseKey, course);
      courseKeys.add(courseKey);
    }

    // Lưu danh sách course keys (CreateCourseNotifier format)
    await LocalStorageHelper.setValue('course_keys', courseKeys);

    // Cũng lưu vào courses_list format (CourseService format) để backward compatibility
    await LocalStorageHelper.setValue('courses_list', sampleCourses);
  }

  /// Tạo 3 Chủ đề mẫu về tiếng Anh
  static Future<void> _createSampleClasses() async {
    final now = DateTime.now();
    final sampleClasses = [
      {
        'id': 'sample_class_1',
        'className': 'Chủ đề Tiếng Anh Cơ Bản',
        'description': 'Chủ đề từ vựng tiếng Anh cơ bản cho người mới bắt đầu',
        'instructor': 'Cô Sarah',
        'totalStudents': 20,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'status': 'active',
        'students': [],
      },
      {
        'id': 'sample_class_2',
        'className': 'Chủ đề Màu Sắc & Hình Dạng',
        'description': 'Học từ vựng về màu sắc và hình dạng trong tiếng Anh',
        'instructor': 'Thầy John',
        'totalStudents': 15,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'status': 'active',
        'students': [],
      },
      {
        'id': 'sample_class_3',
        'className': 'Chủ đề Động Vật & Thiên Nhiên',
        'description': 'Khám phá thế giới động vật qua tiếng Anh',
        'instructor': 'Cô Emma',
        'totalStudents': 18,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'status': 'active',
        'students': [],
      },
    ];

    // Lưu classes vào storage
    await LocalStorageHelper.setValue('library_classes', sampleClasses);
  }

  /// Reset sample data (chỉ dùng cho testing)
  static Future<void> resetSampleData() async {
    // Xóa các course keys trước (đọc trước khi xóa danh sách)
    final courseKeys =
        LocalStorageHelper.getValue('course_keys') as List<dynamic>?;
    if (courseKeys != null) {
      for (final key in courseKeys) {
        await LocalStorageHelper.deleteValue(key as String);
      }
    }

    // Sau đó xóa metadata
    await LocalStorageHelper.deleteValue(_firstLaunchKey);
    await LocalStorageHelper.deleteValue('course_keys');
    await LocalStorageHelper.deleteValue('courses_list');
    await LocalStorageHelper.deleteValue('library_classes');
  }

  /// Force recreate sample data với format mới
  static Future<void> recreateSampleData() async {
    try {
      // Reset data cũ
      await resetSampleData();

      // Tạo lại sample data với format mới
      await _createSampleCourses();
      await _createSampleClasses();

      // Đánh dấu đã có dữ liệu (không phải first launch)
      await LocalStorageHelper.setValue(_firstLaunchKey, false);

      print('✅ [SampleData] Sample data recreated successfully');
    } catch (e) {
      print('❌ [SampleData] Error recreating sample data: $e');
    }
  }
}
