import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/services/sample_data_service.dart';
import 'package:card_mind/modules/create_course/model/create_course_data.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service quản lý đồng bộ dữ liệu giữa Local (Hive) và Cloud (Firestore)
///
/// Chiến lược đồng bộ:
/// - User chưa đăng nhập: Chỉ lưu local
/// - User đã đăng nhập: Đồng bộ local <-> Firestore
/// - Đăng xuất: Xóa local, load sample data
/// - Đăng nhập lại: Merge local + cloud data
class DataSyncService {
  // Singleton pattern
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Keys for local storage
  static const String _coursesListKey = 'courses_list';
  static const String _classesKey = 'library_classes';
  static const String _lastSyncTimeKey = 'last_sync_time';

  // Firestore collection names
  static const String _usersCollection = 'users';
  static const String _coursesSubcollection = 'courses';
  static const String _classesSubcollection = 'classes';

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Lấy user ID hiện tại
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isUserSignedIn => _auth.currentUser != null;

  /// =================================================================
  /// SYNC - Đồng bộ toàn bộ dữ liệu (gọi khi app start hoặc login)
  /// =================================================================

  Future<void> syncAllData() async {
    if (!isUserSignedIn) {
      print('🔄 [DataSync] User not signed in, skip sync');
      return;
    }

    if (_isSyncing) {
      print('🔄 [DataSync] Already syncing, skip');
      return;
    }

    try {
      _isSyncing = true;
      print('🔄 [DataSync] Starting full sync...');

      // 1. Download data từ Firestore về local
      await _downloadCoursesFromFirestore();
      await _downloadClassesFromFirestore();

      // 2. Upload data từ local lên Firestore (nếu có data chưa sync)
      await _uploadCoursesToFirestore();
      await _uploadClassesToFirestore();

      // 3. Cập nhật last sync time
      await _updateLastSyncTime();

      print('🔄 [DataSync] ✅ Full sync completed');
    } catch (e) {
      print('🔄 [DataSync] ❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// =================================================================
  /// UPLOAD - Đẩy dữ liệu từ Local lên Firestore
  /// =================================================================

  /// Upload tất cả courses từ local lên Firestore
  Future<void> _uploadCoursesToFirestore() async {
    if (!isUserSignedIn) return;

    try {
      print('🔄 [DataSync] Uploading courses to Firestore...');

      final localCourses = await _getLocalCourses();

      if (localCourses.isEmpty) {
        print('🔄 [DataSync] No local courses to upload');
        return;
      }

      final batch = _firestore.batch();
      final userCoursesRef = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_coursesSubcollection);

      for (final course in localCourses) {
        final docRef = userCoursesRef.doc(course.id);
        batch.set(docRef, course.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      print('🔄 [DataSync] ✅ Uploaded ${localCourses.length} courses');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to upload courses: $e');
      rethrow;
    }
  }

  /// Upload tất cả classes từ local lên Firestore
  Future<void> _uploadClassesToFirestore() async {
    if (!isUserSignedIn) return;

    try {
      print('🔄 [DataSync] Uploading classes to Firestore...');

      final localClasses = await _getLocalClasses();

      if (localClasses.isEmpty) {
        print('🔄 [DataSync] No local classes to upload');
        return;
      }

      final batch = _firestore.batch();
      final userClassesRef = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_classesSubcollection);

      for (final classData in localClasses) {
        final docRef = userClassesRef.doc(classData.id);
        batch.set(docRef, classData.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      print('🔄 [DataSync] ✅ Uploaded ${localClasses.length} classes');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to upload classes: $e');
      rethrow;
    }
  }

  /// =================================================================
  /// DOWNLOAD - Tải dữ liệu từ Firestore về Local
  /// =================================================================

  /// Download courses từ Firestore về local (chỉ lấy những thay đổi)
  Future<void> _downloadCoursesFromFirestore() async {
    if (!isUserSignedIn) return;

    try {
      print('🔄 [DataSync] Downloading courses from Firestore...');

      // Lấy thời gian sync lần cuối
      final lastSyncTime = await _getLastSyncTime();

      // Query chỉ lấy các documents có updatedAt > lastSyncTime
      Query<Map<String, dynamic>> query = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_coursesSubcollection);

      // Nếu có lastSyncTime, chỉ lấy những thay đổi sau thời điểm đó
      if (lastSyncTime != null) {
        query = query.where('updatedAt', isGreaterThan: lastSyncTime.toIso8601String());
        print('🔄 [DataSync] Fetching courses updated after ${lastSyncTime.toIso8601String()}');
      } else {
        print('🔄 [DataSync] First sync - fetching all courses');
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print('🔄 [DataSync] No new/updated courses in Firestore');
        return;
      }

      final cloudCourses = snapshot.docs
          .map((doc) => CreateCourseData.fromJson(doc.data()))
          .toList();

      // Merge với local courses
      final localCourses = await _getLocalCourses();
      final mergedCourses = _mergeCourses(localCourses, cloudCourses);

      // Lưu về local
      await _saveLocalCourses(mergedCourses);

      print('🔄 [DataSync] ✅ Downloaded ${cloudCourses.length} courses (${snapshot.docs.length} new/updated)');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to download courses: $e');
      rethrow;
    }
  }

  /// Download classes từ Firestore về local (chỉ lấy những thay đổi)
  Future<void> _downloadClassesFromFirestore() async {
    if (!isUserSignedIn) return;

    try {
      print('🔄 [DataSync] Downloading classes from Firestore...');

      // Lấy thời gian sync lần cuối
      final lastSyncTime = await _getLastSyncTime();

      // Query chỉ lấy các documents có updatedAt > lastSyncTime
      Query<Map<String, dynamic>> query = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_classesSubcollection);

      // Nếu có lastSyncTime, chỉ lấy những thay đổi sau thời điểm đó
      if (lastSyncTime != null) {
        query = query.where('updatedAt', isGreaterThan: lastSyncTime.toIso8601String());
        print('🔄 [DataSync] Fetching classes updated after ${lastSyncTime.toIso8601String()}');
      } else {
        print('🔄 [DataSync] First sync - fetching all classes');
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print('🔄 [DataSync] No new/updated classes in Firestore');
        return;
      }

      final cloudClasses = snapshot.docs
          .map((doc) => ClassData.fromJson(doc.data()))
          .toList();

      // Merge với local classes
      final localClasses = await _getLocalClasses();
      final mergedClasses = _mergeClasses(localClasses, cloudClasses);

      // Lưu về local
      await _saveLocalClasses(mergedClasses);

      print('🔄 [DataSync] ✅ Downloaded ${cloudClasses.length} classes (${snapshot.docs.length} new/updated)');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to download classes: $e');
      rethrow;
    }
  }

  /// =================================================================
  /// SYNC REALTIME - Sync từng item khi có thay đổi
  /// =================================================================

  /// Sync một course cụ thể (gọi khi tạo/update course)
  Future<void> syncCourse(CreateCourseData course) async {
    if (!isUserSignedIn) {
      print('🔄 [DataSync] User not signed in, save to local only');
      await _saveSingleCourseToLocal(course);
      return;
    }

    try {
      print('🔄 [DataSync] Syncing course: ${course.title}');
      print('🔄 [DataSync] User ID: $_currentUserId');
      print('🔄 [DataSync] Course ID: ${course.id}');
      print('🔄 [DataSync] Firestore path: users/$_currentUserId/courses/${course.id}');

      // 1. Lưu vào local
      await _saveSingleCourseToLocal(course);

      // 2. Upload lên Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_coursesSubcollection)
          .doc(course.id)
          .set(course.toJson(), SetOptions(merge: true));

      print('🔄 [DataSync] ✅ Course synced to Firestore successfully!');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to sync course: $e');
      // Vẫn lưu được local, không throw error
    }
  }

  /// Sync một class cụ thể (gọi khi tạo/update class)
  Future<void> syncClass(ClassData classData) async {
    if (!isUserSignedIn) {
      print('🔄 [DataSync] User not signed in, save to local only');
      await _saveSingleClassToLocal(classData);
      return;
    }

    try {
      print('🔄 [DataSync] Syncing class: ${classData.className}');

      // 1. Lưu vào local
      await _saveSingleClassToLocal(classData);

      // 2. Upload lên Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_classesSubcollection)
          .doc(classData.id)
          .set(classData.toJson(), SetOptions(merge: true));

      print('🔄 [DataSync] ✅ Class synced: ${classData.className}');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to sync class: $e');
      // Vẫn lưu được local, không throw error
    }
  }

  /// Xóa course (đồng bộ xóa cả local và cloud)
  Future<void> deleteCourse(String courseId) async {
    try {
      // 1. Xóa local
      final localCourses = await _getLocalCourses();
      localCourses.removeWhere((course) => course.id == courseId);
      await _saveLocalCourses(localCourses);

      // 2. Xóa Firestore (nếu đã đăng nhập)
      if (isUserSignedIn) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection(_coursesSubcollection)
            .doc(courseId)
            .delete();
      }

      print('🔄 [DataSync] ✅ Course deleted: $courseId');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to delete course: $e');
      rethrow;
    }
  }

  /// Xóa class (đồng bộ xóa cả local và cloud)
  Future<void> deleteClass(String classId) async {
    try {
      // 1. Xóa local
      final localClasses = await _getLocalClasses();
      localClasses.removeWhere((classData) => classData.id == classId);
      await _saveLocalClasses(localClasses);

      // 2. Xóa Firestore (nếu đã đăng nhập)
      if (isUserSignedIn) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection(_classesSubcollection)
            .doc(classId)
            .delete();
      }

      print('🔄 [DataSync] ✅ Class deleted: $classId');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to delete class: $e');
      rethrow;
    }
  }

  /// =================================================================
  /// LOGOUT - Xóa local data và load sample data
  /// =================================================================

  Future<void> clearLocalDataAndLoadSample() async {
    try {
      print('🔄 [DataSync] Clearing local data and loading sample...');

      // Xóa toàn bộ local data
      await LocalStorageHelper.deleteValue(_coursesListKey);
      await LocalStorageHelper.deleteValue(_classesKey);
      await LocalStorageHelper.deleteValue(_lastSyncTimeKey);

      // Xóa course_keys format
      final courseKeys = LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      for (final key in courseKeys) {
        await LocalStorageHelper.deleteValue(key as String);
      }
      await LocalStorageHelper.deleteValue('course_keys');

      // Tạo lại sample data
      await SampleDataService.recreateSampleData();

      print('🔄 [DataSync] ✅ Local data cleared, sample data loaded');
    } catch (e) {
      print('🔄 [DataSync] ❌ Failed to clear and reload: $e');
      rethrow;
    }
  }

  /// =================================================================
  /// MERGE - Chiến lược merge data khi có conflict
  /// =================================================================

  /// Merge courses: Ưu tiên item có updatedAt mới nhất
  List<CreateCourseData> _mergeCourses(
    List<CreateCourseData> localCourses,
    List<CreateCourseData> cloudCourses,
  ) {
    final Map<String, CreateCourseData> mergedMap = {};

    // Add tất cả local courses
    for (final course in localCourses) {
      mergedMap[course.id] = course;
    }

    // Merge với cloud courses (ưu tiên updatedAt mới hơn)
    for (final cloudCourse in cloudCourses) {
      final localCourse = mergedMap[cloudCourse.id];

      if (localCourse == null) {
        // Không có local, thêm cloud course
        mergedMap[cloudCourse.id] = cloudCourse;
      } else {
        // So sánh updatedAt, giữ lại cái mới hơn
        if (cloudCourse.updatedAt.isAfter(localCourse.updatedAt)) {
          mergedMap[cloudCourse.id] = cloudCourse;
        }
      }
    }

    return mergedMap.values.toList();
  }

  /// Merge classes: Ưu tiên item có updatedAt mới nhất
  List<ClassData> _mergeClasses(
    List<ClassData> localClasses,
    List<ClassData> cloudClasses,
  ) {
    final Map<String, ClassData> mergedMap = {};

    // Add tất cả local classes
    for (final classData in localClasses) {
      mergedMap[classData.id] = classData;
    }

    // Merge với cloud classes (ưu tiên updatedAt mới hơn)
    for (final cloudClass in cloudClasses) {
      final localClass = mergedMap[cloudClass.id];

      if (localClass == null) {
        // Không có local, thêm cloud class
        mergedMap[cloudClass.id] = cloudClass;
      } else {
        // So sánh updatedAt, giữ lại cái mới hơn
        if (cloudClass.updatedAt.isAfter(localClass.updatedAt)) {
          mergedMap[cloudClass.id] = cloudClass;
        }
      }
    }

    return mergedMap.values.toList();
  }

  /// =================================================================
  /// HELPER - Local storage operations
  /// =================================================================

  /// Convert nested Map<dynamic, dynamic> to Map<String, dynamic> recursively
  Map<String, dynamic> _convertMapToStringKeys(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _convertMapToStringKeys(value));
        } else if (value is List) {
          return MapEntry(key.toString(), value.map((item) {
            if (item is Map) {
              return _convertMapToStringKeys(item);
            }
            return item;
          }).toList());
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }

