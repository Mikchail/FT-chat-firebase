import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ft_chat/models/message.dart';

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

class Conversation {
  final String id;
  final List<String> members;
  final List<Message> messages;
  final String ownerID;

  Conversation(
      {required this.id,
      required this.members,
      required this.messages,
      required this.ownerID});

  factory Conversation.fromFireStore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as dynamic;
    List<Message> messages = [];
    List<String> members = [];
    if (data["messages"] != null) {
      data["messages"].forEach((m) {
        var messageType =
            m["type"] == "text" ? MessageType.Text : MessageType.Image;
        messages.add(Message(
            content: m["message"],
            senderID: m["senderID"],
            timestamp: m["timestamp"],
            type: messageType));
      });
    }
    data["members"].forEach((m) {
      members.add(m);
    });
    print(messages);
    return Conversation(
        id: snapshot.id,
        members: members,
        ownerID: data["ownerID"],
        messages: messages);
    ;
  }
}
