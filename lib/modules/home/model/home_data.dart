import 'package:equatable/equatable.dart';

class HomeData extends Equatable {
  final List<CourseItem> courses;

  const HomeData({required this.courses});

  @override
  List<Object?> get props => [courses];

  HomeData copyWith({List<CourseItem>? courses}) {
    return HomeData(courses: courses ?? this.courses);
  }
}

class CourseItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final int totalTerms;
  final String author;

  const CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.totalTerms,
    required this.author,
  });

  @override
  List<Object?> get props => [id, title, description, totalTerms, author];
}
