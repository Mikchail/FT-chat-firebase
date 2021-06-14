import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastSeen;
  final String name;
  Contact(
      {required this.id,
      required this.email,
      required this.image,
      required this.lastSeen,
      required this.name});

  factory Contact.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as dynamic;
    // var data = fromJson(snapshot.data() as Map<String, dynamic>);
    return Contact(
        id: snapshot.id,
        email: data["email"],
        image: data["image"],
        lastSeen: data["lastSeen"],
        name: data["name"]);
  }

  static fromJson(Map<String, dynamic> json) {
    return {
      "email": json["email"],
      "image": json["image"],
      "lastseen": json["lastseen"],
      "name": json["name"]
    };
  }
}
