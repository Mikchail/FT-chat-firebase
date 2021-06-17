import "dart:io";
import "package:firebase_storage/firebase_storage.dart";
import "package:path/path.dart";

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _baseRef;
  String _profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<TaskSnapshot> uploadUserImage(String uid, File image) async {
    try {
      return await _baseRef
          .child(_profileImages)
          .child(uid)
          .putFile(image)
          .whenComplete(() => null);
    } catch (e) {
      throw Error();
    }
  }

  UploadTask uploadMediaMessage(String uid, File file) {
    var timestamp = DateTime.now();
    var fileName = basename(file.path);
    fileName += "_${timestamp.toString()}";
    try {
      return _baseRef
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(fileName)
          .putFile(file);
    } catch (e) {
      throw Error();
    }
  }
}
