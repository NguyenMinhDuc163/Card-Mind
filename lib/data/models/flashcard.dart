import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String frontText;
  final String backText;
  final String? frontImage;
  final String? backImage;
  final String category;
  final bool isLearned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    this.frontImage,
    this.backImage,
    required this.category,
    this.isLearned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    frontText,
    backText,
    frontImage,
    backImage,
    category,
    isLearned,
    createdAt,
    updatedAt,
  ];

  Flashcard copyWith({
    String? id,
    String? frontText,
    String? backText,
    String? frontImage,
    String? backImage,
    String? category,
    bool? isLearned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      category: category ?? this.category,
      isLearned: isLearned ?? this.isLearned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      'frontImage': frontImage,
      'backImage': backImage,
      'category': category,
      'isLearned': isLearned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      frontText: json['frontText'] as String,
      backText: json['backText'] as String,
      frontImage: json['frontImage'] as String?,
      backImage: json['backImage'] as String?,
      category: json['category'] as String,
      isLearned: json['isLearned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
