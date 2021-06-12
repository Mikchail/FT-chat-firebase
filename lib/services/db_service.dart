import "package:cloud_firestore/cloud_firestore.dart";

class DBService {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  static DBService instance = DBService();
  DBService();

  String _userCollection = "Users";

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
}