  Future<List<CreateCourseData>> _getLocalCourses() async {
    try {
      final List<CreateCourseData> allCourses = [];

      // 1. Đọc từ courses_list (format cũ của CourseService)
      final coursesListData = LocalStorageHelper.getValue(_coursesListKey);
      if (coursesListData != null && coursesListData is List) {
        for (final json in coursesListData) {
          try {
            // Convert nested maps recursively
            final Map<String, dynamic> jsonMap = _convertMapToStringKeys(json);
            allCourses.add(CreateCourseData.fromJson(jsonMap));
          } catch (e) {
            print('🔄 [DataSync] Error parsing course from courses_list: $e');
          }
        }
      }

      // 2. Đọc từ course_keys (format của CreateCourseNotifier)
      final courseKeys = LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      for (final key in courseKeys) {
        try {
          final courseData = LocalStorageHelper.getValue(key as String);
          if (courseData != null) {
            // Convert nested maps recursively
            final Map<String, dynamic> jsonMap = _convertMapToStringKeys(courseData);
            final course = CreateCourseData.fromJson(jsonMap);

            // Tránh duplicate - chỉ add nếu chưa có
            if (!allCourses.any((c) => c.id == course.id)) {
              allCourses.add(course);
            }
          }
        } catch (e) {
          print('🔄 [DataSync] Error parsing course from course_keys: $e');
        }
      }

      print('🔄 [DataSync] Loaded ${allCourses.length} courses from local storage');
      return allCourses;
    } catch (e) {
      print('🔄 [DataSync] Error reading local courses: $e');
      return [];
    }
  }

