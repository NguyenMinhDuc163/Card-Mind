import 'package:equatable/equatable.dart';

class CreateCourseData extends Equatable {
  final String id;
  final String topic;
  final String title;
  final String? description;
  final String author;
  final List<TermData> terms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreateCourseData({
    required this.id,
    required this.topic,
    required this.title,
    this.description,
    required this.author,
    required this.terms,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    topic,
    title,
    description,
    author,
    terms,
    createdAt,
    updatedAt,
  ];

  CreateCourseData copyWith({
    String? id,
    String? topic,
    String? title,
    String? description,
    String? author,
    List<TermData>? terms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreateCourseData(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'title': title,
      'description': description,
      'author': author,
      'terms': terms.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CreateCourseData.fromJson(Map<String, dynamic> json) {
    return CreateCourseData(
      id: json['id'] as String,
      topic: json['topic'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      author: json['author'] as String? ?? 'Unknown',
      terms:
          (json['terms'] as List<dynamic>)
              .map((e) => TermData.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }


  factory CreateCourseData.createNew() {
    final now = DateTime.now();
    return CreateCourseData(
      id: now.millisecondsSinceEpoch.toString(),
      topic: '',
      title: '',
      description: null,
      author: 'Me', // Default value, will be updated when saving
      terms: [TermData.createNew()],
      createdAt: now,
      updatedAt: now,
    );
  }
}

class TermData extends Equatable {
  final String id;
  final String term;
  final String definition;
  final String language;

  const TermData({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
  });

  @override
  List<Object?> get props => [id, term, definition, language];

  TermData copyWith({
    String? id,
    String? term,
    String? definition,
    String? language,
  }) {
    return TermData(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'language': language,
    };
  }

  factory TermData.fromJson(Map<String, dynamic> json) {
    return TermData(
      id: json['id'] as String,
      term: json['term'] as String,
      definition: json['definition'] as String,
      language: json['language'] as String,
    );
  }

  factory TermData.createNew() {
    return TermData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      term: '',
      definition: '',
      language: 'Tiếng Việt',
    );
  }
}
