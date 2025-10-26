import 'dart:async';

/// Event service để quản lý thông báo giữa các màn hình
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  // Stream controllers cho các loại event khác nhau
  final StreamController<CourseEvent> _courseEventController =
      StreamController<CourseEvent>.broadcast();
  final StreamController<ClassEvent> _classEventController =
      StreamController<ClassEvent>.broadcast();

  /// Stream để lắng nghe các event liên quan đến khóa học
  Stream<CourseEvent> get courseEvents => _courseEventController.stream;

  /// Stream để lắng nghe các event liên quan đến Chủ đề
  Stream<ClassEvent> get classEvents => _classEventController.stream;

  /// Emit event khi có thay đổi về khóa học
  void emitCourseEvent(CourseEvent event) {
    _courseEventController.add(event);
  }

  /// Emit event khi có thay đổi về Chủ đề
  void emitClassEvent(ClassEvent event) {
    _classEventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    _courseEventController.close();
    _classEventController.close();
  }
}

/// Các loại event liên quan đến khóa học
enum CourseEventType { courseCreated, courseUpdated, courseDeleted }

/// Các loại event liên quan đến Chủ đề
enum ClassEventType { classCreated, classUpdated, classDeleted }

/// Event object cho khóa học
class CourseEvent {
  final CourseEventType type;
  final String? courseId;
  final DateTime timestamp;

  CourseEvent({required this.type, this.courseId, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

/// Event object cho Chủ đề
class ClassEvent {
  final ClassEventType type;
  final String? classId;
  final DateTime timestamp;

  ClassEvent({required this.type, this.classId, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
