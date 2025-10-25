import 'package:equatable/equatable.dart';

class TopicData extends Equatable {
  final String id;
  final String topicName;
  final String description;
  final String category;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String difficulty;
  final List<String> tags;

  const TopicData({
    required this.id,
    required this.topicName,
    required this.description,
    required this.category,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
    required this.difficulty,
    required this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    topicName,
    description,
    category,
    totalItems,
    createdAt,
    updatedAt,
    difficulty,
    tags,
  ];

  TopicData copyWith({
    String? id,
    String? topicName,
    String? description,
    String? category,
    int? totalItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? difficulty,
    List<String>? tags,
  }) {
    return TopicData(
      id: id ?? this.id,
      topicName: topicName ?? this.topicName,
      description: description ?? this.description,
      category: category ?? this.category,
      totalItems: totalItems ?? this.totalItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicName': topicName,
      'description': description,
      'category': category,
      'totalItems': totalItems,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'difficulty': difficulty,
      'tags': tags,
    };
  }

  factory TopicData.fromJson(Map<String, dynamic> json) {
    return TopicData(
      id: json['id'] as String,
      topicName: json['topicName'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      totalItems: json['totalItems'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      difficulty: json['difficulty'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }

  factory TopicData.createNew() {
    final now = DateTime.now();
    return TopicData(
      id: now.millisecondsSinceEpoch.toString(),
      topicName: '',
      description: '',
      category: 'Thư viện',
      totalItems: 0,
      createdAt: now,
      updatedAt: now,
      difficulty: 'Trung bình',
      tags: [],
    );
  }
}
