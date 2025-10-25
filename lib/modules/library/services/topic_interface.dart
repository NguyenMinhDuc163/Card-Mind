import 'package:card_mind/modules/library/model/topic_data.dart';

abstract class ITopicInterface {
  Future<void> saveTopic(TopicData topic);
  Future<TopicData?> loadTopic(String topicId);
  Future<void> deleteTopic(String topicId);
  Future<List<TopicData>> getAllTopics();
  Future<List<TopicData>> searchTopics(String query);
}
