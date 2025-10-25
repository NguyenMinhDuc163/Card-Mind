import 'package:card_mind/modules/library/services/topic_interface.dart';
import 'package:card_mind/modules/library/model/topic_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';

class TopicService implements ITopicInterface {
  static const String _topicsKey = 'library_topics';

  @override
  Future<void> saveTopic(TopicData topic) async {
    try {
      final allTopics = await getAllTopics();
      final existingIndex = allTopics.indexWhere((t) => t.id == topic.id);

      if (existingIndex >= 0) {
        allTopics[existingIndex] = topic;
      } else {
        allTopics.add(topic);
      }

      LocalStorageHelper.setValue(
        _topicsKey,
        allTopics.map((topic) => topic.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Không thể lưu chủ đề: $e');
    }
  }

  @override
  Future<TopicData?> loadTopic(String topicId) async {
    try {
      final allTopics = await getAllTopics();
      return allTopics.firstWhere(
        (topic) => topic.id == topicId,
        orElse: () => throw Exception('Không tìm thấy chủ đề'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    try {
      final allTopics = await getAllTopics();
      allTopics.removeWhere((topic) => topic.id == topicId);

      LocalStorageHelper.setValue(
        _topicsKey,
        allTopics.map((topic) => topic.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Không thể xóa chủ đề: $e');
    }
  }

  @override
  Future<List<TopicData>> getAllTopics() async {
    try {
      final data = LocalStorageHelper.getValue(_topicsKey);
      if (data != null && data is List) {
        return data.map((topicJson) => TopicData.fromJson(topicJson)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Không thể tải danh sách chủ đề: $e');
    }
  }

  @override
  Future<List<TopicData>> searchTopics(String query) async {
    try {
      final allTopics = await getAllTopics();
      return allTopics
          .where(
            (topic) =>
                topic.topicName.toLowerCase().contains(query.toLowerCase()) ||
                topic.description.toLowerCase().contains(query.toLowerCase()) ||
                topic.category.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm chủ đề: $e');
    }
  }
}
