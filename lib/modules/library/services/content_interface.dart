import 'package:card_mind/modules/library/model/content_data.dart';

abstract class IContentInterface {
  Future<void> saveContent(ContentData content);
  Future<ContentData?> loadContent(String contentId);
  Future<void> deleteContent(String contentId);
  Future<List<ContentData>> getAllContents();
  Future<List<ContentData>> searchContents(String query);
}
