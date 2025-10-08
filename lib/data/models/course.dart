import 'package:equatable/equatable.dart';
import 'flashcard.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  final List<Flashcard> flashcards;
  final int totalTerms;
  final bool isVerified;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.flashcards,
    required this.totalTerms,
    this.isVerified = false,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    iconUrl,
    flashcards,
    totalTerms,
    isVerified,
    author,
    createdAt,
    updatedAt,
    category,
  ];

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    List<Flashcard>? flashcards,
    int? totalTerms,
    bool? isVerified,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      flashcards: flashcards ?? this.flashcards,
      totalTerms: totalTerms ?? this.totalTerms,
      isVerified: isVerified ?? this.isVerified,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'flashcards': flashcards.map((x) => x.toJson()).toList(),
      'totalTerms': totalTerms,
      'isVerified': isVerified,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      flashcards:
          (json['flashcards'] as List<dynamic>)
              .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalTerms: json['totalTerms'] as int,
      isVerified: json['isVerified'] as bool? ?? false,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String,
    );
  }
}
