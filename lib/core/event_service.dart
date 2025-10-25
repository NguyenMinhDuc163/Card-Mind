import 'dart:async';

/// Event service để quản lý thông báo giữa các màn hình
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  // Stream controllers cho các loại event khác nhau
  final StreamController<CourseEvent> _courseEventController =
      StreamController<CourseEvent>.broadcast();

  /// Stream để lắng nghe các event liên quan đến khóa học
  Stream<CourseEvent> get courseEvents => _courseEventController.stream;

  /// Emit event khi có thay đổi về khóa học
  void emitCourseEvent(CourseEvent event) {
    _courseEventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    _courseEventController.close();
  }
}

/// Các loại event liên quan đến khóa học
enum CourseEventType { courseCreated, courseUpdated, courseDeleted }

/// Event object cho khóa học
class CourseEvent {
  final CourseEventType type;
  final String? courseId;
  final DateTime timestamp;

  CourseEvent({required this.type, this.courseId, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
