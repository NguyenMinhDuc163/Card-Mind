import 'package:card_mind/modules/create_course/model/import_data_config.dart';
import 'package:easy_localization/easy_localization.dart';

class ImportDataService {
  static ParsedDataResult parseData(String rawData, ImportDataConfig config) {
    try {
      if (rawData.trim().isEmpty) {
        return ParsedDataResult.error(
          'create_course_import.errors.empty_data'.tr(),
        );
      }

      final cardDelimiter = config.effectiveCardDelimiter;
      final termDefinitionDelimiter = config.effectiveTermDefinitionDelimiter;

      if (cardDelimiter.isEmpty) {
        return ParsedDataResult.error(
          'create_course_import.errors.empty_card_delimiter'.tr(),
        );
      }

      if (termDefinitionDelimiter.isEmpty) {
        return ParsedDataResult.error(
          'create_course_import.errors.empty_term_delimiter'.tr(),
        );
      }

      final cards = _splitCards(rawData, cardDelimiter);

      if (cards.isEmpty) {
        return ParsedDataResult.error(
          'create_course_import.errors.no_valid_data'.tr(),
        );
      }

      final List<ParsedTerm> terms = [];

      for (int i = 0; i < cards.length; i++) {
        final card = cards[i].trim();
        if (card.isEmpty) continue;

        final term = _parseTerm(card, termDefinitionDelimiter, i + 1);
        if (term != null) {
          terms.add(term);
        }
      }

      if (terms.isEmpty) {
        return ParsedDataResult.error(
          'create_course_import.errors.no_valid_terms'.tr(),
        );
      }

      return ParsedDataResult.success(terms);
    } catch (e) {
      return ParsedDataResult.error(
        'create_course_import.errors.parse_exception'.tr(args: [e.toString()]),
      );
    }
  }

  static List<String> _splitCards(String data, String delimiter) {
    if (delimiter == '\n') {
      return data.split('\n').where((line) => line.trim().isNotEmpty).toList();
    } else {
      return data
          .split(delimiter)
          .where((card) => card.trim().isNotEmpty)
          .toList();
    }
  }

  static ParsedTerm? _parseTerm(String card, String delimiter, int cardNumber) {
    List<String> parts;

    
    if (delimiter == '\t') {
      
      parts = card.split(RegExp(r'\t|\s{2,}'));
    } else {
      parts = card.split(delimiter);
    }

    if (parts.length < 2) {
      return null;
    }

    final term = parts[0].trim();
    final definition = parts.sublist(1).join(' ').trim();

    if (term.isEmpty || definition.isEmpty) {
      return null;
    }

    return ParsedTerm(
      term: term,
      definition: definition,
      language: tr('language.vietnamese'),
    );
  }

  static String? validateConfig(ImportDataConfig config) {
    if (config.termDefinitionDelimiter == 'custom' &&
        config.customTermDefinitionDelimiter.trim().isEmpty) {
      return 'create_course_import.errors.config_term_required'.tr();
    }

    if (config.cardDelimiter == 'custom' &&
        config.customCardDelimiter.trim().isEmpty) {
      return 'create_course_import.errors.config_card_required'.tr();
    }

    return null;
  }

  static String getSampleData() {
    return '''Hello	xin chào
dog	chó
cat	mèo
house	nhà
water	nước''';
  }
}
