import 'package:card_mind/modules/create_course/model/import_data_config.dart';

class ImportDataService {
  static ParsedDataResult parseData(String rawData, ImportDataConfig config) {
    try {
      if (rawData.trim().isEmpty) {
        return ParsedDataResult.error('Dữ liệu không được để trống');
      }

      final cardDelimiter = config.effectiveCardDelimiter;
      final termDefinitionDelimiter = config.effectiveTermDefinitionDelimiter;

      if (cardDelimiter.isEmpty) {
        return ParsedDataResult.error('Delimiter giữa các thẻ không được để trống');
      }

      if (termDefinitionDelimiter.isEmpty) {
        return ParsedDataResult.error('Delimiter giữa thuật ngữ và định nghĩa không được để trống');
      }

      final cards = _splitCards(rawData, cardDelimiter);

      if (cards.isEmpty) {
        return ParsedDataResult.error('Không tìm thấy dữ liệu hợp lệ');
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
        return ParsedDataResult.error('Không tìm thấy thuật ngữ hợp lệ nào');
      }

      return ParsedDataResult.success(terms);
    } catch (e) {
      return ParsedDataResult.error('Lỗi khi parse dữ liệu: ${e.toString()}');
    }
  }

  static List<String> _splitCards(String data, String delimiter) {
    if (delimiter == '\n') {
      return data.split('\n').where((line) => line.trim().isNotEmpty).toList();
    } else {
      return data.split(delimiter).where((card) => card.trim().isNotEmpty).toList();
    }
  }

  static ParsedTerm? _parseTerm(String card, String delimiter, int cardNumber) {
    final parts = card.split(delimiter);

    if (parts.length < 2) {
      return null;
    }

    final term = parts[0].trim();
    final definition = parts.sublist(1).join(delimiter).trim();

    if (term.isEmpty || definition.isEmpty) {
      return null;
    }

    return ParsedTerm(term: term, definition: definition, language: 'Tiếng Việt');
  }

  static String? validateConfig(ImportDataConfig config) {
    if (config.termDefinitionDelimiter == 'custom' &&
        config.customTermDefinitionDelimiter.trim().isEmpty) {
      return 'Vui lòng nhập delimiter tùy chỉnh cho thuật ngữ và định nghĩa';
    }

    if (config.cardDelimiter == 'custom' && config.customCardDelimiter.trim().isEmpty) {
      return 'Vui lòng nhập delimiter tùy chỉnh cho các thẻ';
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
