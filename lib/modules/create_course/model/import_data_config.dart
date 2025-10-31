import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';

class ImportDataConfig extends Equatable {
  final String termDefinitionDelimiter;
  final String cardDelimiter;
  final String customTermDefinitionDelimiter;
  final String customCardDelimiter;

  const ImportDataConfig({
    required this.termDefinitionDelimiter,
    required this.cardDelimiter,
    this.customTermDefinitionDelimiter = '',
    this.customCardDelimiter = '',
  });

  @override
  List<Object?> get props => [
    termDefinitionDelimiter,
    cardDelimiter,
    customTermDefinitionDelimiter,
    customCardDelimiter,
  ];

  ImportDataConfig copyWith({
    String? termDefinitionDelimiter,
    String? cardDelimiter,
    String? customTermDefinitionDelimiter,
    String? customCardDelimiter,
  }) {
    return ImportDataConfig(
      termDefinitionDelimiter:
          termDefinitionDelimiter ?? this.termDefinitionDelimiter,
      cardDelimiter: cardDelimiter ?? this.cardDelimiter,
      customTermDefinitionDelimiter:
          customTermDefinitionDelimiter ?? this.customTermDefinitionDelimiter,
      customCardDelimiter: customCardDelimiter ?? this.customCardDelimiter,
    );
  }

  String get effectiveTermDefinitionDelimiter {
    if (termDefinitionDelimiter == 'custom') {
      return customTermDefinitionDelimiter;
    }
    return _getDelimiterValue(termDefinitionDelimiter);
  }

  String get effectiveCardDelimiter {
    if (cardDelimiter == 'custom') {
      return customCardDelimiter;
    }
    return _getDelimiterValue(cardDelimiter);
  }

  String _getDelimiterValue(String delimiter) {
    switch (delimiter) {
      case 'tab':
        return '\t'; // Tab character
      case 'comma':
        return ',';
      case 'semicolon':
        return ';';
      case 'newline':
        return '\n';
      default:
        return delimiter;
    }
  }

  factory ImportDataConfig.defaultConfig() {
    return const ImportDataConfig(
      termDefinitionDelimiter: 'tab',
      cardDelimiter: 'newline',
    );
  }
}

class ParsedDataResult extends Equatable {
  final List<ParsedTerm> terms;
  final String? errorMessage;
  final bool hasError;

  const ParsedDataResult({
    required this.terms,
    this.errorMessage,
    this.hasError = false,
  });

  @override
  List<Object?> get props => [terms, errorMessage, hasError];

  factory ParsedDataResult.success(List<ParsedTerm> terms) {
    return ParsedDataResult(terms: terms);
  }

  factory ParsedDataResult.error(String errorMessage) {
    return ParsedDataResult(
      terms: [],
      errorMessage: errorMessage,
      hasError: true,
    );
  }
}

class ParsedTerm extends Equatable {
  final String term;
  final String definition;
  final String language;

  ParsedTerm({required this.term, required this.definition, String? language})
    : language = language ?? tr('language.vietnamese');

  @override
  List<Object?> get props => [term, definition, language];

  ParsedTerm copyWith({String? term, String? definition, String? language}) {
    return ParsedTerm(
      term: term ?? this.term,
      definition: definition ?? this.definition,
      language: language ?? this.language,
    );
  }
}