  Future<List<ClassData>> _getLocalClasses() async {
    try {
      final data = LocalStorageHelper.getValue(_classesKey);
      if (data != null && data is List) {
        return data
            .map((json) {
              // Hive trả về Map<dynamic, dynamic>, cần cast sang Map<String, dynamic>
              final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(json as Map);
              return ClassData.fromJson(jsonMap);
            })
            .toList();
      }
      return [];
    } catch (e) {
      print('🔄 [DataSync] Error reading local classes: $e');
      return [];
    }
  }

  Future<void> _saveLocalCourses(List<CreateCourseData> courses) async {
    try {
      // 1. Lưu vào courses_list (format CourseService)
      await LocalStorageHelper.setValue(
        _coursesListKey,
        courses.map((course) => course.toJson()).toList(),
      );

      // 2. Lưu vào course_keys format (format CreateCourseNotifier)
      final List<String> courseKeys = [];
      for (final course in courses) {
        // Tạo key theo format của CreateCourseNotifier
        final key = _generateCourseKey(course);
        courseKeys.add(key);

        // Lưu course data với key đó
        await LocalStorageHelper.setValue(key, course.toJson());
      }

      // Lưu danh sách keys
      await LocalStorageHelper.setValue('course_keys', courseKeys);

      print('🔄 [DataSync] ✅ Saved ${courses.length} courses to local storage (both formats)');
    } catch (e) {
      print('🔄 [DataSync] Error saving local courses: $e');
      rethrow;
    }
  }

