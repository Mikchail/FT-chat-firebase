import "package:cloud_firestore/cloud_firestore.dart";
import 'package:ft_chat/models/contact.dart';
import 'package:ft_chat/models/conversation_snipet.dart';
import 'package:ft_chat/models/message.dart';

class DBService {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  static DBService instance = DBService();
  DBService();

  String _userCollection = "Users";
  String _conversationsCollection = "Conversations";

  Future<void> createUserInDb(
      String uid, String name, String email, String imageURL) async {
    try {
      return await _db.collection(_userCollection).doc(uid).set({
        "id": uid,
        "name": name,
        "email": email,
        "image": imageURL,
        "lastSeen": DateTime.now().toUtc()
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String userID) {
    var ref = _db.collection(_userCollection).doc(userID);
    return ref.update({"lastSeen": Timestamp.now()});
  }

  Stream<Contact> getUserData(String userID) {
    var ref = _db.collection(_userCollection).doc(userID);
    return ref.get().asStream().map((doc) {
      return Contact.fromFirestore(doc);
    });
  }

  Stream<List<ConversationSnipet>> getUserConversations(String userID) {
    var ref = _db
        .collection(_userCollection)
        .doc(userID)
        .collection(_conversationsCollection);
    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConversationSnipet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    var ref = _db.collection(_conversationsCollection).doc(conversationID);
    return ref.snapshots().map((snapshot) {
      return Conversation.fromFireStore(snapshot);
    });
  }

  Stream<List<Contact>> getUsersInDB(String searchName) {
    var ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: searchName)
        .where("name", isLessThan: searchName + "z");
    return ref.get().asStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> sendMessage(String conversationID, Message message) {
    var ref = _db.collection(_conversationsCollection).doc(conversationID);
    var messageType = "";
    switch (message.type) {
      case MessageType.Text:
        messageType = "text";
        break;
      case MessageType.Image:
        messageType = "image";
        break;
      default:
        messageType = "text";
    }
    return ref.update({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": message.content,
            "senderID": message.senderID,
            "timestamp": message.timestamp,
            "type": messageType
          },
        ],
      ),
    });
  }
}
