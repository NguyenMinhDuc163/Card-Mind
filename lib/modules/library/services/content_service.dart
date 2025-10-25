import 'package:card_mind/modules/library/services/content_interface.dart';
import 'package:card_mind/modules/library/model/content_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';

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
      throw Exception('Không thể lưu nội dung: $e');
    }
  }

  @override
  Future<ContentData?> loadContent(String contentId) async {
    try {
      final allContents = await getAllContents();
      return allContents.firstWhere(
        (content) => content.id == contentId,
        orElse: () => throw Exception('Không tìm thấy nội dung'),
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
      throw Exception('Không thể xóa nội dung: $e');
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
      throw Exception('Không thể tải danh sách nội dung: $e');
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
      throw Exception('Không thể tìm kiếm nội dung: $e');
    }
  }
}