  /// Generate course key theo format của CreateCourseNotifier
  String _generateCourseKey(CreateCourseData course) {
    final cleanTopic = (course.topic.isNotEmpty ? course.topic : 'unknown')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    final cleanTitle = course.title
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();

    // Sử dụng course.id làm timestamp nếu có, nếu không dùng createdAt
    final timestamp = int.tryParse(course.id) ?? course.createdAt.millisecondsSinceEpoch;

    return 'course_${cleanTopic}_${cleanTitle}_$timestamp';
  }

  Future<void> _saveLocalClasses(List<ClassData> classes) async {
    try {
      await LocalStorageHelper.setValue(
        _classesKey,
        classes.map((classData) => classData.toJson()).toList(),
      );
    } catch (e) {
      print('🔄 [DataSync] Error saving local classes: $e');
      rethrow;
    }
  }

  Future<void> _saveSingleCourseToLocal(CreateCourseData course) async {
    final courses = await _getLocalCourses();
    final index = courses.indexWhere((c) => c.id == course.id);

    if (index >= 0) {
      courses[index] = course;
    } else {
      courses.add(course);
    }

    await _saveLocalCourses(courses);
  }

  Future<void> _saveSingleClassToLocal(ClassData classData) async {
    final classes = await _getLocalClasses();
    final index = classes.indexWhere((c) => c.id == classData.id);

    if (index >= 0) {
      classes[index] = classData;
    } else {
      classes.add(classData);
    }

    await _saveLocalClasses(classes);
  }

  Future<void> _updateLastSyncTime() async {
    await LocalStorageHelper.setValue(
      _lastSyncTimeKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<DateTime?> _getLastSyncTime() async {
    final value = LocalStorageHelper.getValue(_lastSyncTimeKey);
    if (value != null && value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DateTime? getLastSyncTime() {
    final value = LocalStorageHelper.getValue(_lastSyncTimeKey);
    if (value != null && value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
