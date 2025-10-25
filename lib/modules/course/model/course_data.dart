import 'package:equatable/equatable.dart';

class CourseData extends Equatable {
  final String id;
  final String topic;
  final String title;
  final String? description;
  final List<TermData> terms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseData({
    required this.id,
    required this.topic,
    required this.title,
    this.description,
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
    terms,
    createdAt,
    updatedAt,
  ];

  CourseData copyWith({
    String? id,
    String? topic,
    String? title,
    String? description,
    List<TermData>? terms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseData(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      description: description ?? this.description,
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
      'terms': terms.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      id: json['id'] as String,
      topic: json['topic'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      terms:
          (json['terms'] as List<dynamic>)
              .map((e) => TermData.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
