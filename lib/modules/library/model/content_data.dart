import 'package:equatable/equatable.dart';

class ContentData extends Equatable {
  final String id;
  final String title;
  final String description;
  final String author;
  final int totalTerms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final bool isCompleted;

  const ContentData({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.totalTerms,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    author,
    totalTerms,
    createdAt,
    updatedAt,
    category,
    isCompleted,
  ];

  ContentData copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    int? totalTerms,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    bool? isCompleted,
  }) {
    return ContentData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      totalTerms: totalTerms ?? this.totalTerms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'totalTerms': totalTerms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  factory ContentData.fromJson(Map<String, dynamic> json) {
    return ContentData(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      totalTerms: json['totalTerms'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  factory ContentData.createNew() {
    final now = DateTime.now();
    return ContentData(
      id: now.millisecondsSinceEpoch.toString(),
      title: '',
      description: '',
      author: 'User',
      totalTerms: 0,
      createdAt: now,
      updatedAt: now,
      category: 'Học phần',
      isCompleted: false,
    );
  }
}
