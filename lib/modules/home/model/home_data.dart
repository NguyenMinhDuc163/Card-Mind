import 'package:equatable/equatable.dart';

class HomeData extends Equatable {
  final List<CourseItem> courses;
  final List<ClassItem> classes;

  const HomeData({required this.courses, required this.classes});

  @override
  List<Object?> get props => [courses, classes];

  HomeData copyWith({List<CourseItem>? courses, List<ClassItem>? classes}) {
    return HomeData(
      courses: courses ?? this.courses,
      classes: classes ?? this.classes,
    );
  }
}

class CourseItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final int totalTerms;
  final String author;
  final int reviewCardsCount; // Số lượng thẻ cần ôn tập (spaced repetition)

  const CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.totalTerms,
    required this.author,
    this.reviewCardsCount = 0,
  });

  @override
  List<Object?> get props =>
      [id, title, description, totalTerms, author, reviewCardsCount];
}

class ClassItem extends Equatable {
  final String id;
  final String className;
  final String description;
  final String instructor;
  final int totalStudents;
  final String status;

  const ClassItem({
    required this.id,
    required this.className,
    required this.description,
    required this.instructor,
    required this.totalStudents,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    className,
    description,
    instructor,
    totalStudents,
    status,
  ];
}
