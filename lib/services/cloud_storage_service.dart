import "dart:io";
import "package:firebase_storage/firebase_storage.dart";

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _baseRef;
  String _profileImages = "profile_images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<TaskSnapshot> uploadUserImage(String uid, File image) async {
    try {
      _baseRef
          .child(_profileImages)
          .child(uid)
          .putFile(image)
          .whenComplete(() => null);
    } catch (e) {
      print(e);
    }
  }
}
