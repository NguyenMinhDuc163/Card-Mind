import 'package:equatable/equatable.dart';

class ClassData extends Equatable {
  final String id;
  final String className;
  final String description;
  final String instructor;
  final int totalStudents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final List<String> students;

  const ClassData({
    required this.id,
    required this.className,
    required this.description,
    required this.instructor,
    required this.totalStudents,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.students,
  });

  @override
  List<Object?> get props => [
    id,
    className,
    description,
    instructor,
    totalStudents,
    createdAt,
    updatedAt,
    status,
    students,
  ];

  ClassData copyWith({
    String? id,
    String? className,
    String? description,
    String? instructor,
    int? totalStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? students,
  }) {
    return ClassData(
      id: id ?? this.id,
      className: className ?? this.className,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      students: students ?? this.students,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'description': description,
      'instructor': instructor,
      'totalStudents': totalStudents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'students': students,
    };
  }

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      id: json['id'] as String,
      className: json['className'] as String,
      description: json['description'] as String,
      instructor: json['instructor'] as String,
      totalStudents: json['totalStudents'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as String,
      students: (json['students'] as List<dynamic>).cast<String>(),
    );
  }

  factory ClassData.createNew() {
    final now = DateTime.now();
    return ClassData(
      id: now.millisecondsSinceEpoch.toString(),
      className: '',
      description: '',
      instructor: 'User',
      totalStudents: 0,
      createdAt: now,
      updatedAt: now,
      status: 'active',
      students: [],
    );
  }
}
