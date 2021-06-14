import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSnipet {
  final String id;
  final String chatID;
  final String lastMessage;
  final String name;
  final String image;
  final int unseenCount;
  final Timestamp timestamp;

  ConversationSnipet(
      {required this.id,
      required this.chatID,
      required this.lastMessage,
      required this.name,
      required this.image,
      required this.unseenCount,
      required this.timestamp});

  factory ConversationSnipet.fromFirestore(snapshot) {
    var data = snapshot.data() as dynamic;
    return ConversationSnipet(
      id: snapshot.id,
      chatID: data["chatID"],
      lastMessage: data["lastMessage"] != null ? data["lastMessage"] : "",
      name: data["name"],
      image: data["image"],
      unseenCount: data["unseenCount"],
      timestamp: data["timestamp"],
    );
  }
}
