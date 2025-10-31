import 'package:card_mind/modules/library/services/topic_interface.dart';
import 'package:card_mind/modules/library/model/topic_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:easy_localization/easy_localization.dart';

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
      throw Exception(
        tr('library.topic_service.error_save', args: [e.toString()]),
      );
    }
  }

  @override
  Future<TopicData?> loadTopic(String topicId) async {
    try {
      final allTopics = await getAllTopics();
      return allTopics.firstWhere(
        (topic) => topic.id == topicId,
        orElse:
            () => throw Exception(tr('library.topic_service.error_not_found')),
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
      throw Exception(
        tr('library.topic_service.error_delete', args: [e.toString()]),
      );
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
      throw Exception(
        tr('library.topic_service.error_load_list', args: [e.toString()]),
      );
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
      throw Exception(
        tr('library.topic_service.error_search', args: [e.toString()]),
      );
    }
  }
}
