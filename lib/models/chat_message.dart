
class ChatMessage {
  String senderID;
  String message;
  int timestamp;
  ChatMessage? referenceMessage;

  ChatMessage({
    required this.senderID,
    required this.timestamp,
    required this.message,
    this.referenceMessage,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, { ID: "" }) {

    return ChatMessage(
      senderID: json['senderID'],
      timestamp: json['timestamp'],
      message: json['message'],
      referenceMessage: json['referenceMessage'] == null ? null
          : ChatMessage.fromJson(json['referenceMessage'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'message': message,
      'senderID': senderID,
      'referenceMessage': referenceMessage,
    };
  }
}
