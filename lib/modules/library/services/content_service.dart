import 'package:card_mind/modules/library/services/content_interface.dart';
import 'package:card_mind/modules/library/model/content_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class ContentService implements IContentInterface {
  static const String _contentsKey = 'library_contents';

  @override
  Future<void> saveContent(ContentData content) async {
    try {
      final allContents = await getAllContents();
      final existingIndex = allContents.indexWhere((c) => c.id == content.id);

      if (existingIndex >= 0) {
        allContents[existingIndex] = content;
      } else {
        allContents.add(content);
      }

      LocalStorageHelper.setValue(
        _contentsKey,
        allContents.map((content) => content.toJson()).toList(),
      );
    } catch (e) {
      throw Exception(
        tr('library.content_service.error_save', args: [e.toString()]),
      );
    }
  }

  @override
  Future<ContentData?> loadContent(String contentId) async {
    try {
      final allContents = await getAllContents();
      return allContents.firstWhere(
        (content) => content.id == contentId,
        orElse:
            () =>
                throw Exception(tr('library.content_service.error_not_found')),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteContent(String contentId) async {
    try {
      final allContents = await getAllContents();
      allContents.removeWhere((content) => content.id == contentId);

      LocalStorageHelper.setValue(
        _contentsKey,
        allContents.map((content) => content.toJson()).toList(),
      );
    } catch (e) {
      throw Exception(
        tr('library.content_service.error_delete', args: [e.toString()]),
      );
    }
  }

  @override
  Future<List<ContentData>> getAllContents() async {
    try {
      final data = LocalStorageHelper.getValue(_contentsKey);
      if (data != null && data is List) {
        return data
            .map((contentJson) => ContentData.fromJson(contentJson))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(
        tr('library.content_service.error_load_list', args: [e.toString()]),
      );
    }
  }

  @override
  Future<List<ContentData>> searchContents(String query) async {
    try {
      final allContents = await getAllContents();
      return allContents
          .where(
            (content) =>
                content.title.toLowerCase().contains(query.toLowerCase()) ||
                content.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                content.author.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception(
        tr('library.content_service.error_search', args: [e.toString()]),
      );
    }
  }
}
