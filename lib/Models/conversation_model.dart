import 'package:json_annotation/json_annotation.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class Conversation {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? messages;

  Conversation({
    required this.id,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.messages,
  });

  // Factory method to generate a Conversation object from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    print('Converting JSON to Conversation: $json');
    return _$ConversationFromJson(json);
  }

  // Method to convert a Conversation object to JSON
  Map<String, dynamic> toJson() {
    final json = _$ConversationToJson(this);
    print('Converting Conversation to JSON: $json');
    return json;
  }
}
